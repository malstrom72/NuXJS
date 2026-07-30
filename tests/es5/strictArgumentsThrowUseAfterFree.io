// A strict function that references `arguments` and throws an exception caught by JS leaves a dangling Arguments
// object behind, and the process dies with a use-after-free the next time the heap is swept. Three landed pieces
// combine:
//   1. FunctionScope's constructor eagerly builds a non-mapped Arguments for a strict function whose body mentions
//      `arguments` (ES5.1 10.6). Nothing else holds a reference to it.
//   2. throwVirtualException resumes at firstCatcher->frame without popping the frames in between, so
//      Scope::leave() never runs for them and those FunctionScopes are abandoned rather than destroyed.
//   3. The sweep destroys both, and ~FunctionScope calls arguments->detach() on an Arguments that may already be
//      gone. detach() then reads a poisoned scope pointer (0xa9a9a9a9a9a9a9a9) through Scope::getLocalsPointer().
// The underlying hazard, a GC object's destructor dereferencing another GC object during sweep, is latent in ES3
// too; only the ES5 strict path makes it reachable. Clean in the es3 build, clean without "use strict", and clean
// when the body never mentions `arguments`.
// Disabled with `*` because it takes the whole harness down rather than failing a section. Re-enable with the fix.
*
> var f = eval("(function () { 'use strict'; var n = arguments.length; throw new TypeError('boom'); })"); try { f(1, 2); } catch (e) { print("caught " + e.name); } print("ok")
< caught TypeError
< ok
-
