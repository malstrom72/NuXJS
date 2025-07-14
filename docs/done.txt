DONE
====

	* for (;;)

	* comma operator

	* void operator

	* delete operator

	* proper string comparisons (< etc)

	* also probe gcitems with gcheap == 0, so that we can have those safely on stack etc
		- thinking of dropping mark etc from gcheap and have in engine instead, we could then have a gcheap list for protected items (probe these before general mark phase)

	* break, continue etc (with labels!)

	* virtual machine should include gc etc

	* check that identifier is never one of the reserved words

	* drop the backwards jump for continue in while(), can jump down to the loop instead, for code simplicity (some day we'll do jump optimizations anyhow)

	* maybe drop the scope vector and just put it all on the program stack

	* switch

	* in operator

	* typeof operator

	* we could reuse free variable indexes in safeKeep (by having a way to "return" them and a queue with free ones), but it kind of feels like sub-optimization

	* for (in)
		- we need to decide what should happen when deleting members still...

	* prototype support

	* new operator
		- done, but need to implement prototype

	* only initialize Value to some BAD_TYPE in debug target, don't touch anything in release

	* native calls (and returns)
		- no synchronized return to native code right now
		- need easier API, shouldn't crash if missing push etc
		- arguments are reversed on native calls, and will be gc'd as stack has already popped 
			- arguments no longer reversed since we push forwards now, but will still be gc'd

	* assignable globals this in processor

	* function name() { } syntax

	* literal function names, e.g. myGlobalName = function myLocalName() { ... }

	* ++ should add numbers *only*, now "3"++ is "31", which is wrong

	* eval support
		- I think the if in the "if (compilingForEval) evalXR = makeRValue(evalXR);" lines are actually unnecessary? 
			- nope, they weren't
		- implement rest of eval r-value logic for do while, for, switch and try / catch (any more?)
			- while, for done, switch and try / catch done, I think, any more?	
		- global eval support (sets all var and function declarations in global this)

	* object literals

	* array literals

	* true primitive <-> object conversions

	* true toString, toNumber, which is problematic because we might have to execute JS-code then and I want to avoid synchronous callbacks to JS-code (=blocking!)

	* string -> number doesn't conform to the http://www.ecma-international.org/ecma-262/5.1/#sec-9.3.1 , e.g. empty string should be 0 , spaces should be accepted etc...

	* are we comparing NaN correctly? e.g. NaN !== NaN
		- yes

	* I am beginning to give up on the idea of avoiding the property attributes... we need Writable, Enumerable & Configurable... perhaps place them in the hash key?

	* vars added by eval should be deletable: f=function() { eval("var x = 42"); delete x; print(x); }

	* proper error exceptions (TypeError etc)

	* instanceof operator

	* should we? *) Doesn't consider unicode Line separator <LS> (\u2028) or Paragraph separator <PS> (\u2029) to be linefeeds. Only LF or CR. Also <NBSP> (\u00A0) and <ZWNBSP> ZERO WIDTH NO-BREAK SPACE (\uFEFF) are not considered white space.

	* (new) Object(v) should convert v to number, string object etc

	* toPrimitive also for native function arguments like sqrt etc, how?
		- stubs

	* (new String("abcd"))[2] should work again, cause it really is no difference from "abcd"[2] according to Ecma spec... this would mean a violation with strict ES 3, since this came in ES 5 first... but really, it is *so* useful (and common I guess).

	* arguments container
		- missing callee
			- that is, if we don't slaughter the whole stupid non-strict argument object and go for the simpler strict version

	* don't accept lf's after ++ etc (automatic ; insertion logic)

	* for in should also include properties in prototypes, except when they are shadowed... don't know if we should do this top-down or bottom-up
		- done, but not for strings and arguments objects

	* should "\/" be valid escape sequence? not according to ECMAScript spec, but JSON allows it right? (or wrong?)
		- actually, any \ that isn't escape is valid, \ is just swallowed see http://www.ecma-international.org/ecma-262/6.0/index.html#sec-literals-string-literals
		- also \<cr>|<crlf>|<lf>|<ls>|<ps> is valid and should continue string on next line
			- nope, not in ES3

	* this ES-262 test fails, why exactly, the number looks right:
		if (+(Number.MAX_VALUE) !== 1.7976931348623157e308) {

	* (1.0E-3 == 0.001) is not true (due to accuracy problems I guess), I think it should be
		- same problem with (0.003e3 == 3.0)

	* why is 0000nnn valid number in js, v8 etc? in ES 11.8.3 Numeric Literals it looks like a number need to start with a non-zero
		- because they support octals

	* fast allocation pools

	* automatic gc pace

	* with statement, it's actually not too bad... check http://stackoverflow.com/questions/61552/are-there-legitimate-uses-for-javascripts-with-statement
	
	* FIX : The SourceCharacter immediately following a NumericLiteral must not be an IdentifierStart or DecimalDigit.    For example:     3in     is an error and not the two input elements 3 and in.

	* also would be good if a["ko"] or a[3423] didn't create a OBJ_TO_STRING_OP, this looks really silly doesn't it?
		114:CONST #0
		116:OBJ_TO_STRING
		117:GET_PROPERTY

	* function.name is actually not a bad idea, although standardized first in ES6 (in a very complex manner where x = function() also get a name)...
		- good to have the name accessible for tracing/debugging (future stack-trace support?)
		- we have it now

	* let ExpressionResult remember if a value is already primitive, no need to make primitive again then, e.g. (5+a)*8 <- two TO_PRIMITIVE today, could be one

	* pop void optimization (almost always occurs with a return;)?

	* special write with pop instructions (very common)?

	* building arrays is slow because of:
			bool Object::setPropertyDeep(Engine& engine, const Value& key, const Value& v) {
				Value dummy;
				if (getOwnProperty(engine, key, &dummy) == NONEXISTENT) {
		getOwnProperty here will convert key to string (on heap!), just to check if it exists somewhere in the chain before setting the array element
		- did a trick

	* Split ScriptFrame -> GlobalFrame & ScriptFrame

	* ERASE_INDEXED_OP for quickly resetting safe kept variables, worth it? (three instructions now, void, write, pop)
		- safekept now on stack, no need anymore

	* change byte code to int code and check performance, or maybe the opposite, add byte, short etc immediates?
		- not too fond of the int cast in the byte array
		- 32-bit opcode with 24-bit operand seems pretty solid

	* safe-kept variables aren't resetted on early exits, e.g.
		b: switch (x) { case 1: switch(x) { case 2: break b } }
		won't reset the safe kept x's, so there is a risk this kind of code holds on to more garbage than necessary (but freed at function exit of course!)
		- safe-kept now on stack, not relevant any more

	* divide by 0 checks? NaN checks?
		- is currently not compatible with -ffast_math, which is bad I guess
		- also isnan is not standard C++ :(, on Windows it is called _isnan
		- do a special Value variation that tracks NAN and Infinities?
		- no, we require non-fast-math, and that's it

	* no need for recursive marking, just add to one end of the list and continue looping to the end of list
		- yeah, much better

	* switch statements could benefit from a JUMP_AND_POP_IF_TRUE so that we could REPUSH the control value instead of safekeeping it
		- safe-keeping on stack made this happen

	* if it wasn't for the problem with the value stack order in the return statement (i.e. the return expression has to be emitted before any "early exits pop's" etc are emitted) we wouldn't have to use safeKeep so much, but could just keep stuff on the stack and repush (e.g. the enumerator object for "for in")
		- actually, this isn't the case, case return expressions "safeKeep" before finally calls, not sure what the problem is to be honest, maybe we can keep stuff on the stack, could turn into many pops on early exits though
		- we now do safekeep on stack!

	* Global object should have standard object prototype, so e.g. 'toString' should be accessible as a global via Object.prototype

	* count (and run-time check) necessary value stack depth for functions
		- alternative have a low-rate check with a margin + make certain there is never a possibility to push more than x per instruction
			- we should build a VM test routine that checks each opcode, how much it changes the stack and stuff
			- we did something even better, a recursive stack depth code validator

	* global environment compiler (don't accept return etc)
		- global is really a function frame too, with vars that you can't delete etc...

	* exceptions (and catching both virtual and native)
		- only thing left is integration with C++ exceptions

	* Why don't we make Engine a GCItem too and gcMark whatever it has instead of "rooting" it?

	* quicker calls by using a frame stack for functions that do not create closures
		- problem is when we create closures with eval though, e.g. return(eval("(function(a,b) { return a+b+c })"));
		- two options: 1) copy frame (byte by byte) to heap when necessary, 2) make super-quick allocation possible and some flag to indicate direct destruction on exit (poor-man generational gc)
			- might be a third option: eval code that isn't executed via "eval" direct-call is treated differently according to http://www.ecma-international.org/ecma-262/5.1/#sec-10.4.2
		- another option would be to not require a frame *at all* for quick calls that doesn't have eval or sub-functions (is it possible?). Just allocate space on the value stack. But what to do with accepting too few arguments?
			- I think this is possible and we could copy the arguments like we do today
			- I've decided this is too complicated for v1.0 + setting up the value stack for this is about as complicated as allocating from our super-quick pool
		- third option: simply focus on making a fast mem pool instead
			- oh snap, it's the gc that's the main performance problem, not the allocation/freeing... gotta look into that
			- actually, I think it might be the CPU cache rather... reusing the same stack memory is much nicer to the CPU than spraying half the memory full with temporaries and then delete them...
		- fourth option: on scope pop: manual delete of scopes that are in the root gc list, on closure creation (= generate function): move all scopes above to "governed" gc list
			- sort of did that but have a flag instead cause 1) you might want scopes on the root list, 2) you also want the non-closure scopes to get gc'ed on exceptions etc and placing them in the root list will not do that

	* NEXT_PROPERTY_OP is always preceeded by READ_INDEXED (since it is always a non-constant safe-kept variable), combine into one instruction (with two operands)
		- if we don't do the REPUSH idea instead of safe-keeping so much
		- we now do

	* share constant pointers (strings etc) between each compiled unit, e.g. function in function will not share the same string pointers
		- I think they do now right?
		- they do

	* count actual memory allocated as in old NuXScript?
		- we do in pools

	* would be cleaner if we could pass a retValue pointer instead of taking a return value (but not nicer syntax for native calls returning tho, hmm, need to think)
		- we want nice, quick, safe and clean syntax for:

			a)	calling synchronously <-- not prio
				script: running vm code until return with option to set max count before error)
				native: call directly
				syntax: either { ret = function->call } or { processor->call(function }

			b)	calling asynchronously  <-- prio
				script: enter call ("chain"), user runs { while (processor->run()) { } }, return value is either popped { processor->getReturnValue() } or stored into a predesignated pointer
				native: chain a native call, syntax should be the same as for script

			c)	calling script async or native sync
				script: enter call ("chain"), user is notified and have the option to "while (run)" or alt. wait for returned value later (via pointer?? nah, probably not)
				native: call directly, return value pushed?

			d)	implementing native functions
				prios: little overhead (quick), error safe (args and maybe even return values are automatically gc protected)
				- so maybe argc is a bad idea, maybe we should have minimum fixed (which is also .length), like native functions

			alt 1: like today, native calls are direct and faster call sequence than script code (they access arguments directly on stack)
				pros:	fast
				cons:	wacky code to accomodate both synchronized native and asynchronized script function calls with little overhead
						harder to make safe
						can't form closures right?

			alt 2: native calls are "embedded" in script functions, they also get a frame, only difference is that they execute natively, probably via a dummy stub that calls the native code
				pros:	probably cleaner and easier to make safe (all args are protected by a frame object)
						an eval call could create a closure (but what would it access, I guess that would be up to the native function tho)
				cons:	slower, more garbage (frames)

			alt 1 is regarding functions in themselves to be either script or native

			alt 2 is regarding code to be either script or native

			IMPORTANT! There must be a call procedure that doesn't need to differentiate between script and native functions.

			- check futures/promises in C++11, is that something useful for chaining?

			- tested alt 2 (separating natives from script entirely), but decided to keep the original call design but call the low-level virtual for invoke(). Realized that you basically *never* want to asynchronously call more than one function at a time (why would you want to have an inverse list?). You can still do it of course, it's not illegal, but it is also not something we need to make easier.

	* at any point where we call a c++ virtual I think we should let the interpreter have a way to update-internals and possibly repeat the instruction. E.g. for implementing getters and setters.
		- in the future maybe

	* perhaps we should separate native and script calls after all... I think one wants to use script stubs for a lot of stuff. native calls could be looked up during compile time and made into super-quick constants
		- see above

	* lots of problems with gc safety and native calls / constructors: newed objects, methods, this values are not protected
		- push them temporarily last on stack
		-  or hold on, I think the entire gc approach needs rethinking, we should have something like gc(beyond) like in NuXScript...
		- actually, the problem isn't huge as we have an asynchronous vm, we could restrict gc to happen in "bottom" main loop
		- yeah, no biggie

	* setting array length needs to do a to_number, how to do this asynchronously?
		- we don't, and it is documented in ECMAViolations.md

	* we ought to have a min and max-roof, min before gc'ing at all, over max = error
		- gc is all under control now

	* so, it's definitely worth it to "consolidate" / "internalize" all strings so that all identifiers get the same pointer (proven by the chess benchmark). The question is: how do we do this thread agnostic?
		- there is also the "string sync" idea from old NuXScript... it could do something like { if (sameString && pointer < other.pointer && heap is 0 or mine) pointer = other.pointer } on all Values compared
			- the only problem is that it won't help stuff that is pushed on the stack only, e.g. a[x] = y <- both x and y are pushed data on stack and changing those pointers really won't help anyone :)
		- we're not going to do this

	* Sandboxing execution speed problem, at least in theory, with extreme proto chains. Each cycle can take a *very* long time.
		- simply prevent long proto chains somehow?
		- yeah, just preventing them to <= 32, should *always* be sufficient

	* Error classes like TypeError etc should not be used in stdlib but rather internal copies of these, in case user changes them.

	* also implement a max recursion on compiler to not overload stack (function in function in function etc)

	* basic library (math, string, array ops)

	* it would be nice if it wasn't so easy to forget that Value() didn't create an undefined type, have a SafeValue()? That also maybe even protects from garbage-collect, that would be nice :)
		- we have a Var now...

	* Must have $toPrimitiveNoHint as well, for + and == (I think those are the only ones). This is for Date() objects to work I guess. See 8.6.2.6 [[DefaultValue]] (hint)

	* Error classes like TypeError etc should not be used in stdlib but rather internal copies of these, in case user changes them.

	* better errors with line numbers and stuff (should we go back to the global "pickup" idea i had in old NuXScript?)
		- should pass char* in exception probably, as it is now new Compilers are created for each function compiling and the Compiler owns the char*, which means in a throw we lose the correct char*

	* max recursion on compiler for sandboxed mode

	* also, drop all STL dependencies, incl. std::string even, for simpler / older / stupid compiler compatibility and smaller footprint
		- all dropped except std::wstring
		- and that's ok

	* don't like that String inherits from Vector, so if you make a non-const String you can actually change it's contents, but hash and bloom-codes are then wrong (forever). Have a ConstVector base class, or is there an easier way? Shouldn't we inherit at all? answer: simple composition
