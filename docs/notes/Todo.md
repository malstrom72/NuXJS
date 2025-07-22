TODO
####

Run-time
========

	* Make gc async/incremental in the sense that you actively and repeatdly call it until it is done (doesn't block native cpu, even if it "blocks" vm cpu).

	* is the logic correct when changing array length containing a few undeletable elements?

	* exception what() should be the one doing the conversion job etc (because exception constructors should never have a risk of throwing), but how can we do that without a heap?
		- actually I think we should merge ScriptException and Exception, no point in having a separate Exception

	* CompilationError is a hack to get access to error line number when using the high-level API. It is problematic because if you catch a compilation error in Javascript you lose this information. Also, it would be neat to have a full stack trace in exceptions for run-time errors. But this is not a standard part of ES3 of course.


Compiler
========

	
	* strip LEFT-TO-RIGHT MARK or RIGHT-TO-LEFT MARK from source-code according to 7.1 in ES3 spec.

	* do we support all whitespaces as described in 7.2?

GC
==

Stdlib
======

	* toFixed should convert to string with full exact decimals, e.g. (1000000000000000128).toFixed(0) should return "1000000000000000128" and not "1000000000000000100".

LOW PRIO
########

Run-time
========

	* I don't know but the "emulation" in arguments object feels a bit over the top (registering deleted items etc)

	* perhaps it would have been better to split Frame into different pointers (more similar to ES-spec): one for running code (not changed by catch and with), one for variable object (not changed by catch, with or eval) and "current scope object" (changed by them all). This way we wouldn't have to declare so many dummy virtuals that just passes stuff upwards the Frame chain.

	* array object (length property support, optimized for numerical indexes?)
		- ok, one thought: normally an array only contains a continuous array (with start and end)... when too many items are (or are to become) undefined, or when non-integer elements are added, convert to a normal ScriptObject (accessed as through a proxy now)
		- more thoughts: use different compressed variations (templates) when type is homogenous over all the array, e.g. number array, object array, string array. One could even consider an int array.

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

