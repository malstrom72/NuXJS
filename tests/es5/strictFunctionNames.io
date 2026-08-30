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
