# Fix options for assigning objects with `valueOf()` to `.length`

NuXJS currently coerces array length writes by calling `Value::toDouble()`, which returns `NaN` for objects, so assigning an object that only supplies a `valueOf()` implementation triggers the length range guard instead of using the object's primitive value.【F:src/NuXJS.cpp†L1754-L1760】【F:src/NuXJS.cpp†L753-L758】 Because the virtual machine is designed to run asynchronously and only advance when the host invokes `Processor::run(maxCycles)`, any fix must convert the incoming value without blocking the client thread.【F:docs/NuXJS Documentation.md†L107-L110】【F:src/NuXJS.cpp†L2551-L2558】 Below are eight implementation strategies that keep the host in control of scheduling while making `.length` honor `valueOf()`. Each option is expanded with implementation considerations, plus a summary table for quick comparison.

| Solution | Brief pros | Brief cons |
| --- | --- | --- |
| Emit array-length opcode | Keeps fix localized to compiler/runtime boundary; reuses existing async coercion helper | Requires compiler work for dot/bracket writes and careful guarding for non-arrays |
| `Array.prototype.length` setter | Uses existing JS conversion machinery; works without interpreter changes | Alters observable property descriptor; needs new native bridge |
| Two-phase `SET_PROPERTY_OP` | No compiler changes; native enforcement remains centralized | Interpreter path gains new reentrancy bookkeeping |
| Async `ToNumber` service | Reusable for other native callers; keeps arrays untouched | Introduces new suspend/resume contract across native code |
| Rewrite to support helper | Keeps interpreter simple; conversion happens in script land | All compiler-generated writes flow through helper, changing host-observed behavior |
| Buffer in `Object::setProperty` | Centralized fix covering host API writes too | Complex state management to avoid leaks on exceptions |
| Deferred-length sentinel | Fast path unchanged for primitives; conversion happens lazily | Every length consumer must be audited to resolve sentinel |
| Per-instance accessors | Limits change to dictionary-mode arrays; setter can be shared | Adds accessor installation cost and exposes setter to reflection |

## Solution 1 – Emit a dedicated array-length coercion opcode

1. Extend the compiler to recognize property writes whose key literal is `"length"` and emit a new opcode (for example, `SET_ARRAY_LENGTH_OP`) instead of the generic `SET_PROPERTY_OP` once the base reference and RHS value are on the stack.【F:src/NuXJS.cpp†L2527-L2538】【F:src/NuXJS.h†L1521-L1539】 This involves updating both the AST lowering and the bytecode serializer, plus the constant folding that determines when the key is statically known.
2. Implement the opcode so it first executes the existing `OBJ_TO_NUMBER_OP` helper if the value on top of the stack is an object. The helper already jumps out of the interpreter loop after scheduling `support.toPrimitiveNumber`, so the client can continue calling `run(maxCycles)` until the conversion completes; the opcode therefore only needs to plug into the same suspension points that `SET_PROPERTY_OP` already supports for getters.【F:src/NuXJS.cpp†L2551-L2558】【F:src/stdlib.js†L111-L124】
3. Once the value is numeric, run the current range checks and call `JSArray::updateLength` as today, ensuring any fractional or out-of-range result still throws synchronously. This reuses the existing `RangeError` paths and requires no new exception plumbing.【F:src/NuXJS.cpp†L1754-L1760】

**Pros.**
- The fix stays localized to compiler lowering and one interpreter opcode, keeping the change set mechanically contained.
- Relies entirely on runtime paths that already cooperate with asynchronous coercion, so no new scheduler hooks are required.

**Cons.**
- Both dot and bracket assignments plus destructuring emit different front-end patterns, so auditing every compiler entry point is non-trivial.
- Additional guards must prevent the opcode from handling non-array objects with a `length` property, otherwise host-defined classes could observe a silent behavior change.

## Solution 2 – Wrap `Array.prototype.length` with a standard-library setter

1. In `stdlib.js`, define a setter on `Array.prototype.length` that invokes `support.toPrimitiveNumber(value)` before writing back, so JavaScript code handles `valueOf()` calls within the VM's cooperative scheduling model.【F:src/stdlib.js†L111-L124】 This setter must be declared during bootstrap to ensure even host-created arrays pick it up.
2. Introduce a small native helper (e.g., `support.setArrayLength(array, newLength)`) that calls through to `JSArray::updateLength`, letting the setter re-use the existing range enforcement implemented in C++. The helper should surface the same exceptions as the current path so embedders do not need to special-case setter calls.【F:src/NuXJS.cpp†L1754-L1760】
3. Update the bootstrap list so the helper is registered alongside the existing support functions, keeping the setter purely JavaScript while the heavy lifting stays native. The initialization order must ensure the setter is installed before user code runs.【F:src/NuXJS.cpp†L5024-L5227】

**Pros.**
- Leverages the existing `support.toPrimitiveNumber` promise-based machinery without any interpreter modifications.
- Keeps most logic in JavaScript, which is easier to iterate on and naturally respects the VM's cooperative scheduling contract.

