TODO
####

Run-time
========

	* 8.12.5 (found 2026-09-19, es5 only, review): an array element store never consults the prototype chain, so an inherited setter never runs, an inherited read-only element is overwritten, and a strict store never throws. JSArray::updateOwnProperty shares setOwnPropertyInternal with setOwnProperty, so the VM's pre-[[CanPut]] fast path CREATES the element (and bumps length) and always reports success; putThrough / Object::setProperty is never reached.
		- `Object.defineProperty(Array.prototype, "7", { set: function (v) { log += v }, configurable: true }); var a = []; a[7] = 3` -> the setter never runs, `a` gains an own "7" and length 8. V8: setter runs, no own property, length stays 0. Same for a hole strictly inside length. The strict form silently succeeds where V8 throws a TypeError. A plain object with the identical shape behaves correctly, so this is JSArray alone.
		- tests/unconforming/readOnlyNumericProps.io blesses the read-only *data* half ("isn't a part of Ecmascript 3 standard"), which stops being true under es5; inherited accessors are a new ES5 case and are neither documented nor tested. Fixing this means moving that test to tests/es3only/ with an es5 twin asserting 456, adding the inherited-accessor case, and moving the "numeric property can shadow a read-only prototype property" bullet in docs/NuXJS Documentation.md from the shared deviations to es3 only.
		- the fix is small but costly. Making updateOwnProperty refuse to create (dense hit updates in place, sparse goes to completeObject->updateOwnProperty, everything else falls through) is correct and ALSO removes the duplicate-getOwnPropertyNames entry below, but every append then walks the chain: measured bigArray 1.22 -> 2.13s and lz4_bm_1 0.47 -> 2.23s. Two causes: three hash lookups per append, and LazyJSObject::getOwnProperty calling getCompleteObject unconditionally, which allocates a table per array just to miss in it (bigArray memory 100 -> 167 MiB).
		- the materializing miss is worth fixing on its own and carries no invariant: JSArray::constructCompleteObject is a no-op, so for an array a null completeObject really does mean "no properties". An early `if (completeObject == 0) return NONEXISTENT;` in JSArray::getOwnProperty took lz4_bm_1 back from 2.23 to 1.28s.
		- skipping the walk needs to know whether Array.prototype or Object.prototype owns any array-index property. JSArray::getPrototype hardcodes the chain to those two and ES5 has no __proto__ / setPrototypeOf, so it is one global question, not a per-array one. A flag maintained by the call sites that create properties was considered and REJECTED: five hooks, a silent failure mode, and the failure IS this same bug returning. If it is done at all it should be derived at the one choke point every property creation funnels through - Table::insert's `if (!bucket->keyExists())` branch - plus a plain denseVector.size() != 0 test for Array.prototype's own dense range, and it needs the inherited-accessor regression test or it will drift.
		- NOT yet measured: how much of the remaining gap after the completeObject early-out is actually the two prototype lookups. Measure that before adding any invariant at all.

	* 15.4.5.1 (found 2026-09-19, es5 only, review): Object.getOwnPropertyNames on an array can report the same index twice. defineElement puts a standard-attribute element into the sparse table even when index == denseVector.size(); a later plain store then takes setElement's `bucket == 0 || bucket->hasStandardFlags()` branch, pushes into denseVector and never erases the bucket.
		- `var a = []; Object.defineProperty(a, "0", { value: 1, writable: true, enumerable: true, configurable: true }); a[0] = 5; Object.getOwnPropertyNames(a)` -> ["0", "0", "length"]. Also reachable through Object.defineProperties / Object.create, and on non-empty arrays. es3 cannot reach the state at all.
		- Object.keys and for-in dedupe, and the next non-standard define heals it, so the damage is confined to getOwnPropertyNames and whatever iterates it (seal / freeze just do the work twice).
		- the updateOwnProperty fix above removes this as a side effect, the store then updating the existing bucket instead of shadowing it. Otherwise: erase the bucket in that setElement branch.

	* FIXED 2026-09-23 (es5 only, found 2026-09-19, review) 15.4.5.1 / 8.7.2: an object-valued array length store lost its strict TypeError. support.setArrayLength sat outside the strict IIFEs, so its `this.length = +v` was a non-strict store: a refused truncation was swallowed and nothing thrown.
		- `"use strict"; var a = [1,2,3]; Object.seal(a); a.length = 1` throws a TypeError (correct), but `a.length = { valueOf: function () { return 1 } }` on the same array silently leaves length 3 and throws nothing. Same shape for a non-configurable element blocking the truncation. V8 throws in all of them, and docs/notes/ECMAScript Compatibility Notes.md claims "The es5 build conforms" for exactly this path.
		- NOT the stdlib one-liner it looks like. Making setArrayLength strict would throw into non-strict callers too, the exception propagating out of the setter frame whatever the caller is, and `a.length = { valueOf: ... }` on a sealed array has to stay silent outside strict code. The helper needs the Throw flag the store already carries, so putThrough has to hand it over - a second argument passed only when the setter is rt.getSetArrayLengthFunction(), since a script setter would otherwise see it in `arguments`.
		- the Throw flag belongs to the store rather than to the helper, so there are now two helpers differing in nothing but the strictness they compile under, and putThrough picks between them. The error is identical to the direct path because it is the same store. Do NOT factor the two into one: the duplication IS the mechanism. putThrough enters the strict helper without a null test and fetchFunction reports a miss by leaving the pointer 0, so removing or renaming one and not the other does not answer wrongly, it takes the process down on the first such store; the assert beside the fetch and arrayLengthCoercion.io are what catch it.

	* 15.4.5.1 (3, 4) (found 2026-09-23, es5 only): the length assigned to an array is converted ONCE where the spec converts it twice. Step 3 takes ToUint32(Desc.[[Value]]) and step 4 compares it against ToNumber(Desc.[[Value]]), both of the original value, so an object's valueOf has to run twice; support.setArrayLength does `this.length = +v` and the store then sees a primitive.
		- `var n = 0; var a = [1,2,3]; a.length = { valueOf: function () { ++n; return 1 } }; print(n)` -> 1 here, 2 in V8.
		- only observable through a valueOf with side effects, and the resulting length is the same either way, which is why it went unnoticed. Found by an expectation written the wrong way round in arrayLengthCoercion.io, which now pins that the conversion happens and deliberately does not pin the count.
		- fixing it means converting in the helper the way the spec does, `var n = toUint32(v); if (n !== +v) throw rangeError(...)`, rather than letting the native re-derive from a primitive. Cheap, but it makes a second valueOf call observable where none was before, so it is a behaviour change to take deliberately rather than fold into an unrelated fix.

	* JSArray::getOwnSetter answers a stdlib function handle as a sentinel, which putThrough then recognises by pointer identity. The object model should not have to know which runtime-owned function exists in order to say "this store needs a conversion I may not run", and the VM should not be matching pointers to decide it.
		- getOwnSetter reporting the *reason* instead, and putThrough choosing the helper (strictness included), removes the identity compare, removes Runtime::getSetArrayLengthFunction, and makes the strict/loose choice an ordinary branch rather than a substitution.
		- getSetArrayLengthFunction and getThrowTypeErrorFunction are the only two that hand out a stdlib function handle (getHeap and getObjectPrototype are pass-throughs too, but of ordinary state), and they exist because JSArray and JSFunction are not friends of Runtime the way Processor and Support are: two mechanisms for one relationship. Worth settling together with the above rather than by widening the friendship.

	* FIXED 2026-09-22 (BOTH builds, found 2026-09-19, review) 11.2.3 / 10.2.1.2.6: a call through a `with` binding got the global object as `this` instead of the with object. Only a PROPERTY callee got GET_METHOD_OP + CALL_THIS_OP; a NAMED callee always took CALL_OP with noReceiver(), so there was no ImplicitThisValue step.
		- `var o = { m: function () { return this === o } }; with (o) { print(m()) }` -> false in both builds; V8 and both ES3 11.2.3 and ES5.1 11.2.3 give true.
		- fixed unconditionally rather than behind a compile-time gate emitting the receiver-aware path only where a `with` is in lexical scope. The gate was measured and abandoned: most of what it would save is charged to both designs anyway, and the work itself sits below what the suite can resolve. Do not reopen this on a benchmark delta alone. A control build carrying both new opcodes but never emitting them - provably doing nothing - read as a four-sigma regression against main; two such controls differing only in where the dead opcodes sit in the enum measured 1.2-1.4% apart; and two binaries with identical __text hashes measured 0.24-0.46% apart. msvc/x64 and clang/arm64 agree. Any claim here needs an A/A control measured in the same session.
		- the es5 build already had the stack shape this needs, GET_METHOD_OP leaving this+function for CALL_THIS_OP, so the merge unified the two rather than carrying both: CALL_THIS_OP is gone, CALL_WITH_THIS_OP is unconditional in both builds with only its receiver argument guarded (an Object* on es3, the base as written on es5), and READ_NAMED_WITH_THIS_OP carries the es5 accessor path of READ_NAMED_OP, a callee reached by name being able to be an accessor on a with or global object like any other read.
		- definition site governs, never call site: a function merely called from inside the block sees nothing of it and stays a ReferenceError, even when it is a method of the with object itself - the shape an over-eager fix would be tempted to make work. tests/conforming/withImplicitThis.io pins all eight against V8, and tests/extremes/stackOverflow.io is re-pinned two frames lower (1016 -> 1014) for the extra value-stack slot per named call, confirmed identical on Windows/x64 and macOS/arm64.

	* Make gc async/incremental in the sense that you actively and repeatdly call it until it is done (doesn't block native cpu, even if it "blocks" vm cpu).

	* FIXED 2026-08-01 (es5 only, found 2026-07-30): a strict function referencing `arguments` that threw an exception caught by JS segfaulted the process on the next sweep. Regression test in tests/es5/strictArgumentsThrowUseAfterFree.io.
		- the arguments/FunctionScope link is a weak pair by design: the scope's pointer to the object is strong and marked, the object's `scope` back-link is deliberately unmarked so that an escaped `arguments` never pins a whole closure alive. Both can therefore die in the same sweep, and what makes that safe is that each destructor severs the other's pointer (~FunctionScope calls detach(), which promotes the alias into an owned copy; ~Arguments clears FunctionScope::arguments). GCList::deleteAll destructs one item at a time, so whoever dies first finds the other still valid. The protocol is correct and ES3 was never at risk.
		- what broke it: 10.6 non-mapped (strict) arguments reused `scope == 0` to mean "not aliased to the parameter slots", which also erased the back-link, so a strict object never severed and ~FunctionScope was left calling detach() on freed memory. One field, two meanings; the ES5 path needed to change only one of them.
		- fix: `scope` is now the back-link in both modes and isMapped() answers the aliasing question, so the strict ctor takes the scope like the mapped one does. detach() on a non-mapped object just clears the link, since its values were captured at entry. es3 release binary verified byte-identical.
		- NOT fixed, separate issue, and much smaller than it first looks: throwVirtualException resumes at firstCatcher->frame with a single assignment, so the frames and scopes between the throw and the catcher never get popFrame'd and never get Scope::leave(). Reviewed 2026-08-03 and it is NOT a leak, NOT a lifetime hazard, and not the cause of the crash above. The memory comes back at the next collection, since Frame and Scope are both GCItems; the only cost is that it comes back then rather than at the throw. Nothing dangles either: FunctionScope owns its `locals` vector and copies argv into it at entry, so a skipped scope stays intact and an escaped `arguments` reading through it sees correct values until the sweep, at which point ~FunctionScope detaches it exactly as frame exit would have. What the skipping did do was make the *same-sweep* case common, and that case was mishandled by the strict back-link bug above until it was fixed; the protocol itself is order-independent by design, which is the only thing that can be assumed under a gc. So this is a gc-pressure item, not a bug. Fixing it is still shared code and would move the es3 binary unless #if-guarded.

	* is the logic correct when changing array length containing a few undeletable elements?

	* exception what() should be the one doing the conversion job etc (because exception constructors should never have a risk of throwing), but how can we do that without a heap?
		- actually I think we should merge ScriptException and Exception, no point in having a separate Exception

	* CompilationError is a hack to get access to error line number when using the high-level API. It is problematic because if you catch a compilation error in Javascript you lose this information. Also, it would be neat to have a full stack trace in exceptions for run-time errors. But this is not a standard part of ES3 of course.

	* setMemoryCap is only enforced inside autoGC, which only runs at the STANDARD_CYCLES_BETWEEN_AUTO_GC batch boundary. Within one batch the heap can grow unboundedly: a single op that allocates a lot (e.g. `s += s` doubling a string) reached ~2 GB *live* with a 16 MB cap before the next check fired (it only stopped on MAX_SINGLE_ALLOCATION_SIZE, not the cap). No host crash (nothrow new -> managed "Out of memory"), but the cap on *running load* isn't really honored for bursts.
		- the contract is that running (live, retained) load must not overshoot the cap; transient spikes are fine. The existing autoGC check (gc + drain, then heap.size() >= memoryCap) measures live load correctly - the only defect is timing.
		- safe fix A (general): charge cyclesLeft for bytes allocated so a burst ends the batch early and the existing post-gc live-load check runs promptly. Reuses the cyclesLeft exit path (no new flag). Catches accumulation of many sub-cap chunks too. Wiring cost: Heap needs a `Int32* activeCyclesLeft` that Processor::run sets/restores via RAII; correct because only one Processor runs per heap at a time (nested rt.call suspends the outer) and heaps aren't shared across threads. Downside: Heap gains a back-reference into VM execution (no longer a pure allocator).
		- safe fix B (cheap, Heap-local): reject a *single* allocation with `size > cap` in acquireMemory (cap pushed down from setMemoryCap). A lone object bigger than the cap can never be valid running load, so this is correct, no false positive, and no Processor coupling. Kills the dramatic single-alloc case (s += s) but does not bound intra-batch accumulation.
		- DANGEROUS / rejected: a cumulative hard ceiling `allocatedSize + size > cap` in acquireMemory - it counts transient + uncollected garbage, so it would spuriously OOM legitimate programs whose steady-state is under the cap.
		- also rejected: GC inside allocate (would bound it tightest, no false positives) - breaks the "GC only at cycle boundaries when the VM stack is consistent" invariant; would need every allocation site audited for unrooted live pointers.
		- decision: deferred for now (reviewed 2026-06-28). B is the clean, coupling-free win; A adds the Heap<->Processor wiring needed to also bound accumulation.

	* AccessorBase::VarMemberFunctionAdapter's receiver check fails OPEN, so the one binding form that looks safe is the least trustworthy. Decide whether to fix it or drop the form (reviewed 2026-08-10, kept as-is for now).
		- background: four things can be assigned to a property to make it callable, and only one validates the receiver. NativeFunction -> FunctorAdapter and VarFunction -> VarFunctorAdapter both forward `thisObject` unchecked; a member function pointer `Var (C::*)(Runtime&, const Var&, const VarList&)` -> VarMemberFunctionAdapter<C> checks; Var(rt, cppObject, &C::method) -> BoundVarMemberFunctionAdapter ignores the receiver entirely. A static and a member function with identical bodies on the same prototype differ in safety with nothing at the call site to show it. Now documented in "Binding C++ functions to properties, and validating `this`".
		- the bug: the check is `me->C::getClassName() != me->getClassName()`. If C does not override getClassName(), the left side resolves to the inherited Object/JSObject implementation, which is exactly what an ordinary object returns on the right, so they compare equal and an unrelated object is reinterpret_cast into C and its method body runs. Verified: binding a member function on a class with no override and calling it with a plain {} receiver does not throw and the body runs; the same class with an override throws TypeError "Invalid class".
		- the check is also wrong in the other direction: a C++ subclass of C that overrides getClassName() with its own name is rejected from methods it legitimately inherits.
		- two lesser defects in the same five lines: no null test (the virtual getClassName() call segfaults on a null receiver, where a hand-written check would throw), and reinterpret_cast rather than static_cast, with the cast performed *before* the class is validated. JSObject inherits Object and Table, so a non-zero base offset is not hypothetical.
		- note the check only covers the receiver, never arguments; checkedOther-style argument validation stays the method's job under every option below.
		- rejected fix A (token at the binding site, `memberFn(&C::m, &CLASS_NAME)`): supplying the wrong constant validates against the wrong class and then casts, i.e. it reproduces the corruption it is meant to prevent, and repeats the opportunity at every binding.
		- rejected fix B (mixin re-declaring getClassName() pure, mirroring LazyJSObject<SUPER>): the forcing works (a subclass without the override becomes abstract and won't instantiate), but it is opt-in - a class deriving straight from JSObject binds fine and degenerates exactly as today, and the developer who forgets the override is the one who forgets the base class. Making it mandatory needs a non-template tag base plus a compile-time derivation check, i.e. a second base on every native object. It also does not remove the unvalidated-pointer call: it guarantees the override exists, not that its body ignores `this`.
		- rejected fix C (required `static const String CLASS_NAME` member): compile error when missing and fails closed when the override is forgotten, but no precedent - the codebase forces subclass contributions with pure virtuals (Enumerator::nextPropertyName, LazyJSObject::constructCompleteObject, Function::invoke), never with a magically named static, and the engine's own class-name constants are file-scope in NuXJS.cpp, not members.
		- candidate 1: make the check RTTI-conditional. dynamic_cast is the correct answer, gets both the fail-open and the subclass case right, and handles pointer adjustment; it is already present as the debug assert on the next line. Blocked in release only by -fno-rtti, which buildAndTest.sh sets for the release target alone (beta and debug keep RTTI). Costs two code paths and a fallback decision for embedders who disable RTTI themselves.
		- candidate 2: delete the member function pointer binding. Nothing in src/, tools/ or docs/examples/ uses it - only the declaration and definition in NuXJS.h - so in-tree breakage is zero. Leaves three forms where validation is unambiguously the method's job, done as NativeFloat32Array::checkedCorrectType already does it (getClassName pointer identity plus a null test).


Compiler
========

	* FIXED 2026-09-20 (es5 only, found 2026-09-19): Compiler::markBackwardBranch did not clear storeTailEnd, so the store-tail peephole could delete an instruction at exactly the offset a backward-branch target had just been recorded at. The loop then re-entered one instruction into its own body, the operand stack desynchronised, and eval code segfaulted the process. Regression test in tests/es5/evalStoreTailBackwardBranch.io.
		- `var o = {}, i = 0; eval("o.a = 1; do { i = i + 1; } while (i < 3); i")` -> segmentation fault (exit 139) in the release build, and `assert(0)` at NuXJS.cpp:829 (Value::toDouble on a garbage type) under asserts. `eval("o.a = 1; do { m++; o.b = m; } while (m < 3); o.b")` -> bogus `TypeError: undefined is not a function`. `eval("o.p = 1; do o.q = ++i; while (i < 3); o.q")` -> silently 1 instead of 3. es3 and V8 give 3 for all three.
		- only FOR_EVAL code can reach it: eval keeps the completion value, so makeRValue emits nothing for PUSHED and storeTailEnd survives the end of the statement; the next statement's first identifier calls discard() -> dropStoreTailValue() as its very first action. A do/while between the two puts markBackwardBranch() precisely in that gap. Global and function code discard at the end of their own statement, before any mark, so they are immune. makeAssignment only arms storeTailEnd for NAMED and PROPERTY targets, so the pending statement has to be a property store or a for-in / function-declaration name store.
		- fix: `currentSection->storeTailEnd = -1;` in markBackwardBranch, beside the lastEmitted reset that is there for the other peephole and for the same reason. switchStatement marks backwards for every `case` and for `default` and had the identical hole, which the same line closes. changeSection needs nothing: storeTailEnd is a CodeSection member, so each section's marker describes only its own code vector.
		- verified: the es3 preprocessed translation unit is unchanged bar the eight blank lines /EP leaves for the guarded block, so the frozen build cannot have moved (MSVC objects are not reproducible even with /Brepro, so hashing them is not a usable gate). Both .io suites pass, both NuXJSTest self tests pass, an asserts build runs all 364 es5 inputs and 3500 differential fuzz programs with no assertion, and eval-heavy benchmarks are unchanged - the peephole only stops firing in the adjacency that was broken.

	* FIXED 2026-09-20 (es5 only, found 2026-09-19): a strict object literal rejected an accessor whose PROPERTY NAME was eval, arguments or a future reserved word. accessorFunctionDefinition now sets nameIsPropertyName on the sub-compiler, which is the one production that needs it, and compileFunction skips only the name check; tests/es5/strictFunctionNames.io walks all eleven words as getter and setter and pins the parameter rule beside them. objectInitialiser hands the accessor's PropertyName to accessorFunctionDefinition as the function name, and compileFunction then applies the 13.1 / 7.6.1.2 restriction on a function's own Identifier to it. 11.1.5 PropertyName is an IdentifierName, where every one of those is legal.
		- `"use strict"; ({ get eval() { return 1 } }).eval` -> SyntaxError where V8 gives 1. Same for arguments, implements, interface, let, package, private, protected, public, static and yield, as getters and as setters, inside strict eval and inside functions that inherit strictness. The data form `({ eval: 1 })` is fine, which is why tests/conforming/reservedWordsAsPropertyNames.io (data properties only) misses it.
		- the parameter list is a *separate* rule and is already right: 11.1.5 has its own clause forbidding eval / arguments as the Identifier of a PropertySetParameterList, so `({ set x(eval) {} })` must keep throwing, and does. Any fix has to skip the name check alone, a few lines from the parameter check in the same block.
		- &EMPTY_STRING as the checked name was the smaller fix and was rejected: functionName also builds code->name and code->source, so blanking it would cost the accessor its name in toString. compileFunction's signature is shared es3 code and could not take a parameter either, hence the guarded member.

	* Same reuse, separate and much smaller: because an accessor is compiled through the ordinary function path, compileFunction builds its code->source as `"function " + name + <span>`, so `Object.getOwnPropertyDescriptor({ get eval() { return 1 } }, "eval").get.toString()` answers `function eval(){return 1}` where V8 answers `get eval(){return 1}`. 15.3.4.2 leaves the format implementation-defined, so this is not a conformance bug, only a visible artifact worth knowing about. (found 2026-09-20, es5 only, review)

	
	* 7.1: strip Unicode format-control (Cf) characters - LRM (U+200E), RLM (U+200F), ZWNJ (U+200C), ZWJ (U+200D), BOM (U+FEFF) - from the source before lexing. ES3 removes them *everywhere*, even inside string/regexp literals (so they'd need \uXXXX to appear in a string). Currently NOT done: a BOM/LRM etc. in code gives a SyntaxError, and they survive as chars inside string literals (e.g. "a<BOM>b".length is 3, should be 2).
		- ES5.1 7.1 abandons the stripping and names the two places it matters instead, so both are now done for the es5 build and this entry describes es3 alone: the BOM became 7.2 WhiteSpace (see below), and ZWNJ / ZWJ became 7.6 IdentifierPart, which the generator handles by building a second part bitmap for es5 and packing it into the same mask array, so no lexer code is involved. LRM and RLM have no ES5.1 treatment at all and stay a SyntaxError in both builds, correctly for es5. Test in tests/es5/identifierFormatControl.io.
		- still open for es3, and fixing it moves the frozen binary, which is the same decision the <USP> set below is waiting on.

	* 7.2 whitespace: the explicitly-listed chars are handled and tested (tests/conforming/variousUnicodeSpaces.io covers TAB/VT/FF/SP/NBSP plus the 7.3 terminators LF/CR/LS/PS). The only thing not covered is the open-ended "Other category Zs" catch-all (the rare U+2000..U+200A, U+3000, U+1680, U+202F); those currently SyntaxError between tokens. Marginal - low priority.
		- the run-time skipper has the same gap and is the more visible half: eatStringWhite backs 9.3.1 ToNumber, so `Number("　1")` is NaN where it should be 1, and parseInt / parseFloat 15.1.2 leading-whitespace stripping is short by the same set.
		- FIXED 2026-08-03 for the es5 build only, under guards, so this entry now describes es3 alone. Compiler::white() and eatStringWhite share one generated isWhiteSpace covering the BOM and the Zs set; parseInt reads a table stdlib.js builds from WHITE_SPACES, so guarding that one string made it conformant with no change to its code, and String.prototype.trim reads the same table. es3 release binary verified byte-identical. Test in tests/es5/whiteSpaceSet.io. The set is now generated from Unicode 3.0, where U+200B is category Zs and so does count, rather than the Cf it became in a later version.
		- still open for es3, and it is a real ES3 deviation rather than an ES5 gap: ES3 7.2 has the identical <USP> catch-all. Fixing it moves the frozen binary, so it needs the same decision the comma-operator fix got, namely whether a plain conformance bug in shared code is worth moving es3 for. Nothing depends on it now that the es5 build is conformant.

GC
==

Stdlib
======

	* FIXED 2026-09-20 (es5 only, found 2026-09-19): readArgList took `+argArray.length`, so apply's retry path disagreed with its own native fast path and an out-of-range length was materialized instead of wrapping. It now converts the way the native half does - ToInt32 then clamp at zero - which is what makes the two agree; the matrix in tests/es5/applyGetters.io pins plain against getter for eleven lengths. Step 6 says ToUint32, but that turns a negative length into four billion arguments, and neither the native half nor V8 has ever done it.
		- `f.apply(null, { length: 2.5, 0: 'a', 1: 'b', 2: 'c' })` passes 2 arguments (correct), but `f.apply(null, { length: 2.5, get 0() { return 'a' }, 1: 'b', 2: 'c' })` passes 3 - the same call, a different answer depending only on whether a getter forces the RETRY_LIST detour. Same for an accessor or object length.
		- `{ get length() { return 4294967297 }, 0: 'a' }` (ToUint32 = 1) tries to build four billion entries and kills the interpreter with an uncatchable "Memory allocation failure"; the surrounding try/catch never runs. V8 answers 1 argument.
		- tests/es5/applyGetters.io asserts "length is converted with ToUint32 as before" without covering a fractional or out-of-range length, and docs/notes/ECMAScript Compatibility Notes.md claims the es5 build conforms. fix: `n = uint32(argArray.length)`.

	* FIXED 2026-09-20 (es5 only, found 2026-09-19): Error.prototype.toString omitted step 1 ("If Type(this) is not Object, throw a TypeError") and, the entry not being strict, boxed a primitive receiver into the global object and reported ITS name and message as the error's. It also read each field twice where steps 2 and 5 read once. The entry is now strict, which is what makes step 1 reachable at all, and reads both fields into locals; tests/es5/errorToString.io pins the five primitive receivers and counts the gets.
		- `var name = "GLOBALNAME", message = "GLOBALMSG"; Error.prototype.toString.call(null)` -> "GLOBALNAME: GLOBALMSG", reporting global variables as the error, where V8 throws a TypeError; `.call("x")`, `.call(5)` and `.call(true)` return "Error" instead of throwing. With `{ get name() {...}, get message() {...} }` counting their calls, NuXJS reads each twice and V8 once.

	* FIXED 2026-09-20 (es5 only, found 2026-09-19): Date.parse rejected the expanded year +000000, the `... || readPart(4)` idiom treating the *value* zero as "no expanded year" and re-reading four digits from the middle of the string. The es5 half of that line is now a conditional, which it can be because isDateTimeString has already settled the shape; the es3 line is untouched and the blob is byte-identical. isDateTimeString also rejects -000000 now, which 15.9.1.15 forbids and which the falsy zero had been hiding. tests/es5/dateParseRejectsInvalid.io pins both signs.
		- `Date.parse("+000000-01-01T00:00:00.000Z")` -> NaN, where V8 gives -62167219200000. `"0000-01-01T00:00:00.000Z"` works, so two legal spellings of the same instant disagree; only year zero is affected, 15.9.1.15 forbidding just -000000.

	* FIXED 2026-09-20 on main, merged here (BOTH builds, found 2026-09-19): qsort looped forever on a comparator that never answered <= 0 - `high` was driven below `from` while `low` stayed at `from`, so `from = low` made no progress and the outer for repeated identically - and overflowed the stack on one that always answered < 0, `low` reaching to + 1 so qsort recursed on its own range. Both scans stop on the pivot, `cmp(mid, mid)` being neither > 0 nor < 0, which leans on the comparator for the algorithm's own bounds; pinning the split to from < low <= to ends both. Regression test in tests/stdlib/sortComparatorTermination.io.
		- measured on [3,1,2]: `return 1`, `return true`, `return a >= b` and `return a < b ? -1 : 1` all spin at 100% CPU forever (one run reached 1107 CPU-seconds during the review before being killed), and `return -1` goes to `RangeError: Stack overflow` through unbounded qsort recursion instead. `return a > b` and `return b - a` are fine, because cmp(mid, mid) answers 0 and lets `low` move - so it is not the boolean shape as such, it is any comparator that never answers <= 0. V8 terminates on all of them. A host that calls resetTimeOut is bounded (`-T 2` reports "Time out"); one that does not hangs.
		- fixed on main rather than behind a guard, because it is an es3 bug and not an es5 one: the es3 blob moves from 53908 to 53946 bytes, which is the toFixed precedent rather than the <USP> one. The clamp is inert for a consistent comparator, the pivot already holding low inside the range - 2400 sorts over six consistent comparators, with holes and undefined, come back byte-identical on both builds.
		- `a < b ? -1 : 1` is the one that made this worth fixing rather than filing under "inconsistent comparator, implementation-defined result": it is an ordinary thing to write, it is inconsistent only because it forgets the equal case, and 15.4.4.11 leaving the *order* unspecified for such a comparator does not license never returning. The `v === v ? v : 0` guard on line 1070 already anticipates exactly this failure shape for NaN; the never-negative case needs the same progress guarantee (a `--to` / `++from` floor in the partition, not a comparator fix-up, since the comparator is not the thing at fault).

	* FIXED 2026-08-04: toFixed rounded on double arithmetic where 15.7.4.5 step 10 asks for the integer nearest the EXACT value of val * 10^f, ties upward. Fixed in the es3 engine unguarded, like the comma operator before it, since it is a plain conformance bug in shared code and the same requirement in ES3 15.7.4.5 as in ES5.1. Tests in tests/stdlib/numberToString.io.
		- the entry this replaces named only (1000000000000000128).toFixed(0) -> "1000000000000000100", which is the rarest corner of it. The common case was ordinary rounding: (0.35).toFixed(1) answered "0.4" where 0.35 is really 0.34999999999999997779 and must round DOWN, and (1.45).toFixed(1) answered "1.5". Roughly one in nine random doubles was wrong.
		- two causes, one fix. Going through '' + integer used 9.8.1 ToString, which is the SHORTEST round-tripping form by definition and so cannot carry exact digits; and floor((val - integer) * 10^f + 0.5) rounds a value that has already lost the information. Every double is y * 2^shift with y an exact integer below 2^53, so the exact expansion is a digit array multiplied by 2 (shift >= 0) or by 5 (shift < 0, since y / 2^k == y * 5^k / 10^k), after which one digit decides the rounding: no sticky bit is needed because an exact tie rounds up like everything above it.
		- COSTS 19x: 1.55 us -> 29 us per call, measured at 200k calls. It was 160x before chunking the exponents per pass (21 for base 5, 49 for base 2, the most that keeps 10 * m under 2^53), and 29x before the cleanup pass that dropped Array unshift/push/reverse/join from the hot path: all four are themselves interpreted JS in this file, so a loop of unshifts is interpreted O(n^2) with a large constant, and plain descending concatenation beat reverse().join() at every length measured. A double-arithmetic fast path for the cases that are not near a tie would recover most of the rest, at the price of resting on an error bound instead of on exactness. Not done; decide before anyone "optimizes" this again.
		- the 5e-21 guard in toFixed does not protect the other two, and cannot: they must emit real digits, and the carries in y * 5^1074 propagate upward so the low ones cannot be skipped. (5e-324).toFixed(20) is 0.015 ms and (5e-324).toExponential(20) is 4.4 ms, about 290x. Inherent, not a defect, but worth knowing before anyone formats denormals in a loop.
		- 15.7.4.6 toExponential and 15.7.4.7 toPrecision had the SAME defect and are now fixed too, on the same exactDigits / digitString pair, since both ask for n and e with a fixed digit count nearest x with ties to the larger, which is the same cut at a significant-digit count instead of at an absolute decimal place. 16% of a 60540-case sweep was wrong before, denormals worst: (1e-323).toExponential(2) answered "1.00e-323" where the double is really 9.8813129168e-324, and Number.MIN_VALUE.toPrecision(21) answered "5.00000000000000000000e-324" for 4.94065645841246544177e-324. EIGHT expectations in tests/stdlib/numberToString.io were pinning those wrong answers.
		- their fractionDigits-absent path wants "f as small as possible", which IS 9.8.1 ToString, so it now reads the digits back out of ToString rather than recomputing them from a log/pow significand. That also removes an inconsistency nobody had noticed: (0.35).toExponential() used to answer 3.4999999999999996e-1 while String(0.35) was "0.35". 40000 random values now confirm x.toPrecision() === String(x) exactly, which 15.7.4.7 step 2 requires.
		- both also returned a Number rather than a String for NaN, the infinities, and toPrecision with precision absent. Fixed; typeof is now "string" throughout.
	* NOT a bug, recorded so it is not "found" again: for a value exactly between two 17-digit decimals, e.g. 1700687411567516.25, NuXJS ToString answers "1700687411567516.3" and V8 answers "1700687411567516.2". Both round-trip to the same double, and 9.8.1 (ES3 and ES5.1 alike) says in as many words that "the least significant digit of s is not necessarily uniquely determined by these criteria". 16 of the 60540 cases above are this, all in the fractionDigits-absent path, and all now consistent with our own String(). A later 260000-case run put it at 24, being 12 values times toExponential() and toPrecision(). Every one measured is an EXACT tie: the double terminates at 18 significant digits ending in 5, e.g. 0.83309173583984375, so it is equidistant from both candidates. Note though that ES3 (lines 1713 and 5472 of the md) and ES5.1 (lines 2307 and 6339 of the txt) both carry a non-normative NOTE recommending that implementations with more accurate conversions break such a tie toward the EVEN digit. V8 follows it, we round half up in magnitude. We already satisfy its primary "closest in value to x" clause everywhere, so only the even rule differs. Following it would mean a round-half-to-even tie-break inside doubleToString. DECIDED: we do not. It is a NOTE, not normative, our output round-trips and uses minimal digits either way, and the ES3 core is not worth disturbing for a choice between two equally valid spellings. Measured at 434 of 200000 random doubles (0.217%), every one of them an exact tie and every one round-tripping. Do not reopen this.

	* FIXED 2026-08-02 (es5 only): a strict function that reached `arguments` INDIRECTLY got the wrong values. `Code::usesArguments` was set by a purely lexical scan for the identifier, and only then did the FunctionScope ctor capture argv at entry. Reach it through a direct `eval` instead and `getDynamicVars` built the non-mapped object from `localsPointer`, i.e. the parameter slots as they were NOW, so it silently behaved like a mapped object snapshotted late. `(function (a) { 'use strict'; a = 9; return eval('arguments[0]'); })(1)` gave 9 where 10.6 and V8 say 1. Regression test in tests/es5/strictArgumentsIndirectCapture.io.
		- the fix is NOT the one sketched here first ("always capture for strict functions"). That is unconditionally correct but costs three allocations per strict call (the Arguments object plus its two vectors) for the overwhelmingly common function that never touches `arguments`. Instead `usesArguments` is now set by a second production as well: a *direct eval call*, which the compiler already recognises exactly, at the site where it picks CALL_EVAL_OP.
		- why that is sound, and why the two productions have to stay a matched pair: a direct eval is the only way into a strict function's own scope by name. `with` is a SyntaxError in strict code, an indirect eval runs as global code, and a nested function's `arguments` is its own. On the consuming side, FunctionScope::readVar / writeVar / deleteVar only reach getDynamicVars() for the name `arguments` itself, and declareVar only for a name outside the function's own nameIndexes, which in strict code again needs a direct eval. The contract is written out on `usesArguments` in NuXJS.h.

	* FIXED 2026-08-02 on main, in the es3 engine itself rather than under a guard, since it was a plain conformance bug in shared code and the es3 binary gate exists to catch accidents, not to freeze defects. The comma operator yielded a *reference* where 11.14 says it yields a value: `case COMMA` in postOperate handed the right operand's ExpressionResult straight back, so `(0, eval)` was still `NAMED("eval")`. It now collapses through makeRValue. Six behaviours moved, all onto V8's answer: `(0, o.f)()` this-binding, `(0, eval)` scope read and write, `typeof (0, undeclared)`, `delete (0, v)`, and `(0, v) = 5`. `(eval)(s)` stays a direct eval, since 11.1.6 does not GetValue, and `case GROUP` now says so in a comment. See tests/conforming/CommaOperatorYieldsValue.io.
		- consequence for the item above: `(0, eval)` no longer sets `usesArguments`, which is correct. An indirect eval runs as global code and cannot reach the function's own `arguments`, so the matched pair in NuXJS.h is now exactly the two productions that can.

	* NOT a bug, recorded so it is not "found" again: an indirect eval seeing a global `arguments` (`var g = eval; g("typeof arguments")` -> "object") is the command-line tool, not the engine. tools/NuXJSREPL.cpp defines a global `arguments` array of [script.js, args...], which its own --help documents. node has no such global, hence the diff.

	* Date.parse reads a DATE-ONLY ISO string as local time; 15.9.1.15 says a date-only form is UTC and only a date-TIME form without a zone is local. `Date.parse("1970-01-01")` gives -3600000 in CET where it should be 0; the date-time case is already right. The parser is in stdlib.js (shared with es3), and it never sets a flag for "a time part was present" - the fix is to record that where the T / t / space designator is consumed and skip fromLocalTime when it was absent. ES3 15.9.4.2 leaves Date.parse implementation-defined and has no ISO format at all, so this changes es3 behaviour and therefore the es3 binary; needs a decision before landing.

	* es5 only: `f.bind(null).name` is "bound undefined" when the target has no own `name` (V8 gives "bound "). Only reachable for native functions that lack `name`, since JSFunction always sets one. `name` is a NuXJS extension anyway (15.3.5 defines only `length` and `prototype`), so this is cosmetic - see the bound-function entry in docs/specs/ES5.1 vs modern divergences.md.

	* es5 only, performance: the five callback-taking array methods use `f.call(t, o[k], k, o)` per element, and `Function.prototype.call` is itself JS (stdlib.js) that reads `arguments`. That costs roughly 4-5 heap objects per element: the `call` frame's FunctionScope and locals, a dynamicVars JSObject plus an Arguments object because `call` is non-strict and touches `arguments`, and the lazy complete object that `arguments.length` forces. `reduce`/`reduceRight` call `f(...)` directly and pay none of it.
		- fix: a `support.callback(f, thisArg, a, b, c)` native hook doing `f->invoke(rt, processor, 3, argv, thisObject)` off a stack array. Adds one Support entry and REMOVES a code path from the JS, so it does not fall foul of "an optimization that adds code paths is a net loss" - but measure a large forEach first, per the PROVEN-win rule.

LOW PRIO
########

Run-time
========

	* I don't know but the "emulation" in arguments object feels a bit over the top (registering deleted items etc)

	* perhaps it would have been better to split Frame into different pointers (more similar to ES-spec): one for running code (not changed by catch and with), one for variable object (not changed by catch, with or eval) and "current scope object" (changed by them all). This way we wouldn't have to declare so many dummy virtuals that just passes stuff upwards the Frame chain.

	* array object: type-specialized storage. (DONE: length property + a dense continuous-vector that falls back to a normal ScriptObject when the array becomes sparse or gets non-integer keys - see JSArray denseVector / sliceDenseVector / constructCompleteObject.)
		- still open: use different compressed variations (templates) when the type is homogenous over the whole array, e.g. number array, object array, string array. One could even consider an int array.

	* unprintable strings, strings with lf etc does not look so nice in exceptions, e.g. when trying to convert to a function, e.g. ("")(): TypeError:  is not a function
		- also extremely long strings create absurd exceptions this way

Compiler
========

Other
=====

	* diagB.js at the repository root is a six-line ad-hoc diagnostic for the Error reflection work, committed by the ES51 branch and referenced by nothing. Delete it or move it under tests/. (found 2026-09-19, review)

	* tools/buildAndTest.sh builds the examples with `BuildCpp.sh "$target" "$exe" ...`, dropping $model; the .cmd twin got that fix on the ES51 branch but the POSIX script did not, so `./build.sh es5 x86` builds the examples for `native`. It fails quietly because $exe does not match BuildCpp.sh's model regex and is taken as the output path instead. (found 2026-09-19, review)

	* included in tests should be to config the gc to sweep after every instruction


	* optional version without exceptions?!
		- would work except for the compiler, how to abort compiler? longjump? I know it is ugly, but this woul be for embedded systems etc that disable exceptions. Would be nice to support them.
		  ... or I suppose we could change all methods to return a bool :(

OPTIMIZE
########

Run-time
========

	* could we gain something on representing bools as doubles (0 and 1) in the union? e.g. converting to/from double would be quicker

	* if we can guarantee that vsp is always at function entry level for each catch scope we should try a table-based exception handler, e.g.
		- struct TryRange { Int32 offset; Int32 length; Int32 catchIndex; String* catchName; } // catchName != 0 then create temporary "catch frame"
		- TRY_OP, TRIED_OP and CATCH_FRAME_OP would go away then...

	* if we supplied a local variable index to CatchFrame (for the exception variable) we could access it by index instead of by name in the catch scope (and in the CatchFrame property getters/setters), but I am not convinced it would make an enormous performance improvement.

	* Make writes terminal and REPUSH in a = b = c type of expression...
		- after a lot of experiments with this I think we better expand this in the future to a general opcode pattern reducer instead (see rev 19228)
		- instead added _pop variations on write opcodes



	* not a big fan of the POST_SHUFFLE_OP solution, feels ugly, but can't for the world come up with any simpler solutions!?

	* PRE_EQ_OP isn't actually necessary, we could just backup ip once if isObject and retry the EQ after toPrimitive (same applies to TO_PRIMITIVE_OP actually, but that's a bigger story considering the virtually impossible task of "primitivizing" two stack elements at once for binary operators)
		- alternatively have two opcodes, swap on type < (like in isEqualTo today) and save CPU on isEqualTo as operands are already sorted

	* .length is very common, special opcode?

	* arguments and <self name>, couldn't they be indexed variables too instead of accessed through slow READ_NAMED? Either created only when present in code or allocated on demand?

	* "get parent index" opcode, it is very common to access variables one level up (two levels up not so much), and parent frame never changes in a closure so...

		- I did a full implementation of this ("far index" opcodes that contained distance to travel up the scope chain) and concluded that (non-strict) eval (and allowing var declarations inside eval) breaks everything. :( Performance gain seemed to be around 30%(!) otherwise. Here is an example that illustrates the problem: (function a() { var k = 5; (function b() { var i = 0; do { (function c() { print(k); })(); eval("var k = 3"); } while (++i < 2); })() })(). This code has an eval that inserts a k variable in the (b) closure just above the current function (c) but below the k = 5 definition (in a). How the hell should we know of this when we compile the innermost function? Since we do a single pass and compile each function with a separate Compiler instance it is not trivial to go back to all inner functions and fix this afterwards.

		- Actually, for the particular but common case of one level deep closure we could implement opcodes that just go up one level (e.g. read-
		global-indexed). Anything deeper than that suffers from the problem described above. We would still need a 2nd pass to change all indexed to named if we encounter an eval, but that would only be on the function we are currently compiling.

		- A completely different approach would to be to abort the scope climbing when you encounter a scope that has been used by eval, thus determining this in run-time, and continue the search by name (through code-def lookup) at that point. I guess CPU hit could be negligable if we just set a pointer (climbScope) to 0 whenever direct eval is being executed in a scope. It would improve performance where eval is included in the code but for some reason isn't actually used (`if (false) eval(s)`). But it would prevent further optimizations (not yet tested) like having a constant-time short vector in each scope for scope-chain upwards instead of only a linked-list. (I think it is *extremely* rare that you have closures that are deeper than say 8 levels.)

		- Also, as the compiler works now, a simple late declaration of a var is enough to break things. E.g. `var x = 5; (function() { print(x); var x; })()` should print "undefined" and not "5". This could of course be solved as soon as you encounter "var x". But what about: `var x = 5; (function() { (function() { print(x); })(); var x })();`. The recompile when finding eval approach alone doesn't cut it (svn revision 19277). What we need is a second compilation pass to bind all variables. To bad. Chess benchmark is twice as fast without global variable lookup by name.


	* es5 only: RESOLVE_NAMED walks the scope chain to capture the assignment reference 11.13.1 asks for, and that walk is most of the residual cost of the fix. It is only observable when the target scope can move under the right-hand side, which needs a `with` in scope or a direct eval that can declare; the compiler already knows both at the site, so it could emit plain WRITE_NAMED otherwise. Same eval-defeats-static-scoping problem as the "get parent index" entry above, and the same caveat: a late `var` counts too.
		- do NOT "simplify" readVar and resolveVar into one walk. It looks like duplication and is not: measured at 1.6pp across the benchmark suite, because a read that hits an ordinary binding must not pay for the holder bookkeeping. The contract is written out on resolveVar in NuXJS.h.
		- the branch's benchmark numbers were taken on a busy machine and are not trustworthy beyond "the fix costs a few percent". Re-run on a quiet one before anyone optimizes against them.

	* have a tiny-string type which fits inside value directly (4 16-bit words or 8 8-bit bytes?), for faster/more economic character handling

	* building strings is still slow, could they be built with an internal temporary type similar to $StringBuilder? Or a "PolyString" which consists of a meta-concatentation of two existing strings (or polystrings), possibly even substrings of those?
		- gc is now so much better that this has improved a lot, test to see if it is still a problem if you have a heavily populated heap


	* have an int index Element AccessorBase for quick array accesses

Compiler
========

	* jump optimizations
		- another way to deal with it would be to think in the lines of the break scopes... complete forward jumps first at definite end-point, I think this was the way I solved it in ACL
		- we should at least have two alternative JF and JT, JF_NO_POP, JT_NO_POP that doesn't pop on jump
		- JF_OR_POP and JT_OR_POP implemented... next step is to do a global pass on all jumps and reduce jump->jump->jump to single jumps, rules:
			.    J** @y
			  y: JMP @x
			  => JMP @x

			.    JF_OR_POP @y
			  y: JF_OR_POP @x
			  => JF_OR_POP @x

			.    JT_OR_POP @y
			  y: JT_OR_POP @x
			  => JT_OR_POP @x

			.    JF_OR_POP @y
			  y: JF @x
			  => JF @x

			.    JT_OR_POP @y
			  y: JT @x
			  => JT @x

			.    JF_OR_POP @y
			  y: (JT_OR_POP | JT) @x
			  => JF @y+1

			.    JT_OR_POP @y
			  y: (JF_OR_POP | JF) @x
			  => JT @y+1


	* eliminate re-thrower in try / catch / finally if no finally block (by replacing the first try in catch with jmp +0)

	* try to move POP_FRAME to first in FINALLY block, need different JSR and a new RSR / JMP_INDIRECT then that pushes and pops instruction offset on value stack instead (ought to work)
		- we could go back to switches for these when we don't need to POP_FRAME_OP on CATCH_TYPE:
		- if (s->type == Scope::CATCH_TYPE || s->type == Scope::FINALLY_TYPE) emit(Processor::POP_FRAME_OP);

	* don't like the outputCode solution, setting / resetting stuff manually isn't good programming style

	* fast lookup of operators (some clever quick hashing)
		- can't do normal quick-hashing since it requires string length... perhaps I can develop a quick hashing that matches beginning of strings only?
			- it would be required to use && to never look beyond the max length of all "current candidates"

	* couldn't we share identical strings in the same engine? any disadvantage to that?
		- we did for a while (shared constants with stdlib etc), but it went away when I added the blocking eval() etc utility functions and I believe there was even some performance benefit to *not* sharing (but why?)

	* simple constants pre-calculations
		- can we instantiate a small processor to do this?
		- problem is that we first emit the left constant then compile the right constant and in case we have something like `(a,5)+(b,6)` the opcode order will be: a,5,b,6,+ ... how can we then remove the first 5?
		- I guess we need to temporarily change output (as usual) for the second operand (if first is constant) *or* remove an earlier element (never done before)
		- Preliminary tests found little to gain in practice cause you rarely have complicated constants without involvment of variables.

	* instead of flushing/discarding results of statements directly, couldn't we keep them until the next statement? i.e. eliminating stuff like "WRITE_INDEXED #-1", "POP", "READ_INDEXED #-1" (except when branch targets of course)

	* I dropped the std::map for defined constants lookup of Value->index (thus getting rid of almost all STL). Now I simply iterate through all constants in the codedef. It actually improved profiled times quite a bit. Not sure why, but either std::map was slow to iterate during gc or it takes a lot of time to build up / tear down?
		- it *is* too slow to iterate through all constants with extreme source files (x * 10k) ... should do something better

GC
==

	* take a shot at generational gc
		- couldn't it work if we just make sure that a reference from old -> new gen protects the item in new gen until we sweep the old gen?
		- actually, I don't think we should think new and old gen... we should think standard heap and "sleepy" heap..
		- we could do this on an object level: sleepy object has a different setter that checks -> new gen references, but how can we change object class on the fly? I suppose we can't, which would mean a flag for this = slightly yucky.

