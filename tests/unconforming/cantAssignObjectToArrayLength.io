> a=[]
> o={valueOf:function() { return 23 }}
> print(o+10)
< 33

> a.length=o
> print(a.length)
< 23

> o={valueOf:function() { return 47 }}
> s='length';
> a[s]=o
> print(a.length)
< 47
-
