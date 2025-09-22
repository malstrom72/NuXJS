# Handling Lone Surrogates in NuXJS Strings

This plan outlines four potential remediation strategies for the regression where unmatched UTF-16 surrogates provoke assertion failures (and out-of-bounds reads in release builds) when the engine formats error messages.

## Approach 1 – Adopt WTF-8 style encoding for guest-facing UTF-8
- **Idea:** Update the UTF-16 → UTF-8 conversion helpers so that unmatched surrogates are encoded as the WTF-8 surrogate-tracing three-byte sequences instead of asserting. Keep defensive asserts solely for buffer boundary errors and programming mistakes.

### Detailed implementation steps
1. **Audit the call sites.** Catalogue every function that currently depends on `String::toUTF8String()` or `String::utf8Length()` (`src/runtime/String.cpp`, `src/runtime/StringBuffer.cpp`, `src/runtime/ScriptException.cpp`, and embedders in `src/api/StringRef.cpp`). Mark the handful of legacy helpers such as `JSPrinter::printString` that open-code UTF-8 emission so they can be upgraded to delegate to the centralized implementation.
2. **Extend the fast-path classifier.** In `String::utf8Length()` teach the length calculator to treat any code unit inside `[0xD800, 0xDFFF]` as a literal WTF-8 payload when it is not followed by a valid low surrogate. Add a new branch that increments the length by three bytes and advances a single code unit instead of reading `p[1]`. Make sure the routine still increments by four bytes when a well-formed surrogate pair is present.
3. **Rewrite the encoder.** Inside `String::toUTF8String()` refactor the surrogate handling block to: (a) detect whether the current code unit is a high surrogate with a matching low surrogate, (b) emit the standard four-byte UTF-8 sequence when the pair is well formed, and (c) otherwise fall back to emitting the WTF-8 literal by passing the 16-bit value through `0xE0 | (code >> 12)` / `0x80 | ((code >> 6) & 0x3F)` / `0x80 | (code & 0x3F)`. This mirrors SpiderMonkey’s `LossyConvertUtf16ToUtf8` implementation and preserves round-tripping.
4. **Handle stray low surrogates.** The current code assumes a stray `0xDC00–0xDFFF` is unreachable; add an explicit `else if (code >= 0xDC00 && code < 0xE000)` arm that emits the same three-byte WTF-8 sequence, ensuring we no longer crash on malformed input constructed via `String.fromCharCode(0xDC00)`.
5. **Share the logic.** Factor the new surrogate-aware encoding into a small inline helper (e.g., `encodeCodeUnitAsWTF8`) so auxiliary code (such as the serializer in `src/runtime/JSONSerializer.cpp` and `tests/runtime/StringBuilderTests.cpp`) can call it without duplicating the branchy logic. Adjust any manual emitters (string builder, debugger pretty-printer, REPL) to use the helper to maintain consistent semantics.
6. **Retain defensive assertions.** Replace the current surrogate asserts with descriptive debug-only `ASSERT(!isHighSurrogate(code) || i + 1 < length)` style checks that fire only if the buffer boundaries are wrong. This prevents accidental OOB reads in debug builds while allowing malformed sequences to flow through.
7. **Review buffer sizing.** Because WTF-8 treats isolated surrogates as three bytes instead of four, the existing allocation math still upper-bounds the required capacity. Nevertheless, add unit tests that exercise worst-case inputs (`"\uD800\uD800"`, `"\uDC00"`) to confirm no undersized buffers slip past the new logic.
8. **Update the embedder surface.** Search for any code that advertises `String::toUTF8String()` as returning strict Unicode (documentation in `docs/Embedding Guide.md`, API comments, public headers). Amend the wording to clarify that the result uses WTF-8 to guarantee round-tripping of ECMAScript strings.
9. **Cross-platform verification.** Build and run both the Unix (`build.sh`) and Windows (`build.cmd` under CI) targets because the code touches shared runtime pieces. Pay special attention to the MSVC build, ensuring `_MSC_VER`-gated paths in `String::toUTF8String()` compile with the new helper.
10. **Regression testing.** Augment the `tests/regression/loneSurrogateErrorMessageCrash.io` added earlier with positive cases that ensure the engine no longer asserts and that `String.fromCharCode(0xD800).toString()` round-trips. Also add a fuzzer seed that concatenates mixed valid and invalid surrogate pairs to verify we never crash while building error messages.

### Documentation and rollout checklist
- Update `docs/Unicode.md` (create it if necessary) to explain NuXJS now uses WTF-8 for host-visible UTF-8 conversions, including rationale, example encodings, and compatibility notes.
- Announce the change in `CHANGELOG.md` under a breaking-changes entry, advising embedders that guest-provided strings may contain non-standard UTF-8 sequences and that they should validate before bridging into strict-Unicode APIs.
- Coordinate with fuzzing infrastructure: regenerate the `fuzzCrashes` minimized corpus to confirm no seed now crashes, then flip the regression test from “expect crash” to “expect clean exit” before landing.

### Risk mitigation
- Because some embedders might reject WTF-8, prototype a follow-up option flag (`EngineOptions::strictUTF8`) that could restore the old behavior (but throw a recoverable exception) if external partners demand strict compliance. This is not part of the initial landing but should be documented as a contingency plan if rollout feedback surfaces issues.

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

