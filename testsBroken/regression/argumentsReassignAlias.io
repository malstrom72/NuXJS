> f=function(a,b) { var args = arguments; args[0]=123; print(a); }
> f(3,5)
< 123
-
> f()
< undefined
-
> f=function(a,b) { var args = arguments; arguments = { }; args[0] = 234; print(a); }
> f(3,5)
< 234
-
> f()
< undefined
-
> f=function() { var a = arguments; gc(); return [ a, function() { gc(); return a[1]; } ] }
> ag=f(5,6,7);
> a=ag[0];
> g=ag[1];
> gc();
> print(a[1]);
> print(g());
> delete a[1];
> gc();
> print(a[1]);
> print(g());
< 6
< 6
< undefined
< undefined
-
> f=function() { var a = arguments; gc(); return [ a, function() { gc(); return a[1]; } ] }
> ag=f(5,6,7);
> a=ag[0];
> g=ag[1];
> gc();
> print(a[1]);
> print(g());
> delete a[1];
> gc();
> print(a[1]);
> print(g());
< 6
< 6
< undefined
< undefined
-
