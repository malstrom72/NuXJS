> (function() { var i = 1; (function() { var j = 2; eval("var k = 3"); (function() { eval("print(i); print(j); print(k)") })() })() })()
< 1
< 2
< 3
-
> (function() { var i = 1; (function() { var j = 2; eval("var k = 3"); (function() { print(i); print(j); print(k) })() })() })()
< 1
< 2
< 3
-
> (function() { var i = 1; var k = 5; (function() { var j = 2; eval("var k = 3"); (function() { print(i); print(j); print(k) })() })() })()
< 1
< 2
< 3
-
