// ES5.1 14.1 / 10.4.3: in a strict function an unbound `this` is undefined (no global-object substitution).
> function f() { "use strict"; return this; }
> print(f() === undefined)
< true
-
// A non-strict function still substitutes the global object.
> function g() { return this; }
> print(g() === this)
< true
-
// A method call binds `this` to the receiver object even in strict mode.
> var o = { m: function () { "use strict"; return this; } };
> print(o.m() === o)
< true
-
// Global "use strict" makes the whole program strict; nested functions inherit it.
> "use strict";
> function h() { return this; }
> print(h() === undefined)
> var obj = { m: function () { return this === obj; } };
> print(obj.m())
< true
< true
-
// Strict propagates into nested function expressions and accessor bodies.
> function outer() { "use strict"; return function () { return this; }; }
> print(outer()() === undefined)
> var s = { get p() { "use strict"; return this === s; } };
> print(s.p)
< true
< true
-
// A strict inner function is strict even when the outer function is not.
> function nonstrict() { return (function () { "use strict"; return this; })(); }
> print(nonstrict() === undefined)
< true
-
// Strict does not leak the other way: a non-strict sibling still gets the global object.
> function withStrict() { "use strict"; }
> function sibling() { return this; }
> print(sibling() === this)
< true
-
// A leading string that is part of a larger expression is not a directive.
> function notADirective() { ("use strict"); return this; }
> print(notADirective() === this)
< true
> function alsoNot() { "use strict" + ""; return this; }
> print(alsoNot() === this)
< true
-
// A strict constructor binds `this` to the freshly created object.
> function C() { "use strict"; this.x = 42; }
> print(new C().x)
< 42
-
// 10.4.3 through 15.3.4.3 / .4 / .5: call, apply and bind hand a strict callee the this value verbatim, so a
// primitive stays a primitive rather than arriving as its wrapper. Checked against V8.
> function s() { "use strict"; return this; }
> var vals = [5, "x", true], out = [];
> for (var i = 0; i < vals.length; ++i) out.push(typeof s.call(vals[i]) + " " + typeof s.apply(vals[i]) + " " + typeof s.bind(vals[i])());
> print(out.join("|"))
< number number number|string string string|boolean boolean boolean
-
// Identity, not merely the type: it is the very value handed in.
> function s() { "use strict"; return this; }
> print([s.call(5) === 5, s.apply("x") === "x", s.bind(true)() === true].join(" "))
< true true true
-
// null and undefined reach a strict callee unchanged, and an unbound `this` is undefined.
> function s() { "use strict"; return this; }
> print([s.call(null) === null, s.apply(undefined) === undefined, s.bind(null)() === null, s() === undefined].join(" "))
< true true true true
-
// The non-strict rows are the ones that must keep boxing, 10.4.3 running ToObject on entry.
> function n() { return this; }
> var vals = [5, "x", true], out = [];
> for (var i = 0; i < vals.length; ++i) out.push(Object.prototype.toString.call(n.call(vals[i])));
> print(out.join(" "))
< [object Number] [object String] [object Boolean]
-
// The wrapper is never the primitive, but it carries the same value.
> function n() { return this; }
> print([n.call(5) === 5, n.call(5).valueOf() === 5, n.call("x") === "x", n.call("x").valueOf() === "x"].join(" "))
< false true false true
-
// null, undefined and an absent receiver all give a non-strict callee the global object.
> function n() { return this; }
> print([n.call(null) === this, n.apply(undefined) === this, n.bind(null)() === this, n() === this].join(" "))
< true true true true
-
// An object receiver is untouched in either mode, through all three entry points.
> function s() { "use strict"; return this; }
> function n() { return this; }
> var o = {};
> print([s.call(o) === o, s.apply(o) === o, s.bind(o)() === o, n.call(o) === o, n.apply(o) === o, n.bind(o)() === o].join(" "))
< true true true true true true
-
