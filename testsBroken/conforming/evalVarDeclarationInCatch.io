> (function() { var x = 7; try { throw "x" } catch (x) { x = 9; eval("var x = 11, y = 5"); print(x) }; print(x); print(y) })()
< 11
< 7
< 5
-
> (function() { var x = 7; try { throw "x" } catch (x) { x = 9; eval("for (var x = 0; x < 10; ++x);"); print(x) }; print(x); })()
< 10
< 7
-
