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
