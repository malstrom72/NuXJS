# Legacy Exception Output Migration Plan

## Objective
Document a concrete process for regenerating modern exception expectations for every regression test that still carries `// CLI: --legacy-exceptions`, so the compatibility flag can be deleted without losing coverage.

## Milestone 1 – Establish the Baseline
- [x] Inventory the affected tests by running `rg "// CLI:.*--legacy-exceptions" -n tests`, then snapshotting the 40 flagged paths in `docs/LegacyExceptionInventory.json` for ongoing tracking.
- [x] Extend `tools/annotate_io_cli.py` (or create a companion helper) to emit the inventory as structured data (JSON or CSV) for tracking via the new `--inventory-output` and `--inventory-format` options.
- [x] Characterize the modern diagnostics format by running `tools/test.pika -e tests/regression/exceptionDiagnosticsStack.io` without the legacy flag and confirming that `output/NuXJS -s` reports the full stack trace (`Error: boom` plus the three frames) by default.
- [x] ✅ Run `timeout 180 ./build.sh` and confirm `=== ALL BUILDS AND TESTS COMPLETED SUCCESSFULLY ===` to lock in a clean baseline before changing tooling or expectations.

## Milestone 2 – Upgrade the Tooling
- [x] Add `tools/rewrite_exception_expectations.py` (or equivalent) that reuses the parsing logic from `tools/annotate_io_cli.py`.
- [x] Teach the helper to materialize temporary `.js` inputs that mirror `tools/test.pika` section boundaries.
- [x] Execute NuXJS via `subprocess.run`, forwarding all CLI arguments except `--legacy-exceptions`, and capture normalized STDOUT/STDERR.
- [x] Replace the `!` expectation blocks (and any other legacy-influenced sections) with the captured diagnostics while preserving surrounding markers.
- [x] Provide a `--check` dry-run mode that reports diffs without writing files.
- [x] ✅ After the tooling is implemented, rerun `timeout 180 ./build.sh` to validate no regressions were introduced.

## Milestone 3 – Regenerate Expectations
- [x] Prime the workspace by choosing the NuXJS binary (Debug or Release) and exposing it to the helper script, e.g. via an environment variable (`NUXJS_REWRITE_BINARY="output/NuXJS -s"`).
- [x] Drive the helper with the legacy inventory, allowing per-file skips for problematic cases (the new `--inventory`/`--skip` options wire directly into `docs/LegacyExceptionInventory.json`).
- [x] For each file, emit a `.bak` backup of the existing expectations before rewriting so a safety net exists while reviewing the diffs.
- [x] Execute NuXJS without `--legacy-exceptions` and rewrite the `.io` expectations with the modern diagnostics.
- [x] Spot-check representative syntax, runtime, and parser errors to ensure stack traces and metadata look correct (for example `tests/erroneous/notAFunction.io` and `tests/erroneous/illegalUseOfKeywords.io`).
- [x] Delete backups once confidence in the regenerated expectations is established.
- [x] Maintain an external checklist (such as `plan.md`) to record each test converted to the modern output (see `docs/LegacyExceptionConversionChecklist.md`).
- [x] ✅ Execute `timeout 180 ./build.sh` to ensure the regenerated expectations pass end-to-end.

## Milestone 4 – Final Cleanup
- [ ] Run `tools/test.pika -e <paths>` on the converted tests to confirm they succeed without the compatibility flag.
- [ ] Remove `// CLI: --legacy-exceptions` directives from the updated `.io` files.
- [ ] Delete the compatibility flag from the regression harness and CLI documentation once no tests require it.
- [ ] ✅ Perform a final `timeout 180 ./build.sh` run to certify the suite passes with modern diagnostics only.

## Risk Mitigation
- [ ] Keep incremental commits small (convert related tests together) so regressions are easy to bisect.
- [ ] Pause the migration for any test that reveals a real behavioral difference rather than formatting noise and investigate before updating expectations.
- [ ] Use the helper’s dry-run mode plus `git diff` to guard against unintended changes to non-error output sections.
