> function f() { print(typeof f); f = 3; print(typeof f); };
> f();
< function
< number
-
> function f2() { print(typeof f2); var f2 = 3; print(typeof f2); };
> f2();
< undefined
< number
-
> function f3() { print(typeof f3); eval("var f3 = 3"); print(typeof f3) };
> f3();
< function
< number
-
> (function f1() { print(typeof f1); f1 = 3; print(typeof f1); })();
< function
< function
-
> (function f2() { print(typeof f2); var f2 = 3; print(typeof f2); })();
< undefined
< number
-
> (function f3() { print(typeof f3); eval("var f3 = 3"); print(typeof f3) })();
< function
< number
-
> (function() { var f = 'outer'; (function f() { print(typeof f); print(delete f); print(typeof f); })(); })();
< function
< false
< function
-
> (function f4() { print(typeof f4); eval("var f4 = 3"); print(typeof f4); print(delete f4); print(typeof f4); })()
< function
< number
< true
< function
-
