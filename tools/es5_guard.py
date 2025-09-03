#!/usr/bin/env python3
import os
import re
import subprocess
from pathlib import Path

def git_diff_paths():
	cmd = ['git', 'diff', '-U0', '-w', 'main', '--', 'src/NuXJS.cpp', 'src/NuXJS.h']
	return subprocess.run(cmd, check=True, capture_output=True, text=True).stdout.splitlines()

def parse_ranges(diff_lines):
	file_ranges = {}
	current = None
	for line in diff_lines:
		if line.startswith('diff --git'):
			parts = line.split()
			current = parts[3][2:]
			file_ranges.setdefault(current, [])
		elif line.startswith('@@'):
			m = re.search(r'\+(\d+)(?:,(\d+))?', line)
			if m:
				start = int(m.group(1)) - 1
				count = int(m.group(2) or '1')
				file_ranges[current].append([start, start + count - 1])
	return file_ranges

def mark_es5(lines):
	stack = []
	active = [False] * len(lines)
	for i, line in enumerate(lines):
		stripped = line.strip()
		if stripped.startswith('#if'):
			if 'NUXJS_ES5' in stripped:
				stack.append((True, True))
			else:
				stack.append((False, stack[-1][1] if stack else False))
		elif stripped.startswith('#else'):
			if stack:
				cond, branch = stack.pop()
				if cond:
					stack.append((cond, not branch))
				else:
					stack.append((cond, stack[-1][1] if stack else False))
		elif stripped.startswith('#elif'):
			if stack:
				cond, branch = stack.pop()
				stack.append((cond, False if cond else stack[-1][1] if stack else False))
		elif stripped.startswith('#endif'):
			if stack:
				stack.pop()
		active[i] = any(c and b for c, b in stack)
	return active

def insert_guards(path, ranges):
	file_path = Path(path)
	lines = file_path.read_text().splitlines(True)
	offset = 0
	for start, end in sorted(ranges):
		start += offset
		end += offset
		active = mark_es5(lines)
		if all(active[i] for i in range(start, end + 1)):
			continue
		indent = re.match(r'\t*', lines[start]).group(0)
		guard_indent = indent[:-1] if len(indent) > 0 else ''
		lines.insert(start, f"{guard_indent}#if (NUXJS_ES5)\n")
		lines.insert(end + 2, f"{guard_indent}#endif\n")
		offset += 2
	file_path.write_text(''.join(lines))

def main():
	root = Path(__file__).resolve().parent.parent
	os.chdir(root)
	diff_lines = git_diff_paths()
	for path, ranges in parse_ranges(diff_lines).items():
		insert_guards(path, ranges)

if __name__ == '__main__':
	main()
