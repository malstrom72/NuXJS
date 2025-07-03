> a=[]
-
> print(a.length)
< 0
-
> a[0xFFFFFFFF]='z'
-
> print(a.length)
< 0
-
> print(a[0xFFFFFFFF])
< z
-
> a[0xFFFFFFFE]='z'
-
> print(a.length)
< 4294967295
-
> print(a[a.length - 1])
< z
-