**Cons.**
- `Array.prototype.length` currently appears as a data property; switching to an accessor changes observable descriptors and may break code that snapshots property metadata.
- The native helper becomes part of the public bootstrap surface, so embedders must ship an updated runtime to stay compatible.

## Solution 3 – Teach `SET_PROPERTY_OP` to perform a two-phase length write

1. Modify the interpreter's `SET_PROPERTY_OP` handler to detect `JSArray` targets whose key is the canonical `length` string and whose value is an object.【F:src/NuXJS.cpp†L2527-L2538】 The detection needs to cover both fast property strings and dictionary lookups so that hidden-class transitions still take the path.
2. When that pattern is seen, push a small frame describing the pending write and trigger `OBJ_TO_NUMBER_OP` manually, then `return` from `innerRun` so the caller regains control while the value is being coerced. The frame must include enough state to resume correctly even if another suspension or exception happens during conversion.【F:src/NuXJS.cpp†L2551-L2558】
3. After `OBJ_TO_NUMBER_OP` finishes (i.e., on the next `run` iteration), complete the buffered assignment by calling into `JSArray::setOwnProperty` with the converted primitive, reusing the existing length validation path. Cleanup must run in both success and error cases to prevent stale buffers.【F:src/NuXJS.cpp†L1754-L1760】

**Pros.**
- Avoids front-end changes and keeps all behavior in the interpreter, minimizing surface area.
- Preserves existing native `JSArray::setOwnProperty` semantics so host APIs continue to observe consistent behavior.

**Cons.**
- The interpreter path acquires additional reentrancy states, increasing the complexity of `innerRun` and the risk of bugs when multiple async operations are pending.
- Any mistakes in the resume bookkeeping could leak stack frames or replay assignments incorrectly after exceptions, which would be difficult to debug.

## Solution 4 – Add an asynchronous `ToNumber` service for native code

1. Introduce a `Runtime::coerceToNumberAsync(Value& slot)` helper that native subsystems can call. If `slot` already holds a primitive, the helper returns immediately; otherwise it arranges for the active processor to execute `OBJ_TO_NUMBER_OP` with `slot` as the destination and yields control to the host, mirroring how existing bytecodes queue conversions.【F:src/NuXJS.cpp†L2551-L2558】 This helper needs to integrate with the VM's resume stack to know which continuation to revive.
2. Update `JSArray::setOwnProperty` so it calls the helper before performing range validation. The function would detect the yielded state (e.g., via a boolean return) and stop the setter early, letting the interpreter retry once the conversion completes. All callers of `setOwnProperty` must be audited so they can propagate the "come back later" signal without duplicating work.【F:src/NuXJS.cpp†L1754-L1760】
3. Ensure the retry path re-enters `setOwnProperty` with the primitive result, keeping the validation and `updateLength` call unchanged, and propagate any pending exceptions thrown during conversion back to JavaScript code. This requires a small state machine so repeated retries do not re-trigger the conversion.

**Pros.**
- Creates a general-purpose mechanism that other native entry points (e.g., numeric typed array setters) could reuse for async-friendly coercions.
- Keeps arrays on the same fast paths until conversion is actually needed, minimizing steady-state overhead.

**Cons.**
- Adds a new suspend/resume protocol to native code, so every caller must understand the helper's two-phase contract to avoid running twice.
- Requires touching many call sites to thread through the retry signal, which is both time-consuming and easy to miss.

## Solution 5 – Rewrite `.length` assignments to call a support helper

1. Extend the compiler's assignment handling so property writes with a literal `length` key emit a specialized lowering instead of the generic `SET_PROPERTY_OP`, reusing the existing hooks where property l-values are recognized.【F:src/NuXJS.cpp†L3290-L3296】【F:src/NuXJS.cpp†L3690-L3702】 This requires updating both expression and pattern assignments so destructuring and compound assignments stay consistent.
2. Have that lowering load a `support.setArrayLength` helper and invoke it with `CALL_METHOD_OP`, letting the helper execute as ordinary script code that may yield back to the host while conversions run.【F:src/NuXJS.cpp†L2631-L2643】【F:src/NuXJS.cpp†L5024-L5227】 The emitted bytecode must also arrange the stack to pass the array, value, and possibly receiver consistently across code paths.
3. Implement the helper so it awaits `support.toPrimitiveNumber(value)` before delegating to `JSArray::updateLength`, reusing the existing range guard after the asynchronous conversion finishes.【F:src/stdlib.js†L111-L124】【F:src/NuXJS.cpp†L1754-L1760】 The helper should wrap the native call in `try`/`catch` (in JS) if it needs to normalize exceptions.

**Pros.**
- Leaves the interpreter unchanged, which reduces the risk of destabilizing bytecode execution or reentrancy semantics.
- Since the helper is JavaScript, NuXJS embedders can override or patch it without rebuilding the VM if their host integration needs special handling.

**Cons.**
- Every compiler entry point that emits property writes—including inline caches and destructuring initializers—must be updated to route through the helper, making the change broad in scope.
- Redirecting writes through JavaScript changes observable call stacks and triggers host interceptors (like proxies) differently, which some embedders may rely on today.

