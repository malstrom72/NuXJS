#!/usr/bin/env python3
import os
import re
import subprocess
from pathlib import Path

def git_diff_lines():
	cmd = ['git', 'diff', '-U0', '-w', 'main', '--', 'src/NuXJS.cpp', 'src/NuXJS.h']
	return subprocess.run(cmd, check=True, capture_output=True, text=True).stdout.splitlines()

def parse_hunks(diff_lines):
	files = {}
	current = None
	new_start = None
	plus = []
	minus = []
	for line in diff_lines:
		if line.startswith('diff --git'):
			if new_start is not None:
				files[current].append((new_start, plus, minus))
				new_start, plus, minus = None, [], []
			parts = line.split()
			current = parts[3][2:]
			files.setdefault(current, [])
		elif line.startswith('@@'):
			if new_start is not None:
				files[current].append((new_start, plus, minus))
			m = re.search(r'\+(\d+)(?:,(\d+))?', line)
			new_start = int(m.group(1)) - 1
			plus, minus = [], []
		elif line.startswith('+') and not line.startswith('+++'):
			plus.append(line[1:] + '\n')
		elif line.startswith('-') and not line.startswith('---'):
			minus.append(line[1:] + '\n')
	if new_start is not None:
		files[current].append((new_start, plus, minus))
	return files

def insert_guards(path, hunks):
	file_path = Path(path)
	lines = file_path.read_text().splitlines(True)
	offset = 0
	for start, plus, minus in hunks:
		start += offset
		if plus:
			indent = re.match(r'\t*', lines[start]).group(0) if start < len(lines) else ''
			guard_indent = indent[:-1] if len(indent) > 0 else ''
			lines.insert(start, f"{guard_indent}#if (NUXJS_ES5)\n")
			end = start + 1 + len(plus)
			if minus:
				lines.insert(end, f"{guard_indent}#else\n")
				lines[end + 1:end + 1] = minus
				lines.insert(end + 1 + len(minus), f"{guard_indent}#endif\n")
				offset += len(minus) + 3
			else:
				lines.insert(end, f"{guard_indent}#endif\n")
				offset += 2
		elif minus:
			base = start if start < len(lines) else len(lines)
			indent = re.match(r'\t*', lines[base]).group(0) if lines else ''
			guard_indent = indent[:-1] if len(indent) > 0 else ''
			lines.insert(start, f"{guard_indent}#if (!NUXJS_ES5)\n")
			lines[start + 1:start + 1] = minus
			lines.insert(start + 1 + len(minus), f"{guard_indent}#endif\n")
			offset += len(minus) + 2
	file_path.write_text(''.join(lines))

def main():
	root = Path(__file__).resolve().parent.parent
	os.chdir(root)
	diff_lines = git_diff_lines()
	for path, hunks in parse_hunks(diff_lines).items():
		insert_guards(path, hunks)

if __name__ == '__main__':
	main()

