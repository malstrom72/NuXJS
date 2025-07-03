> (function() { var x = 1; print(eval("x")) })()
< 1
-
> e=eval;
> x=3;
> (function() { var x = 1; print(e("x")) })()
< 3
-
> eval=(function() { return("reassigned") });
> (function() { var x = 1; print(eval("x")) })()
< reassigned
-
> eval=e;
> (function() { var x = 1; print(eval("x")) })()
< 1
-