## Solution 6 – Buffer array-length writes inside `Object::setProperty`

1. Update `Object::setProperty` to detect when a `JSArray` receives a `length` key whose value is an object, deferring the native write rather than calling `JSArray::setOwnProperty` immediately.【F:src/NuXJS.cpp†L1364-L1375】【F:src/NuXJS.cpp†L1754-L1760】 The detection logic needs to work for both symbol and string keys and respect property flags so proxies still trap correctly.
2. When that pattern is seen, stash the target/value in a pending record and trigger `OBJ_TO_NUMBER_OP` so the interpreter yields to the host while `support.toPrimitiveNumber` runs, just as other object-to-number conversions do today.【F:src/NuXJS.cpp†L2551-L2558】【F:src/NuXJS.cpp†L2475-L2589】 The pending record must be stored on the runtime or stack so nested writes do not overwrite it.
3. Once the processor resumes with the primitive result, replay the buffered assignment through the existing setter path, clearing the pending record even if the range check raises a `RangeError`. Additional cleanup hooks should run when an exception unwinds the stack to avoid retaining references.【F:src/NuXJS.cpp†L2527-L2539】【F:src/NuXJS.cpp†L1754-L1760】

**Pros.**
- Centralizes the fix so every code path that funnels through `setProperty` (including host API writes and `Reflect.set`) benefits automatically.
- Keeps all logic inside the native object model, so no bytecode or JavaScript code needs to change.

**Cons.**
- Introduces new reentrancy states inside `Object::setProperty`, meaning exception safety and nested writes need rigorous testing.
- Pending-record bookkeeping increases the risk of memory leaks or use-after-free bugs if the conversion throws or the object is GC'd while deferred.

## Solution 7 – Store a deferred-length sentinel and resolve lazily

1. Allow `JSArray::length` to hold a sentinel pointing at the original object value when an assignment supplies an object, rather than forcing an immediate numeric conversion.【F:src/NuXJS.cpp†L1659-L1678】【F:src/NuXJS.cpp†L1690-L1699】 The sentinel can be a tagged pointer or dedicated enum so garbage collection knows the array still references the object.
2. Introduce a `resolveLength(Runtime&)` helper that `setElement`, `sliceDenseVector`, `updateLength`, and other entry points call before relying on `length`, so any pending sentinel is resolved first.【F:src/NuXJS.cpp†L1703-L1712】【F:src/NuXJS.cpp†L1715-L1742】【F:src/NuXJS.cpp†L1665-L1678】 This requires auditing every hot path that reads `length`, including iterator helpers and host API accessors.
3. Have `resolveLength` schedule `OBJ_TO_NUMBER_OP` when it encounters the sentinel, yielding until the conversion finishes and only then overwriting the cached `length` with the validated integer result.【F:src/NuXJS.cpp†L2551-L2558】【F:src/NuXJS.cpp†L1754-L1760】 The helper must also handle cases where the conversion throws so the sentinel is cleared and the exception surfaces correctly.

**Pros.**
- Keeps array writes and typical reads fast for primitive inputs because the sentinel path is only taken for object assignments.
- Defers work until code actually observes the `length`, which may avoid needless conversions if the property is overwritten again before being read.

**Cons.**
- Every call site that touches `length` must remember to invoke `resolveLength`, so the audit surface is large and future contributors might miss new entry points.
- Adding sentinel states to `JSArray` complicates the garbage collector and serialization code, which must learn to handle deferred references safely.

## Solution 8 – Install per-instance accessors during array materialization

1. Populate `JSArray::constructCompleteObject` with an accessor descriptor for `length`, so arrays that transition to dictionary mode expose a setter implemented in either native C++ or `stdlib.js` glue code.【F:src/NuXJS.cpp†L1703-L1712】【F:src/NuXJS.cpp†L1774-L1774】 The accessor must be wired into the prototype templates so both prebuilt and runtime-created arrays adopt it consistently.
2. Implement the setter so it queues `support.toPrimitiveNumber(value)` before invoking `JSArray::updateLength`, ensuring the conversion executes under the interpreter's cooperative scheduling model.【F:src/stdlib.js†L111-L124】【F:src/NuXJS.cpp†L1754-L1760】 The setter can live in C++ or JavaScript but needs to handle reentrancy if the conversion triggers user-defined code.
3. Register the accessor helper alongside the existing support functions so it is available whenever a complete array object is created or materialized from a template.【F:src/NuXJS.cpp†L5024-L5227】【F:src/NuXJS.cpp†L1846-L1854】 Template cache invalidation must also be considered so existing instances pick up the accessor.

**Pros.**
- Limits behavioral changes to arrays that actually expose their `completeObject`, leaving dense fast arrays untouched until they need dictionary semantics.
- The accessor can be shared across other host objects that want the same coercion behavior, making the code reusable.

**Cons.**
- Accessor installation slightly increases the cost of promoting arrays to dictionary mode and may surface the setter to reflective code that inspects property descriptors.
- Requires updating template instantiation and cache invalidation so partially constructed arrays do not end up with inconsistent descriptors.
