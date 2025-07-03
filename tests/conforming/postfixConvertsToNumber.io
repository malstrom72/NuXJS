> var x = true;
> var y = x--;
> print(y)
< 1
-
> print(x)
< 0
-
> var o = { };
> o.x = true;
> var y = o.x--;
> print(y)
< 1
-
> print(o.x)
< 0
-
> var a = [ ];
> a[0] = true;
> var y = a[0]--;
> print(y)
< 1
-
> print(a[0])
< 0
-
> o={valueOf:function() { return "111"; }}
> print(o+333)
> print((o++)+333)
< 111333
< 444
-
