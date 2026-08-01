TODO
####

Run-time
========

	* Make gc async/incremental in the sense that you actively and repeatdly call it until it is done (doesn't block native cpu, even if it "blocks" vm cpu).

	* FIXED 2026-08-01 (es5 only, found 2026-07-30): a strict function referencing `arguments` that threw an exception caught by JS segfaulted the process on the next sweep. Regression test in tests/es5/strictArgumentsThrowUseAfterFree.io.
		- the arguments/FunctionScope link is a weak pair by design: the scope's pointer to the object is strong and marked, the object's `scope` back-link is deliberately unmarked so that an escaped `arguments` never pins a whole closure alive. Both can therefore die in the same sweep, and what makes that safe is that each destructor severs the other's pointer (~FunctionScope calls detach(), which promotes the alias into an owned copy; ~Arguments clears FunctionScope::arguments). GCList::deleteAll destructs one item at a time, so whoever dies first finds the other still valid. The protocol is correct and ES3 was never at risk.
		- what broke it: 10.6 non-mapped (strict) arguments reused `scope == 0` to mean "not aliased to the parameter slots", which also erased the back-link, so a strict object never severed and ~FunctionScope was left calling detach() on freed memory. One field, two meanings; the ES5 path needed to change only one of them.
		- fix: `scope` is now the back-link in both modes and isMapped() answers the aliasing question, so the strict ctor takes the scope like the mapped one does. detach() on a non-mapped object just clears the link, since its values were captured at entry. es3 release binary verified byte-identical.
		- NOT fixed, separate issue: throwVirtualException resumes at firstCatcher->frame without popping the frames in between, so Scope::leave() never runs for them and those scopes are left to the GC instead of being destroyed deterministically. That is what made the crash reachable, and it is a real leak in ES3 too, but it is shared code so a fix changes the es3 binary unless #if-guarded.

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


Compiler
========

	
	* 7.1: strip Unicode format-control (Cf) characters - LRM (U+200E), RLM (U+200F), ZWNJ (U+200C), ZWJ (U+200D), BOM (U+FEFF) - from the source before lexing. ES3 removes them *everywhere*, even inside string/regexp literals (so they'd need \uXXXX to appear in a string). Currently NOT done: a BOM/LRM etc. in code gives a SyntaxError, and they survive as chars inside string literals (e.g. "a<BOM>b".length is 3, should be 2).

	* 7.2 whitespace: the explicitly-listed chars are handled and tested (tests/conforming/variousUnicodeSpaces.io covers TAB/VT/FF/SP/NBSP plus the 7.3 terminators LF/CR/LS/PS). The only thing not covered is the open-ended "Other category Zs" catch-all (the rare U+2000..U+200A, U+3000, U+1680, U+202F); those currently SyntaxError between tokens. Marginal - low priority.

GC
==

Stdlib
======

	* toFixed should convert to string with full exact decimals, e.g. (1000000000000000128).toFixed(0) should return "1000000000000000128" and not "1000000000000000100".

	* es5 only: a strict function that reaches `arguments` INDIRECTLY gets the wrong values. `Code::usesArguments` is set by a purely lexical scan for the identifier (Compiler, `compilingFor == FOR_FUNCTION`), and only then does the FunctionScope ctor capture argv at entry. Reach it through `eval` or `with` instead and `getDynamicVars` builds the non-mapped object from `localsPointer`, i.e. the parameter slots as they are NOW, so a non-mapped object silently behaves like a mapped one snapshotted late.
		- `eval("(function (a) { 'use strict'; a = 9; return eval('arguments[0]'); })")(1)` gives 9; V8 and 10.6 say 1. Written lexically (`return arguments[0]`) it correctly gives 1.
		- fix: stop deriving "must capture" from the lexical scan for strict functions and always capture at entry. The eager path in the FunctionScope ctor is already unconditional-capable; `getUsesArguments()` is only an allocation optimisation, and for strict functions it is an unsound one.

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

