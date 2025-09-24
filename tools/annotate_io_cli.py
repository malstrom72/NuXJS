#!/usr/bin/env python3
import argparse
import csv
import io
import json
import sys
from pathlib import Path
from typing import Iterable, List


REPO_ROOT = Path(__file__).resolve().parents[1]


def collect_targets(paths: Iterable[str]) -> List[Path]:
        arguments = list(paths)
        if arguments:
                bases = [Path(p).resolve() for p in arguments]
        else:
                bases = [REPO_ROOT / 'tests']
        files = []
        for base in bases:
                if not base.exists():
                        print(f"warning: {base} does not exist", file=sys.stderr)
                        continue
                if base.is_file() and base.suffix == '.io':
                        files.append(base)
                        continue
                for path in sorted(base.rglob('*.io')):
                        files.append(path)
        return files


def wants_legacy(text: str) -> bool:
        if '! !!!!' in text:
                return True
        if '< !!!!' in text:
                return False
        if '!!!!' in text and '!!!! location' not in text and '!!!! stack' not in text:
                return True
        return False


def detect_newline(text: str) -> str:
        if '\r\n' in text:
                return '\r\n'
        return '\n'


def analyze_file(path: Path):
        original = path.read_text(encoding='utf-8')
        newline = detect_newline(original)
        had_trailing_newline = original.endswith('\n')
        lines = original.splitlines()
        cli_index = None
        existing_cli = None
        for idx, line in enumerate(lines):
                if line.startswith('// CLI:'):
                        cli_index = idx
                        existing_cli = line
                        break
        legacy_required = wants_legacy(original)
        desired = '// CLI: --legacy-exceptions' if legacy_required else '// CLI:'
        rewritten_lines = list(lines)
        if cli_index is None:
                rewritten_lines.insert(0, desired)
        else:
                rewritten_lines.pop(cli_index)
                rewritten_lines.insert(0, desired)
        rewritten = newline.join(rewritten_lines)
        if had_trailing_newline:
                rewritten += newline
        needs_update = rewritten != original
        inventory_entry = {
                'path': str(path.relative_to(REPO_ROOT).as_posix()),
                'requires_legacy': legacy_required,
                'existing_cli': existing_cli,
                'desired_cli': desired,
        }
        return inventory_entry, needs_update, rewritten


def write_inventory(entries, args):
        if not args.inventory_output:
                return
        filtered = [entry for entry in entries if entry['requires_legacy']]
        destination = args.inventory_output
        data: str
        if args.inventory_format == 'json':
                data = json.dumps(filtered, indent=2, sort_keys=True) + '\n'
        else:
                buffer = io.StringIO()
                writer = csv.DictWriter(buffer, fieldnames=['path', 'requires_legacy', 'existing_cli', 'desired_cli'])
                writer.writeheader()
                for row in filtered:
                        writer.writerow(row)
                data = buffer.getvalue()
        if destination == '-':
                sys.stdout.write(data)
        else:
                output_path = Path(destination)
                output_path.parent.mkdir(parents=True, exist_ok=True)
                output_path.write_text(data, encoding='utf-8')
                print(f"wrote inventory with {len(filtered)} entries to {output_path}")


def parse_arguments(argv: List[str]):
        parser = argparse.ArgumentParser(description='Annotate NuXJS regression .io files with // CLI directives.')
        parser.add_argument('paths', nargs='*', help='Optional .io files or directories to process.')
        parser.add_argument('--inventory-output', '-i', help='Write legacy exception inventory to this path. Use - for stdout.')
        parser.add_argument('--inventory-format', choices=('json', 'csv'), default='json', help='Structured inventory format.')
        parser.add_argument('--no-annotate', action='store_true', help='Only produce the inventory without rewriting files.')
        return parser.parse_args(argv[1:])


def main(argv):
        args = parse_arguments(argv)
        io_files = collect_targets(args.paths)
        if not io_files:
                return 0
        updated = 0
        inventory_entries = []
        for path in io_files:
                entry, needs_update, rewritten = analyze_file(path)
                inventory_entries.append(entry)
                if args.no_annotate:
                        continue
                if needs_update:
                        path.write_text(rewritten, encoding='utf-8')
                        print(f"annotated {path}")
                        updated += 1
        write_inventory(inventory_entries, args)
        if not args.no_annotate:
                print(f"Processed {len(io_files)} .io files; updated {updated}.")
        return 0


if __name__ == '__main__':
        sys.exit(main(sys.argv))
