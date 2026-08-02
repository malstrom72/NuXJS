# Test262 Dashboard

The Test262 dashboard is an optional developer utility for running and summarizing the ECMAScript 5.1 subset of the Test262 suite against NuXJS.

## What counts as in scope

Test262 states the edition each test was written against in the test's own frontmatter: `es5id` is an ES5.1 test,
while `es6id` and the unversioned `esid` are newer. The dashboard reads that and ignores anything past the target
edition, so the out-of-scope bucket is derived rather than recorded. `tools/testdash.json` therefore holds only
the calls a human made:

- `BAD TEST` - the test itself is wrong.
- `BY DESIGN` - NuXJS deliberately differs.
- `ES >5.1` - out of scope, but the frontmatter does not say so (58 tests carry no edition id).
- `TBD` / `TODO` - triaged, not yet resolved.

Retargeting to a later edition is the `TARGET` object at the top of `tools/testdash.node.js`.

## Test262 Suite Layout

- The Test262 archive lives at `externals/test262-master.tar.gz`.
- On first use, the dashboard extracts the archive to `externals/test262-master/` automatically.
- You can unpack it manually if desired:
  ```bash
  tar -xzf externals/test262-master.tar.gz -C externals
  ```

## Running the Dashboard

- Start the dashboard server (opens a browser):
  ```bash
  node tools/testdash.node.js
  ```
- Run headless CLI mode:
  ```bash
  node tools/testdash.node.js --cli
  ```
- Include ignored categories in the CLI summary:
  ```bash
  node tools/testdash.node.js --cli --include-ignored
  ```
- Reset the category for all passing tests (ignored tests included; failures untouched):
  ```bash
  node tools/testdash.node.js --cli --reset-passed
  ```
- Pick the engine explicitly. Otherwise the newest `output/NuXJS_es5_*` build wins, falling back to the ES3 names:
  ```bash
  node tools/testdash.node.js --cli --engine=./output/NuXJS_es5_release_native
  ```
- Include the strict-mode runs. `test262.py` is invoked with `--non_strict_only` by default, which skips the 482
  `onlyStrict` tests outright; strict mode is an ES5.1 feature, so a real conformance number needs this:
  ```bash
  node tools/testdash.node.js --cli --include-strict
  ```

## Python 2 Requirement

The Test262 harness expects Python 2. Use the provided shim to avoid system-wide installs:

- Install the shim:
  ```bash
  bash tools/setupPython2.sh
  ```
- Add it to the current shell `PATH`:
  ```bash
  export PATH="$HOME/.local/bin:$PATH"
  ```
  The script appends this to `~/.zshrc`/`~/.bashrc` for future shells.
- Verify the shim:
  ```bash
  python2 -V
  ```
- For a one-off run without editing `PATH`:
  ```bash
  PATH="$HOME/.local/bin:$PATH" node tools/testdash.node.js --cli
  ```

### Platform Notes

- **Apple Silicon**: Python 2 packages are x86_64-only. The setup script creates an `osx-64` conda environment that runs under Rosetta 2. Install Rosetta if needed:
  ```bash
  softwareupdate --install-rosetta --agree-to-license
  ```
- **Windows**: Use `tools/setupPython2.cmd` (wraps the bash script) and run the Node commands in a shell where `python2` resolves.

## Additional Notes

- The dashboard auto-extracts the Test262 archive if the extracted folder is missing.
- The bundled Test262 snapshot is the newest version that still ships the Python 2 harness; newer releases need a different one. It predates ES6, so its `es5id` set is the ES5.1 suite proper: 11820 of its 16485 tests.
