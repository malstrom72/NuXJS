> (function() { try { throw "oops" } catch (f) { function f() { print("yo") } }; print(typeof f); })()
< function
-
> (function() { try { throw "oops" } catch (f) { eval("function f() { print('yo') }") }; print(typeof f); })()
< function
-
> (function() { try { throw "oops" } catch (arguments) { eval("function arguments() { print('yo') }") }; print(typeof arguments); })()
< function
-
> (function x(a) { try { throw "oops" } catch (x) { eval("function x() { print('yo') }") }; print(typeof x); print(x.length) })()
< function
< 0
-
