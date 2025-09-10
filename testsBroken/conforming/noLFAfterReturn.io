> print(function() { return /* no lf */ 3 }());
< 3
-
> print(function() { return
> 3 }());
< undefined
-
> print(function() { return /*
> */ 3 }());
< undefined
-
> print(function(){return//
> 3}());
< undefined
-
