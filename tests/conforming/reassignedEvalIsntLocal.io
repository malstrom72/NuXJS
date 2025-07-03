> i=9999
> f=function(i) { return e("(function() { return ++i })"); }
> e=eval
-
> g=f(111)
-
> print(g())
< 10000
-
