#!/usr/bin/env python3
"""Guard differing regions between two source files.

Usage:
	python diffguard.py MACRO sourceA sourceB destination
	python diffguard.py MACRO --remove source destination

Given ``sourceA`` and ``sourceB``, the utility compares their contents and
writes to ``destination`` the contents of ``sourceA`` with any regions that
differ from ``sourceB`` wrapped in ``#if``/``#else`` blocks controlled by
``MACRO``. Unchanged regions are taken verbatim from ``sourceA`` so the default
code path always reflects that file. When ``MACRO`` is defined the code from
``sourceB`` is used instead. Existing regions already guarded by that macro are
stripped prior to comparison so the diff operates on the plain source. Run with
``--remove`` to drop all existing guards and emit the unguarded ``source``.

This is useful when maintaining a single file that needs alternative code paths
for different runtime environments.
"""

import argparse
import difflib
import re
from pathlib import Path


def _normalized(lines: list[str]) -> list[str]:
	"""Return ``lines`` with all whitespace removed for comparison."""
	return [re.sub(r"\s+", "", s) for s in lines]


def _indent(line: str) -> str:
	"""Return the leading tab sequence of ``line``."""
	m = re.match(r"\t*", line)
	return m.group(0) if m else ""


def _check_balance(block: list[str], path: str, base: int, label: str) -> None:
	"""Ensure ``block`` has balanced ``#if``/``#endif`` pairs."""
	depth = 0
	for i, line in enumerate(block):
		s = line.lstrip()
		if s.startswith("#if"):
			depth += 1
		elif s.startswith("#endif"):
			depth -= 1
			if depth < 0:
				raise ValueError(
					f"unmatched #endif in {path} ({label} line {base + i + 1})"
				)
	if depth != 0:
		raise ValueError(f"unbalanced #if/#endif in {path} ({label})")


def guard_diff(base: list[str], alt: list[str], macro: str, path: str) -> list[str]:
	"""Return ``base`` with differing regions guarded to switch to ``alt``."""
	out: list[str] = []
	matcher = difflib.SequenceMatcher(a=_normalized(base), b=_normalized(alt))
	for tag, i1, i2, j1, j2 in matcher.get_opcodes():
		if tag == "equal":
			out.extend(base[i1:i2])
			continue

		base_block = base[i1:i2]
		alt_block = alt[j1:j2]
		if (
			_normalized(base_block) == _normalized(alt_block)
			or not any(line.strip() for line in base_block + alt_block)
		):
			out.extend(base_block)
			continue
		_check_balance(base_block, path, i1, "baseline")
		_check_balance(alt_block, path, j1, "alternate")
		sample = base_block[0] if base_block else (alt_block[0] if alt_block else "")
		indent = _indent(sample)
		prefix = indent[:-1] if indent else ""
		out.append(f"{prefix}#if ({macro})\n")
		out.extend(alt_block)
		if base_block:
			out.append(f"{prefix}#else\n")
			out.extend(base_block)
		out.append(f"{prefix}#endif\n")
	return out


def remove_empty_guards(lines: list[str], macro: str) -> list[str]:
	"""Remove empty ``#if``/``#endif`` blocks guarded by ``macro``."""
	out: list[str] = []
	i = 0
	while i < len(lines):
		line = lines[i]
		stripped = line.lstrip()
		if stripped.startswith("#if") and macro in stripped:
			j = i + 1
			depth = 1
			has_code = False
			while j < len(lines) and depth > 0:
				s = lines[j].lstrip()
				if s.startswith("#if"):
					depth += 1
				elif s.startswith("#endif"):
					depth -= 1
				elif depth == 1 and s and not s.startswith("#else") and not s.startswith("#elif") and lines[j].strip():
					has_code = True
				j += 1
			if not has_code:
				i = j
				continue
		out.append(line)
		i += 1
	return out


def strip_macro(lines: list[str], macro: str) -> list[str]:
	"""Return ``lines`` with ``macro`` guards removed."""
	out: list[str] = []
	i = 0
	while i < len(lines):
		line = lines[i]
		stripped = line.lstrip()
		if stripped.startswith("#if") and macro in stripped:
			negated = "!" in stripped or ("defined" in stripped and "!" in stripped.split(macro, 1)[
										  0]) or stripped.startswith("#ifndef")
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
	parser = argparse.ArgumentParser(
		description="Guard or remove conditional diffs",
	)
	parser.add_argument(
		"macro", help="Preprocessor macro controlling guarded regions"
	)
	parser.add_argument(
		"--remove", action="store_true",
		help="Strip existing guards without applying new diffs",
	)
	parser.add_argument(
		"paths", nargs="+",
		help="Input and output paths",
	)
	args = parser.parse_args()

	if args.remove:
		if len(args.paths) != 2:
			parser.error("--remove requires SOURCE and DESTINATION")
		source, destination = args.paths
		lines = Path(source).read_text().splitlines(True)
		stripped = strip_macro(lines, args.macro)
		stripped = remove_empty_guards(stripped, args.macro)
		Path(destination).write_text("".join(stripped))
		return

	if len(args.paths) != 3:
		parser.error("Requires SOURCEA SOURCEB DESTINATION")
	source_a, source_b, destination = args.paths
	base = Path(source_a).read_text().splitlines(True)
	base = strip_macro(base, args.macro)
	base = remove_empty_guards(base, args.macro)
	alt = Path(source_b).read_text().splitlines(True)
	alt = strip_macro(alt, args.macro)
	alt = remove_empty_guards(alt, args.macro)
	if _normalized(base) == _normalized(alt):
		Path(destination).write_text("".join(base))
		return
	guarded = guard_diff(base, alt, args.macro, destination)
	guarded = remove_empty_guards(guarded, args.macro)
	Path(destination).write_text("".join(guarded))


if __name__ == "__main__":
	main()
