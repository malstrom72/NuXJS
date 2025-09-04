#!/usr/bin/env python3
"""Wrap differences between the current tree and another branch in
conditional guards.

Existing ``NUXJS_ES5`` blocks are stripped first so the diff operates on
plain ES5 sources. The resulting hunks are wrapped in ``#if`` / ``#else``
blocks guarded by a configurable macro (default: ``NUXJS_ES5``).

Running the tool with ``--remove`` performs only the initial stripping,
restoring the original ES5 code without reapplying the diff.
"""

import argparse
import difflib
import os
import re
import subprocess
from pathlib import Path

DEFAULT_FILES = ["src/NuXJS.cpp", "src/NuXJS.h"]


def _normalized(lines: list[str]) -> list[str]:
	"""Return ``lines`` with all whitespace removed for comparison."""
	return [re.sub(r"\s+", "", s) for s in lines]


def _indent(line: str) -> str:
	"""Return the leading tab sequence of ``line``."""
	m = re.match(r"\t*", line)
	return m.group(0) if m else ""


def _check_balance(block: list[str], path: str) -> None:
		"""Ensure ``block`` has balanced ``#if``/``#endif`` pairs."""
		depth = 0
		for line in block:
				s = line.lstrip()
				if s.startswith("#if"):
						depth += 1
				elif s.startswith("#endif"):
						depth -= 1
						if depth < 0:
								raise ValueError(f"unmatched #endif in {path}")
		if depth != 0:
				raise ValueError(f"unbalanced #if/#endif in {path}")


def guard_diff(ref: list[str], cur: list[str], macro: str, path: str) -> list[str]:
		"""Return ``cur`` with differing regions guarded against ``ref``."""
		out: list[str] = []
		matcher = difflib.SequenceMatcher(a=ref, b=cur)
		for tag, i1, i2, j1, j2 in matcher.get_opcodes():
				if tag == "equal":
						out.extend(cur[j1:j2])
						continue

				ref_block = ref[i1:i2]
				cur_block = cur[j1:j2]
				_check_balance(ref_block, path)
				_check_balance(cur_block, path)
				sample = cur_block[0] if cur_block else (ref_block[0] if ref_block else "")
				indent = _indent(sample)
				prefix = indent[:-1] if indent else ""
				out.append(f"{prefix}#if ({macro})\n")
				out.extend(cur_block)
				if ref_block:
						out.append(f"{prefix}#else\n")
						out.extend(ref_block)
				out.append(f"{prefix}#endif\n")
		return out


def strip_macro(lines: list[str], macro: str) -> list[str]:
		"""Return ``lines`` with ``macro`` guards removed (keeping ES5)."""
		out: list[str] = []
		i = 0
		while i < len(lines):
				line = lines[i]
				stripped = line.lstrip()
				if stripped.startswith("#if") and macro in stripped:
						negated = "!" in stripped or ("defined" in stripped and "!" in stripped.split(macro, 1)[0]) or stripped.startswith("#ifndef")
						i += 1
						if_block: list[str] = []
						else_block: list[str] = []
						block = if_block
						depth = 1
						while i < len(lines) and depth > 0:
								cur = lines[i]
								s = cur.lstrip()
								if s.startswith("#if"):
										depth += 1
										block.append(cur)
								elif s.startswith("#endif"):
										depth -= 1
										if depth > 0:
												block.append(cur)
								elif depth == 1 and (s.startswith("#else") or s.startswith("#elif")):
										block = else_block
								else:
										block.append(cur)
								i += 1
						out.extend(else_block if negated else if_block)
						continue
				out.append(line)
				i += 1
		return out


def main() -> None:
		parser = argparse.ArgumentParser(description="Guard or remove ES5 diffs")
		parser.add_argument("files", nargs="*", default=DEFAULT_FILES,
				help="Files to process")
		parser.add_argument("--branch", default="main",
				help="Branch to diff against (default: main)")
		parser.add_argument("--macro", default="NUXJS_ES5",
				help="Preprocessor macro to guard diffs (default: NUXJS_ES5)")
		parser.add_argument("--remove", action="store_true",
				help="Strip existing guards without applying new diffs")
		args = parser.parse_args()

		root = Path(__file__).resolve().parent.parent
		os.chdir(root)

		for path in args.files:
				p = Path(path)
				lines = p.read_text().splitlines(True)
				stripped = strip_macro(lines, args.macro)
				if args.remove:
						p.write_text("".join(stripped))
						continue

				ref = subprocess.run(
						["git", "show", f"{args.branch}:{path}"],
						check=True, capture_output=True, text=True
				).stdout.splitlines(True)
				ref = strip_macro(ref, args.macro)
				if _normalized(ref) == _normalized(stripped):
						p.write_text("".join(stripped))
						continue
				guarded = guard_diff(ref, stripped, args.macro, path)
				p.write_text("".join(guarded))


if __name__ == "__main__":
	main()

