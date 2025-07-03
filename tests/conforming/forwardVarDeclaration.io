> (function() { var x = x; print(x) })();
< undefined
-
> var x = 'outer'; (function() { x = x; var x; print(x) })(); print(x)
< undefined
< outer
-
