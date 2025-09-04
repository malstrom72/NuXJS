#!/usr/bin/env python3
import json
import subprocess
import tarfile
from collections import defaultdict
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
FAILS_FILE = ROOT / "fails"
TARBALL = ROOT / "externals" / "test262-master.tar.gz"
TEST262_DIR = ROOT / "externals" / "test262-master" / "test"
DASH_PATH = ROOT / "tools" / "testdash.json"

KEYWORDS = [
	"Symbol",
	"Proxy",
	"Reflect",
	"Map",
	"Set",
	"WeakMap",
	"WeakSet",
	"Promise",
	"Generator",
	"async",
	"await",
	"BigInt",
	"ArrayBuffer",
	"DataView",
	"Int8Array",
	"Uint8Array",
	"Uint16Array",
	"Uint32Array",
	"Float32Array",
	"Float64Array",
	"Object.defineProperty",
	"Object.defineProperties",
	"Object.getOwnPropertyDescriptor",
	"Object.getOwnPropertyDescriptors",
	"Object.setPrototypeOf",
	"Object.getPrototypeOf",
	"Object.preventExtensions",
	"Object.seal",
	"Object.freeze"
]

SPEC_MAP = {
	"Array": "§15.4",
	"Boolean": "§15.6",
	"Date": "§15.9",
	"Math": "§15.8",
	"Number": "§15.7",
	"Object": "§15.2",
	"RegExp": "§15.10",
	"String": "§15.5"
}

def ensure_test262_extracted() -> None:
	if TEST262_DIR.exists():
		return
	with tarfile.open(TARBALL, "r:gz") as tar:
		tar.extractall(TARBALL.parent)

def load_fails():
	fails = []
	with open(FAILS_FILE, encoding="utf-8") as fh:
		for line in fh:
			line = line.strip()
			if line.startswith("FAIL "):
				fails.append(line[5:])
	return fails

def feature_from_path(path: str) -> str:
	parts = path.split("/")
	if parts[0] == "built-ins" and len(parts) > 1:
		return parts[1]
	return parts[0]

def uses_non_es3_feature(test_path: Path) -> bool:
	pattern = "|".join(KEYWORDS)
	result = subprocess.run(["rg", pattern, str(test_path)], capture_output=True, text=True)
	return result.stdout != ""

def main() -> None:
	ensure_test262_extracted()
	fails = load_fails()
	with open(DASH_PATH, encoding="utf-8") as fh:
		dash = json.load(fh)
	groups = defaultdict(list)
	non_es3 = set()
	for rel in fails:
		test_file = TEST262_DIR / f"{rel}.js"
		groups[feature_from_path(rel)].append(rel)
		if test_file.exists() and uses_non_es3_feature(test_file):
			non_es3.add(rel)
	for rel in sorted(non_es3):
		if dash.get(rel, {}).get("category") != "not_es3":
			dash[rel] = {"category": "not_es3"}
	with open(DASH_PATH, "w", encoding="utf-8") as fh:
		json.dump(dash, fh, indent=4, sort_keys=True)
	print("| Feature | Spec Clause | Total | non_es3 | Remaining |")
	print("| --- | --- | ---:| ---:| ---:|")
	for feature in sorted(groups):
		tests = groups[feature]
		n_es3 = len([t for t in tests if t in non_es3])
		print(f"| {feature} | {SPEC_MAP.get(feature, '')} | {len(tests)} | {n_es3} | {len(tests) - n_es3} |")

if __name__ == "__main__":
	main()
