# Test262 Dashboard

The Test262 dashboard is an optional developer utility for running and summarizing the ECMAScript 3 subset of the Test262 suite against NuXJS.

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
- NuXJS targets ES3. The bundled Test262 snapshot is the newest version compatible with ES3 engines; newer releases assume ES5+ semantics and a different harness.
