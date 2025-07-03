> a=function() { b = function() { c = function() { return d++ }; return c; }; var d = 23 ; return b }
> b=a()()
> print(b());
> print(b());
> print(b());
> print(b());
< 23
< 24
< 25
< 26
-
