#!/usr/bin/env python3
import argparse
import difflib
import fnmatch
import json
import os
import shlex
import subprocess
import sys
from dataclasses import dataclass, field
from pathlib import Path
from typing import Dict, Iterable, List, Optional, Tuple

TOOLS_DIR = Path(__file__).resolve().parent
if str(TOOLS_DIR) not in sys.path:
        sys.path.insert(0, str(TOOLS_DIR))

from annotate_io_cli import collect_targets, detect_newline  # type: ignore

REPO_ROOT = TOOLS_DIR.parent


@dataclass
class LineEntry:
        text: str
        kind: str  # cli, input, output, legacy, separator, raw, comment, blank


@dataclass
class Section:
        index: int
        input_indices: List[int] = field(default_factory=list)
        output_indices: List[int] = field(default_factory=list)

        def wants_rewrite(self, lines: List[LineEntry]) -> bool:
                return any(lines[idx].kind == 'legacy' for idx in self.output_indices)


def parse_io_file(path: Path):
        original = path.read_text(encoding='utf-8')
        newline = detect_newline(original)
        had_trailing_newline = original.endswith('\n') if newline == '\n' else original.endswith('\r\n')
        lines = original.splitlines()

        line_entries: List[LineEntry] = []
        sections: List[Section] = []
        current_section: Optional[Section] = None
        cli_args: Optional[str] = None
        cli_index: Optional[int] = None

        def flush_section():
                nonlocal current_section
                if current_section is not None:
                        sections.append(current_section)
                        current_section = None

        def ensure_section() -> Section:
                nonlocal current_section
                if current_section is None:
                                current_section = Section(len(sections))
                return current_section

        for raw_line in lines:
                line_index = len(line_entries)
                if raw_line.startswith('// CLI:'):
                        cli_args = raw_line[len('// CLI:'):].strip()
                        cli_index = len(line_entries)
                        line_entries.append(LineEntry(raw_line, 'cli'))
                        continue
                if raw_line == '':
                        line_entries.append(LineEntry(raw_line, 'blank'))
                        continue
                directive = raw_line[0]
                if directive == '>':
                        if current_section is not None and current_section.output_indices:
                                flush_section()
                        section = ensure_section()
                        section.input_indices.append(line_index)
                        line_entries.append(LineEntry(raw_line, 'input'))
                elif directive == '<':
                        section = ensure_section()
                        section.output_indices.append(line_index)
                        line_entries.append(LineEntry(raw_line, 'output'))
                elif directive == '!':
                        section = ensure_section()
                        section.output_indices.append(line_index)
                        line_entries.append(LineEntry(raw_line, 'legacy'))
                elif directive == '-':
                        line_entries.append(LineEntry(raw_line, 'separator'))
                        flush_section()
                elif directive == '/' and raw_line.startswith('//'):
                        line_entries.append(LineEntry(raw_line, 'comment'))
                else:
                        section = ensure_section()
                        section.output_indices.append(line_index)
                        line_entries.append(LineEntry(raw_line, 'raw'))
        flush_section()

        if cli_args is None:
                cli_args = ''
        return original, newline, had_trailing_newline, cli_args, cli_index, line_entries, sections


def section_inputs(section: Section, lines: List[LineEntry]) -> str:
        commands: List[str] = []
        for idx in section.input_indices:
                text = lines[idx].text
                if text.startswith('> '):
                        commands.append(text[2:])
                else:
                        commands.append(text[1:].lstrip())
        return '\n'.join(commands)


def build_js_script(sections: List[Section], lines: List[LineEntry]) -> str:
        parts: List[str] = []
        for section in sections:
                header = f"----<<<< {section.index} >>>>----"
                parts.append(f'print("{header}");')
                parts.append('')
                input_block = section_inputs(section, lines)
                if input_block:
                        parts.append(input_block)
                parts.append('')
        return '\n'.join(parts)


def filter_cli_args(raw_cli: str) -> List[str]:
        if not raw_cli:
                        return []
        args = shlex.split(raw_cli)
        filtered: List[str] = []
        for arg in args:
                if arg in ('--legacy-exceptions', '-E'):
                        continue
                if arg.startswith('--legacy-exceptions='):
                        continue
                if arg == '-Elegacy-exceptions':
                        continue
                filtered.append(arg)
        return filtered


