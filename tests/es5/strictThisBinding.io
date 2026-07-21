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
