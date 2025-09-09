> a=[1,2,3]
> print(a.length)
< 3
-
> a.length=true
> print(a.length)
< 1
-
> a.length=false
> print(a.length)
< 0
-
> a.length=80
> print(a.length)
< 80
-
> a.length="234"
> print(a.length)
< 234
-
> a.length="234.456"
! !!!! RangeError: Invalid array length
-
> a.length=-1
! !!!! RangeError: Invalid array length
-
> a.length=null
! !!!! RangeError: Invalid array length
-
> a.length=void 0
! !!!! RangeError: Invalid array length
-
