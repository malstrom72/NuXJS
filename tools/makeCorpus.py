#!/usr/bin/env python3
from __future__ import annotations

import argparse
import shutil
from pathlib import Path
from typing import Iterable, List


def flatten_relative_path(path: Path) -> str:
    parts = list(path.parts)
    return "_".join(parts)


def write_test_sections(test_file: Path, tests_root: Path, destination: Path) -> int:
    rel_path = test_file.relative_to(tests_root)
    flattened = flatten_relative_path(rel_path)
    stem = Path(flattened).name
    content = test_file.read_text(encoding="utf-8", errors="ignore").replace("\r\n", "\n")

    section_lines: List[str] = []
    index = 0
    for raw_line in content.splitlines():
        if not raw_line:
            continue
        directive = raw_line[0]
        payload = raw_line[1:]
        if directive == ">":
            section_lines.append(payload)
        elif directive == "-":
            if section_lines:
                save_section(destination, stem, index, section_lines)
                index += 1
                section_lines = []
    if section_lines:
        save_section(destination, stem, index, section_lines)
        index += 1
    return index


def save_section(destination: Path, stem: str, index: int, lines: Iterable[str]) -> None:
    destination.mkdir(parents=True, exist_ok=True)
    section_path = destination / f"{stem}_{index}.js"
    text = "\n".join(lines) + "\n"
    section_path.write_text(text, encoding="utf-8")


def copy_js_sources(sources: Iterable[Path], repo_root: Path, destination: Path) -> int:
    copied = 0
    for src in sources:
        if not src.is_dir():
            continue
        for js_file in src.rglob("*.js"):
            try:
                rel = js_file.relative_to(repo_root)
            except ValueError:
                resolved = js_file.resolve()
                flattened = flatten_relative_path(Path(*resolved.parts[1:]))
                rel = Path("_external") / flattened
            target = destination / rel
            target.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(js_file, target)
            copied += 1
    return copied


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Create a NuXJS fuzzing corpus from tests and JS sources.")
    parser.add_argument("output", nargs="?", default="corpus", help="Destination directory for the corpus (default: corpus)")
    parser.add_argument(
        "--include",
        action="append",
        dest="includes",
        metavar="DIR",
        help="Additional directories to scan for .js files.",
    )
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    repo_root = Path(__file__).resolve().parents[1]
    output_dir = (repo_root / args.output).resolve()
    if output_dir.exists():
        shutil.rmtree(output_dir)
    tests_root = repo_root / "tests"
    tests_destination = output_dir / "tests"
    js_destination = output_dir / "js"

    tests_written = 0
    if tests_root.is_dir():
        for test_file in tests_root.rglob("*.io"):
            tests_written += write_test_sections(test_file, tests_root, tests_destination)

    default_sources = [repo_root / name for name in ("benchmarks", "examples", "src", "tools", "tests", "docs")]
    include_sources = []
    if args.includes:
        include_sources = [repo_root / Path(path) for path in args.includes]
    copied_files = copy_js_sources(default_sources + include_sources, repo_root, js_destination)

    summary_lines = [
        f"Created corpus in {output_dir}",
        f"Converted {tests_written} JavaScript snippets from test inputs.",
        f"Copied {copied_files} existing .js files.",
    ]
    output_dir.mkdir(parents=True, exist_ok=True)
    (output_dir / "summary.txt").write_text("\n".join(summary_lines) + "\n", encoding="utf-8")
    for line in summary_lines:
        print(line)


if __name__ == "__main__":
    main()
