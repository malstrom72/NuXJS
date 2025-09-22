# Handling Lone Surrogates in NuXJS Strings

This plan outlines four potential remediation strategies for the regression where unmatched UTF-16 surrogates provoke assertion failures (and out-of-bounds reads in release builds) when the engine formats error messages.

## Approach 1 – Adopt WTF-8 style encoding for guest-facing UTF-8
- **Idea:** Update `String::toUTF8String()` (and related helpers) to emit three-byte UTF-8 sequences for any lone surrogate, mirroring the "WTF-8" convention used by V8 and SpiderMonkey. Maintain asserts only for structurally impossible cases (e.g., buffer overruns).
- **Pros:**
  - Preserves round-tripping: converting a JavaScript string to UTF-8 and back yields the original code units, including unmatched surrogates.
  - Matches de facto behavior of other engines, keeping interop with fuzzers and host embeddings that expect Node/V8 semantics.
  - Minimal API surface changes; only the transcoding routine needs modifications.
- **Cons / Risks:**
  - Generated UTF-8 sequences are non-standard, so external consumers expecting strict Unicode may reject them.
  - Existing host integrations might implicitly rely on `toUTF8String()` producing well-formed Unicode, so documentation and possibly call sites must be audited.

## Approach 2 – Provide a lossy conversion variant for diagnostics
- **Idea:** Retain the current strict converter for host APIs but introduce `String::toUTF8StringLossy()` (used by error formatting) that replaces isolated surrogates with U+FFFD. Update `ScriptException` and similar paths to call the lossy helper and drop assertions there.
- **Pros:**
  - Guarantees diagnostics never crash, even with adversarial input.
  - Keeps `toUTF8String()` behavior intact for embedders that depend on strict Unicode.
  - Straightforward to implement and document.
- **Cons / Risks:**
  - Error messages will differ from the offending source string, which can hinder debugging.
  - Divergent code paths raise maintenance burden; callers must consciously pick strict vs. lossy conversions.

## Approach 3 – Track string well-formedness metadata
- **Idea:** Extend the `String` representation with a `bool hasUnpairedSurrogates` (or tri-state) flag maintained by constructors and mutators. `toUTF8String()` consults the flag: when `false` it proceeds as today; when `true` it either executes the lossy path or throws a recoverable exception instead of asserting.
- **Pros:**
  - Provides fast-path for the common case (well-formed strings) without rescanning buffers.
  - Enables policy decisions at call sites (e.g., host APIs could reject, diagnostics could degrade gracefully).
  - Creates infrastructure for future features (e.g., validation hooks, debug warnings).
- **Cons / Risks:**
  - Requires auditing every string creation and mutation site to set/propagate the flag correctly.
  - Adds memory overhead to each `String` instance.
  - Bugs in flag propagation could reintroduce the same class of crash in a subtler form.

## Approach 4 – Normalize storage to UTF-32 internally
- **Idea:** Refactor the engine's `String` storage to keep code points (32-bit units) instead of UTF-16. Accept UTF-16 inputs by decoding surrogates during construction; lone surrogates become distinct code points (e.g., stored in the 0xD800–0xDFFF range). All transcoding routines iterate per code point and can explicitly encode lone surrogates without peeking ahead.
- **Pros:**
  - Eliminates reliance on two-code-unit lookahead throughout the string library, simplifying iterators.
  - Future proofs against other surrogate-related bugs (e.g., indexing, slicing).
  - Makes additional Unicode-aware features (normalization, case folding) easier to implement.
- **Cons / Risks:**
  - Large refactor touching many subsystems (GC layout, serializers, JS<->native API), with significant performance and memory implications.
  - Requires revisiting ABI boundaries where `Char*` is exposed.
  - Longer timeline; not suitable for a quick regression fix but may be part of a long-term modernization effort.