def run_sections(executable: List[str], cli_args: List[str], sections: List[Section], lines: List[LineEntry]):
        if not sections:
                return []
        script = build_js_script(sections, lines)
        command = executable + cli_args
        completed = subprocess.run(command, input=script, capture_output=True, text=True)
        combined = (completed.stdout or '') + (completed.stderr or '')
        normalized = combined.replace('\r\n', '\n').strip('\n')
        outputs: List[List[str]] = [[] for _ in sections]
        headers: Dict[str, int] = {f"----<<<< {section.index} >>>>----": section.index for section in sections}
        current: Optional[int] = None
        for line in normalized.split('\n'):
                if line in headers:
                        current = headers[line]
                        continue
                if current is None:
                        continue
                outputs[current].append(line)
        return outputs


def render_cli_line(args: Iterable[str]) -> str:
        rendered = ' '.join(args)
        return '// CLI:' if not rendered else f'// CLI: {rendered}'


def resolve_path(path: str) -> Path:
        candidate = Path(path)
        if not candidate.is_absolute():
                return (REPO_ROOT / candidate).resolve()
        return candidate.resolve()


def should_skip(rel_path: str, patterns: Iterable[str]) -> bool:
        return any(fnmatch.fnmatch(rel_path, pattern) for pattern in patterns)


def load_inventory(path: Path) -> Tuple[List[Dict[str, object]], Dict[str, Dict[str, object]]]:
        data = json.loads(path.read_text(encoding='utf-8'))
        mapping: Dict[str, Dict[str, object]] = {}
        for entry in data:
                rel = entry.get('path')
                if isinstance(rel, str):
                        mapping[rel] = entry
        return data, mapping


def inventory_targets(entries: List[Dict[str, object]], skip_patterns: Iterable[str]) -> List[Path]:
        targets: List[Path] = []
        seen: set[Path] = set()
        for entry in entries:
                rel = entry.get('path')
                if not isinstance(rel, str):
                        continue
                if should_skip(rel, skip_patterns):
                        continue
                candidate = resolve_path(rel)
                if not candidate.exists():
                        print(f"warning: {candidate} listed in inventory but not found", file=sys.stderr)
                        continue
                if candidate.suffix != '.io':
                        continue
                if candidate not in seen:
                        targets.append(candidate)
                        seen.add(candidate)
        return targets


def update_inventory_file(path: Path, entries: List[Dict[str, object]], mapping: Dict[str, Dict[str, object]], converted: Dict[str, Dict[str, object]]):
        if not converted:
                        return
        updated = False
        for rel_path, info in converted.items():
                entry = mapping.get(rel_path)
                if entry is None:
                        continue
                if entry.get('requires_legacy'):
                        entry['requires_legacy'] = False
                        updated = True
                if entry.get('converted') is not True:
                        entry['converted'] = True
                        updated = True
                modern_cli = info.get('cli')
                if modern_cli is not None and entry.get('modern_cli') != modern_cli:
                        entry['modern_cli'] = modern_cli
                        updated = True
        if not updated:
                return
        serialized = json.dumps(entries, indent=2, sort_keys=True) + '\n'
        path.write_text(serialized, encoding='utf-8')
        print(f"updated inventory {path}")


