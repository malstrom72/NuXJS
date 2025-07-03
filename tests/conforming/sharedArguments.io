> a={}
> f = (function() { a[0]=5 })
> g = (function(p) { a=arguments; f(); print(p) })
> g(129)
< 5
-
> f = (function() { a[0]=25 })
> g = (function(p) { a=arguments; f(); return (function() { return p }) })
> h = g(388)
> print(h())
< 25
-
> a[0]=99
> print(h())
< 99
-
> f = (function(p) { return [ (function() { return p }), arguments ] })
> v = f(23,57,99);
> print(v[1][0]+','+v[1][1]+','+v[1][2]);
> print(v[0]())
> v[1][0] = 151
> print(v[0]())
< 23,57,99
< 23
< 151
-
