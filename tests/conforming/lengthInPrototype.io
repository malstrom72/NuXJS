> o = function() { }; o.prototype = new String("pok")
-
> x = new o
-
> print(x.length)
< 3
-
> x.length = 5
-
> print(x.length)
< 3
-
> print(delete x.length)
< true
-
> print(typeof x.length)
< number
-
> print(x.length)
< 3
-