def rewrite_lines(path: Path, executable: List[str], check_only: bool):
        original, newline, had_trailing_newline, cli_args_raw, cli_index, line_entries, sections = parse_io_file(path)
        cli_args = filter_cli_args(cli_args_raw)
        cli_rendered = render_cli_line(cli_args)
        cli_needs_update = False
        if cli_index is not None:
                if line_entries[cli_index].text != cli_rendered:
                        cli_needs_update = True
        else:
                if cli_args_raw or cli_args:
                        cli_needs_update = True
        sections_to_update = [section for section in sections if section.wants_rewrite(line_entries)]
        if not sections_to_update and not cli_needs_update:
                return False, original, cli_rendered
        section_outputs = run_sections(executable, cli_args, sections, line_entries)
        replacements: Dict[int, List[str]] = {}
        for section in sections_to_update:
                actual_lines = section_outputs[section.index] if section.index < len(section_outputs) else []
                replacements[section.index] = [f"< {line}" if line else '<' for line in actual_lines]
        section_by_first_output: Dict[int, Section] = {}
        for section in sections:
                if not section.output_indices:
                        continue
                section_by_first_output[section.output_indices[0]] = section
        result_lines: List[str] = []
        idx = 0
        total_lines = len(line_entries)
        inserted_cli = False
        while idx < total_lines:
                section = section_by_first_output.get(idx)
                if section is not None and section.index in replacements:
                        result_lines.extend(replacements[section.index])
                        idx = section.output_indices[-1] + 1
                        continue
                entry = line_entries[idx]
                if entry.kind == 'cli':
                        result_lines.append(cli_rendered)
                        inserted_cli = True
                else:
                        result_lines.append(entry.text)
                idx += 1
        if cli_index is None and (cli_args_raw or cli_args) and not inserted_cli:
                result_lines.insert(0, cli_rendered)
        rewritten = newline.join(result_lines)
        if had_trailing_newline and not rewritten.endswith(newline):
                        rewritten += newline
        if not had_trailing_newline and rewritten.endswith(newline):
                        rewritten = rewritten[: -len(newline)]
        if rewritten == original:
                return False, original, cli_rendered
        if check_only:
                diff = difflib.unified_diff(
                        original.splitlines(keepends=True),
                        rewritten.splitlines(keepends=True),
                        fromfile=str(path),
                        tofile=str(path),
                        lineterm='',
                )
                for line in diff:
                        print(line)
                return True, original, cli_rendered
        backup_path = path.with_suffix(path.suffix + '.bak')
        backup_path.write_text(original, encoding='utf-8')
        path.write_text(rewritten, encoding='utf-8')
        print(f"rewrote {path}")
        return True, rewritten, cli_rendered


DEFAULT_EXECUTABLE = os.environ.get('NUXJS_REWRITE_BINARY', 'build/Debug/NuXJS -s')


def parse_arguments(argv: List[str]):
        parser = argparse.ArgumentParser(description='Rewrite legacy NuXJS exception expectations with modern diagnostics.')
        parser.add_argument('paths', nargs='*', help='Optional .io files or directories to process (defaults to tests/).')
        parser.add_argument('--nujs', default=DEFAULT_EXECUTABLE, help='Command used to execute NuXJS (default: %(default)s). Override with NUXJS_REWRITE_BINARY.')
        parser.add_argument('--inventory', help='Legacy exception inventory JSON to drive the rewrite (e.g. docs/LegacyExceptionInventory.json).')
        parser.add_argument('--inventory-update', action='store_true', help='Persist converted status back into the inventory JSON.')
        parser.add_argument('--skip', action='append', default=[], help='Glob pattern of inventory entries to skip (repeatable).')
        parser.add_argument('--check', action='store_true', help='Dry-run mode: show diffs instead of writing files.')
        return parser.parse_args(argv[1:])


def main(argv: List[str]):
        args = parse_arguments(argv)
        skip_patterns = args.skip or []
        inventory_entries: List[Dict[str, object]] = []
        inventory_mapping: Dict[str, Dict[str, object]] = {}
        inventory_path: Optional[Path] = None
        if args.inventory:
                inventory_path = resolve_path(args.inventory)
                if inventory_path.exists():
                        inventory_entries, inventory_mapping = load_inventory(inventory_path)
                else:
                        print(f"warning: inventory {inventory_path} not found", file=sys.stderr)
        io_files: List[Path] = []
        seen: set[Path] = set()
        if inventory_entries:
                for candidate in inventory_targets(inventory_entries, skip_patterns):
                        if candidate not in seen:
                                io_files.append(candidate)
                                seen.add(candidate)
        explicit_targets: List[Path] = []
        if args.paths:
                explicit_targets = collect_targets(args.paths)
        elif not inventory_entries:
                explicit_targets = collect_targets(args.paths)
        for candidate in explicit_targets:
                rel = candidate.relative_to(REPO_ROOT).as_posix()
                if should_skip(rel, skip_patterns):
                        continue
                if candidate not in seen:
                        io_files.append(candidate)
                        seen.add(candidate)
        if not io_files:
                        return 0
        executable = shlex.split(args.nujs)
        updates = 0
        converted: Dict[str, Dict[str, object]] = {}
        for path in io_files:
                changed, _, cli_line = rewrite_lines(path, executable, args.check)
                if changed:
                        updates += 1
                        rel = path.relative_to(REPO_ROOT).as_posix()
                        converted[rel] = {'cli': cli_line}
        if args.check:
                if updates:
                        return 1
                return 0
        if args.inventory_update and inventory_entries and inventory_path is not None:
                update_inventory_file(inventory_path, inventory_entries, inventory_mapping, converted)
        return 0


if __name__ == '__main__':
        sys.exit(main(sys.argv))
