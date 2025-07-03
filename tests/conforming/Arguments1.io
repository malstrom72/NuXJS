> function f() { print(arguments[0]); print(arguments["0"]); print(arguments[" 0 "]); print(arguments["0.0"]); }
> f(1234)
< 1234
< 1234
< undefined
< undefined
-
> (function() { function arguments() { }; print(typeof arguments); })()
< function
-
> (function() { var arguments = 3; print(typeof arguments); })()
< number
-
> (function() { eval("function arguments() { };"); print(typeof arguments); })()
< function
-
> (function() { eval("var arguments = 3;"); print(typeof arguments); })()
< number
-
