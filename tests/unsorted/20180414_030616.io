> print((function() { for (var i = 0; i < 10; ++i) { print(i); try { try { return 1 } finally {  } } finally { continue } } })())
< 0
< 1
< 2
< 3
< 4
< 5
< 6
< 7
< 8
< 9
< undefined
-
> print((function() { for (var i = 0; i < 10; ++i) { print(i); try { try { throw "up" } finally {  } } finally { continue } } })())
< 0
< 1
< 2
< 3
< 4
< 5
< 6
< 7
< 8
< 9
< undefined
-
> 
-
