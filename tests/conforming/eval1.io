> (function() { var x = 3; eval("var x = 5"); print(delete x); print(typeof x); print(x); })();
< false
< number
< 5
-
> (function() { eval("var x = 3"); eval("var x = 5"); print(delete x); print(typeof x); })();
< true
< undefined
-
> (function x() { eval("var x = 3"); eval("var x = 5"); print(typeof x); print(delete x); print(typeof x); })();
< number
< true
< function
-
> (function f() { eval("var x = 3"); eval("var x = 5"); print(delete x); print(typeof x); })();
< true
< undefined
-
> (function() { var x = 3; eval("function x() { }"); print(typeof x); print(delete x); print(typeof x); })();
< function
< false
< function
-
> (function() { var x = 123; try { throw "up"; } catch (x) { eval("function x() { };"); print(typeof x) }; print(typeof x); })();
< string
< function
-
> (function() { var x = 123; try { throw "up"; } catch (x) { eval("var x = function() { }"); print(typeof x) }; print(typeof x); })();
< function
< number
-
