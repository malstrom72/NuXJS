> print((function() { var x; try { try { x = 1; return x; } finally { x = 2; return x*2 } } finally { x = 3; return x*3 } })())
< 9
-
