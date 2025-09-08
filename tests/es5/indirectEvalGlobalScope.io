> var x = 3;
> (function() { var x = 1; var e = eval; print(e('x')); })();
< 3
-
> (function() { var e = eval; e('var z = 5;'); })();
> print(z);
< 5
-
