// ES5.1 7.6 / 7.6.1.2 / 13.1: in strict code a function's own name may be neither eval nor arguments nor a
// FutureReservedWord. The name is parsed before the body, so a function made strict by its own directive prologue
// only reaches the check retroactively, once the body has settled code->strict.
> function check(src) { try { eval(src); print("accepted") } catch (e) { print(e.name) } }
-
// Strictness from the function's own directive: declarations.
> check("function interface() { 'use strict' }")
< SyntaxError
> check("function package() { 'use strict' }")
< SyntaxError
> check("function yield() { 'use strict' }")
< SyntaxError
> check("function implements() { 'use strict' }")
< SyntaxError
> check("function eval() { 'use strict' }")
< SyntaxError
> check("function arguments() { 'use strict' }")
< SyntaxError
-
// The same, as named function expressions, where the name binds only inside the function itself.
> check("(function interface() { 'use strict' })")
< SyntaxError
> check("(function static() { 'use strict' })")
< SyntaxError
> check("(function eval() { 'use strict' })")
< SyntaxError
-
// Strictness inherited from enclosing code, which the identifier parser rejects up front.
> check("'use strict'; function interface() {}")
< SyntaxError
> check("'use strict'; (function private() {})")
< SyntaxError
-
// Parameters are checked retroactively too, by the same predicate.
> check("function f(interface) { 'use strict' }")
< SyntaxError
> check("function f(a, arguments) { 'use strict' }")
< SyntaxError
> check("function f(a, a) { 'use strict' }")
< SyntaxError
-
// A nested strict function inside a non-strict one still checks its own name.
> check("function outer() { function interface() { 'use strict' } }")
< SyntaxError
-
// Reserved only in strict code: the very same names are legal identifiers in non-strict code.
> check("function interface() { return 1 }")
< accepted
> check("(function package() {})")
< accepted
> check("function f(interface, yield) { return interface + yield }")
< accepted
> check("function eval() { return 1 }")
< accepted
-
// Words reserved in every edition stay SyntaxErrors regardless of strictness, and ordinary names stay legal.
> check("function this() {}")
< SyntaxError
> check("function ok() { 'use strict'; return 1 }")
< accepted
> print((function letters() { "use strict"; return typeof letters })())
< function
-
// A strict function may still be called `undefined` or `NaN`: those are properties, not reserved words.
> check("function undefined() { 'use strict' }")
< accepted
-
// The rule is about the `function Identifier` terminal, and an 11.1.5 accessor has none: it is named with a
// PropertyName, which is an IdentifierName and so admits every reserved word. The whole 7.6.1.2 list plus eval and
// arguments is legal there, as a getter and as a setter, and the value still comes back through the accessor.
> var WORDS = "eval arguments implements interface let package private protected public static yield".split(" ");
> function accessor(w, src) { try { return eval(src) } catch (e) { return w + ":" + e.name } }
> var bad = [];
> for (var i = 0; i < WORDS.length; ++i) {
>	var w = WORDS[i];
>	if (accessor(w, "'use strict'; ({ get " + w + "() { return 1 } })['" + w + "']") !== 1) bad.push(w + ":get");
>	if (accessor(w, "'use strict'; ({ set " + w + "(v) { this.got = v }, got: 0 }).got") !== 0) bad.push(w + ":set");
>	if (accessor(w, "({ get " + w + "() { return 2 } })['" + w + "']") !== 2) bad.push(w + ":sloppy");
> }
> print(WORDS.length + " words, failures: " + (bad.length === 0 ? "none" : bad.join(" ")))
< 11 words, failures: none
-
// The setter's parameter list is a different 11.1.5 clause and keeps its own rule, so eval and arguments are still
// rejected there - and so is a FutureReservedWord, being an Identifier like any other parameter.
> check("'use strict'; ({ set x(eval) {} })")
< SyntaxError
> check("'use strict'; ({ set x(arguments) {} })")
< SyntaxError
> check("'use strict'; ({ set x(static) {} })")
< SyntaxError
> check("({ set x(eval) {} })")
< accepted
-
