# Opcode Layout Optimization Plan

This plan describes the instrumentation, analysis, search, and validation work needed to evaluate whether reordering the interpreter's opcode cases can improve performance through better instruction-cache locality.

## 1. Quantify dynamic opcode behaviour
- **Goal:** Record how often each opcode executes and how frequently opcodes follow one another while running representative workloads.
- **Instrumentation tasks:**
  - Extend `Processor::innerRun` (or augment the existing opcode-report tooling) to increment per-opcode execution counters and transition counts keyed by `(current, next)` opcode pairs.
  - Ensure counters are thread-safe or guarded by the interpreter lock so concurrent VMs cannot corrupt the statistics.
  - Add command-line flags or environment variables to enable and disable instrumentation to avoid perturbing release builds.
- **Data capture:**
  - Augment the benchmark harness to dump the collected counts in a machine-readable format (JSON or CSV) once execution completes.
  - Run the full benchmark suite (one run per test initially) with instrumentation enabled and archive the resulting profiles for repeatability.

## 2. Model the layout optimisation problem
- **Goal:** Convert the dynamic profile into a graph representation suitable for code-placement algorithms.
- **Processing tasks:**
  - Build a script that consumes the opcode execution report and constructs a weighted directed graph where nodes represent opcode handlers and edge weights equal observed transition frequencies.
  - Normalise weights into probabilities (edge weight / source node execution count) to facilitate comparisons across opcodes with different hotness.
  - Identify the hottest opcodes and top transitions to prioritise during clustering.
- **Output:**
  - Emit summaries such as per-opcode hotness rankings, transition matrices, and visualisations (e.g., Graphviz) to guide manual inspection.

## 3. Search for improved opcode orderings
- **Goal:** Automatically propose switch-case permutations that keep hot transitions contiguous.
- **Algorithm tasks:**
  - Implement a greedy Pettis–Hansen-style clustering pass that begins with the hottest opcode and iteratively appends the most probable successor not yet placed.
  - Allow clusters to merge when doing so increases the total covered transition weight within the same block.
  - Add optional metaheuristics (simulated annealing or integer programming) seeded with the greedy result to explore alternative layouts and escape local optima.
- **Deliverables:**
  - Produce candidate opcode orders along with their estimated cost/benefit metrics.
  - Generate diffs or scripts that rewrite `Processor::innerRun` according to each candidate for easy experimentation.

## 4. Validate performance statistically
- **Goal:** Determine whether proposed orderings deliver repeatable speedups.
- **Benchmarking tasks:**
  - Automate rebuilding the interpreter for each candidate ordering.
  - Run the benchmark harness for both baseline and reordered builds with enough iterations (dozens of runs per workload) to gather stable timing distributions.
  - Capture raw timing data and compute summary statistics (mean, median, variance) for each workload.
- **Analysis tasks:**
  - Apply statistical tests (e.g., Welch's t-test or bootstrap confidence intervals) to compare baseline vs. reordered timings and quantify confidence levels.
  - Flag changes that are statistically significant and aggregate wins/regressions across the suite.
- **Reporting:**
  - Document the methodology, data, and conclusions in a dedicated report.
  - Integrate the profiling, search, and validation steps into an automated pipeline so future opcode changes can be re-evaluated quickly.
