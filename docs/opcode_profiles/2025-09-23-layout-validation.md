# Opcode layout validation – 2025-09-23

## Methodology
- Used `tools/run_opcode_layout_experiment.js` with the new `--build nujs`, `--tests`, and `--allow-dirty` options to accelerate rebuilds and focus on specific benchmarks. Baseline builds rebuild the release interpreter via `bash tools/BuildCpp.sh release native ./output/NuXJS tools/NuXJSREPL.cpp src/NuXJS.cpp src/stdlibJS.cpp` before every batch of runs.【F:tools/run_opcode_layout_experiment.js†L1-L220】
- Captured four targeted workloads that exercise the hottest opcode transitions (`bigArray`, `bigObject`, `chess_bm`, `navierStokes_bm`). `bigArray` used 6 runs × 4 iterations (24 samples); the remaining workloads used 4 runs × 3 iterations (12 samples) to keep turnaround manageable.
- Saved raw harness output for every workload/candidate pair as JSON (`docs/opcode_profiles/2025-09-23-layout-*.json`).【F:docs/opcode_profiles/2025-09-23-layout-bigArray.json†L1-L63】【F:docs/opcode_profiles/2025-09-23-layout-bigObject.json†L1-L63】【F:docs/opcode_profiles/2025-09-23-layout-chess_bm.json†L1-L63】【F:docs/opcode_profiles/2025-09-23-layout-navierStokes_bm.json†L1-L63】
- Added `tools/analyze_opcode_layout_results.js` to parse experiment artifacts, compute descriptive statistics, and run Welch’s t-tests when both candidates complete successfully. The script emits Markdown summaries for reporting.【F:tools/analyze_opcode_layout_results.js†L1-L221】

## Results
The aggregated summary lives in `docs/opcode_profiles/2025-09-23-layout-summary.md`. Key observations:

| Benchmark | Runs (baseline / anneal) | Mean Δ | Welch p-value | Notes |
| --- | --- | --- | --- | --- |
| `bigArray` | 24 / 24 | -0.019 s (-1.08 %) | 0.365 | No statistically significant change; anneal is slightly faster but well within noise.【F:docs/opcode_profiles/2025-09-23-layout-summary.md†L1-L9】 |
| `bigObject` | 12 / 12 | -0.0029 s (-0.07 %) | 0.969 | No meaningful difference; distributions overlap heavily.【F:docs/opcode_profiles/2025-09-23-layout-summary.md†L12-L20】 |
| `chess_bm` | 12 / 0 | — | — | Anneal layout segfaulted immediately; baseline data retained for reference.【F:docs/opcode_profiles/2025-09-23-layout-summary.md†L22-L30】 |
| `navierStokes_bm` | 12 / 0 | — | — | Anneal layout segfaulted immediately; baseline data retained.【F:docs/opcode_profiles/2025-09-23-layout-summary.md†L32-L40】 |

The two high-throughput array/object microbenchmarks show no statistically significant speed-up from the annealed layout, while the long-running control-flow workloads (`chess_bm`, `navierStokes_bm`) crash when the annealed handler order is installed. That failure mode matches the harness output in the raw JSON files, which report a segmentation fault before any timing samples are recorded.【F:docs/opcode_profiles/2025-09-23-layout-chess_bm.json†L38-L61】【F:docs/opcode_profiles/2025-09-23-layout-navierStokes_bm.json†L38-L63】 

## Next steps
- Investigate the crash introduced by the annealed order on control-flow heavy workloads before considering further performance tuning.
- Expand coverage to the full benchmark suite once the reordered switch is stable—today’s workflow exercised only the hottest adjacency chains to keep iteration times reasonable.
- Integrate the new analysis script into the opcode search pipeline so candidates automatically receive statistical evaluation alongside profiling reports.
