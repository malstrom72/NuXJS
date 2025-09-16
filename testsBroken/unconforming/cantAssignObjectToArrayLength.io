> a=[]
-
> o={valueOf:function() { return 23 }}
-
> print(o+10)
< 33
-
> a.length=o
! !!!! RangeError: Invalid array length
-
> print(a.length)
< 0
-
> o={valueOf:function() { return 47 }}
> s='length';
> a[s]=o
! !!!! RangeError: Invalid array length
-
> print(a.length)
< 0
-
