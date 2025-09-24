# Opcode layout pipeline

The `tools/opcode_layout_pipeline.js` helper automates the full opcode-layout workflow. It rebuilds NuXJS (unless `--skip-build` is supplied), records a fresh dynamic opcode profile, generates greedy and annealed layout candidates, benchmarks each configuration, and produces human-readable summaries alongside raw artifacts.

## Prerequisites
- Start from a clean Git worktree; the script refuses to run otherwise unless `--allow-dirty` is provided.
- Ensure the benchmark harness can execute locally. The helper automatically drives `externals/PikaCmd/PikaCmd` and the existing analysis scripts.

## Typical usage
```bash
node tools/opcode_layout_pipeline.js --label 2025-09-30-layout --profile-runs 1 \
        --experiment-runs 4 --experiment-iterations 3
```

The command above writes artifacts into `docs/opcode_profiles` prefixed with the chosen label. When no label is specified the tool derives one from the current timestamp. Use `--output-dir` to place results elsewhere (relative paths are resolved from the repository root).

## Key options
- `--profile-tests` / `--experiment-tests` let you focus on specific benchmarks using the same glob syntax accepted by the harness.
- `--no-anneal` disables simulated annealing; only the greedy Pettis–Hansen layout is generated.
- `--anneal-iterations`, `--anneal-start`, and `--anneal-end` tweak the annealing schedule if you need a longer or shorter search.
- `--build` forwards the build mode to `run_opcode_layout_experiment.js`. The default `full` mode rebuilds all binaries; pass `nujs` for faster inner-loop testing.
- `--skip-build` is useful when you have already rebuilt the interpreter before invoking the pipeline.

Run `node tools/opcode_layout_pipeline.js --help` to inspect the complete flag list and defaults.

## Generated artifacts
For a label `example`, the pipeline produces the following files inside the output directory:

| Artifact | Description |
| --- | --- |
| `example-profile.json` | Raw opcode execution counters and transition data captured from the benchmark harness. |
| `example-analysis.md` | Markdown summary of opcode hotness, top transitions, and clustering metrics. |
| `example-greedy-order.txt` / `example-anneal-order.txt` | Canonical opcode orders discovered by the greedy pass and simulated annealing. |
| `example-greedy-rewrite.js` / `example-anneal-rewrite.js` | Rewrite scripts that reorder `Processor::innerRun` to match the proposed layouts. |
| `example-experiments.json` | Raw output from `run_opcode_layout_experiment.js`, including per-iteration benchmark logs. |
| `example-summary.md` | Statistical comparison of baseline versus reordered layouts derived from the experiment JSON. |

All artifacts remain stable across runs, enabling future opcode changes to be measured against historical data without manual orchestration.
