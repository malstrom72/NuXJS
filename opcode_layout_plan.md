# Opcode Layout Optimization Plan

This plan describes the instrumentation, analysis, search, and validation work needed to evaluate whether reordering the interpreter's opcode cases can improve performance through better instruction-cache locality.

## 1. Quantify dynamic opcode behaviour
- [x] Instrument `Processor::innerRun` (or extend the opcode-report tooling) to increment per-opcode execution counters and `(current, next)` transition counts during real workloads.
- [x] Guard the counters with the interpreter lock (or another thread-safety mechanism) so concurrent VMs cannot corrupt statistics.
- [x] Add a runtime toggle (CLI flag or environment variable) to enable or disable instrumentation and prevent overhead in release builds.
- [x] Teach the benchmark harness to dump the collected counters in a machine-readable format (JSON or CSV) when runs finish.
- [x] Execute the full benchmark suite (start with one run per test) under instrumentation and archive the resulting profiles for repeatability (see `docs/opcode_profiles/2025-09-23-benchmark.json`).

## 2. Model the layout optimisation problem
- [ ] Build a script that ingests the dynamic opcode report and constructs a weighted directed graph whose nodes are handlers and whose edge weights are observed transition counts.
- [ ] Normalise edge weights into probabilities (edge weight ÷ source opcode executions) so hotness comparisons are meaningful across handlers.
- [ ] Identify the hottest opcodes and top transitions to prioritise during clustering.
- [ ] Emit summaries—hotness rankings, transition matrices, and optional Graphviz renders—to guide manual inspection.

## 3. Search for improved opcode orderings
- [ ] Implement a greedy Pettis–Hansen-style clustering pass that seeds with the hottest opcode and repeatedly appends the most likely unseen successor.
- [ ] Allow clusters to merge whenever doing so increases the total in-block transition weight.
- [ ] Add optional metaheuristics (simulated annealing or integer programming) seeded with the greedy result to explore alternative layouts and escape local optima.
- [ ] Produce candidate opcode orders accompanied by their estimated cost/benefit metrics.
- [ ] Generate diffs or scripts that rewrite `Processor::innerRun` for each candidate to simplify experimentation.

## 4. Validate performance statistically
- [ ] Automate rebuilding the interpreter for each candidate ordering.
- [ ] Run the benchmark harness for both baseline and reordered interpreters with enough iterations (dozens of runs per workload) to capture stable timing distributions.
- [ ] Record raw timing data and compute summary statistics (mean, median, variance) for every workload.
- [ ] Apply statistical tests (e.g., Welch's t-test or bootstrap confidence intervals) to compare baseline and reordered timings, flagging statistically significant deltas.
- [ ] Aggregate wins and regressions across the suite to judge net impact.
- [ ] Document the methodology, captured data, and conclusions in a dedicated report.
- [ ] Integrate profiling, search, and validation into an automated pipeline so future opcode changes can be re-evaluated quickly.
