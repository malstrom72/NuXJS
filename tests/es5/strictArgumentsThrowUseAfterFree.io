// Regression: a strict function that references `arguments` and throws an exception caught by JS used to segfault
// the process on the next sweep.
//
// An arguments object and its FunctionScope are linked both ways: the scope holds a strong, marked pointer to the
// object, while the object's `scope` back-link is deliberately weak (see the note in NuXJS.h) so that holding on
// to an escaped `arguments` never pins a whole closure alive. Both may therefore become garbage in the same sweep,
// and the protocol that makes that safe is that each destructor severs the other's pointer: ~FunctionScope calls
// detach(), which promotes the alias into an owned copy, and ~Arguments clears FunctionScope::arguments. Since
// GCList::deleteAll destructs one item at a time, whichever dies first finds the other still valid, so order does
// not matter.
//
// 10.6 non-mapped (strict) arguments broke that invariant by reusing `scope == 0` to mean "not aliased to the
// parameter slots", which also erased the back-link. A strict arguments object then never severed, so
// ~FunctionScope was left calling detach() on freed memory, reading a poisoned scope pointer through
// Scope::getLocalsPointer(). It only bit when the scope died by sweep rather than by Scope::leave(), which is what
// an exception does: throwVirtualException resumes at the catcher's frame without popping the frames in between.
//
// The fix separates the two meanings: `scope` is the back-link in both modes, and isMapped() answers the aliasing
// question. ES3 is unaffected, and was never at risk, because its arguments object always kept the back-link.
> var f = eval("(function () { 'use strict'; var n = arguments.length; throw new TypeError('boom'); })"); try { f(1, 2); } catch (e) { print("caught " + e.name); } print("ok")
< caught TypeError
< ok
-
// The mapped (non-strict) half of the same protocol, which must keep working: `arguments` aliases the live
// parameter slots while the frame is running, and an escaped object keeps its values after the frame is gone.
> function f(a) { a = 9; return arguments[0]; } print(f(1))
< 9
> function f(a) { arguments[0] = 9; return a; } print(f(1))
< 9
> function f(a) { return arguments; } var g = f(7); print(g[0] + " " + g.length)
< 7 1
-
// An escaped strict arguments object is non-mapped: it keeps the values captured at entry, and writes to it do
// not reach the parameter, nor does assigning the parameter reach it.
> var f = eval("(function (a) { 'use strict'; a = 9; return arguments[0]; })"); print(f(1))
< 1
> var f = eval("(function (a) { 'use strict'; arguments[0] = 9; return a; })"); print(f(1))
< 1
> var f = eval("(function (a) { 'use strict'; return arguments; })"); var g = f(7); print(g[0] + " " + g.length)
< 7 1
-
// Throwing repeatedly from both modes, with enough allocation in between to force sweeps, must stay clean.
> var s = eval("(function () { 'use strict'; return arguments.length; })"); var n = eval("(function () { return arguments.length; })"); var t = eval("(function () { 'use strict'; var q = arguments.length; throw new Error('x'); })"); for (var i = 0; i < 500; ++i) { try { t(i, i); } catch (e) { } s(i); n(i); ({ pad: i }); } print("survived " + i)
< survived 500
-
