// CLI:
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
< !!!! RangeError: Invalid array length
< !!!! location: <anonymous>:1:19
< !!!! stack: RangeError: Invalid array length
<     at <anonymous>:1:19
-
> a.length=-1
< !!!! RangeError: Invalid array length
< !!!! location: <anonymous>:1:12
< !!!! stack: RangeError: Invalid array length
<     at <anonymous>:1:12
-
> a.length=null
> print(a.length)
< 0
-
> a.length=void 0
< !!!! RangeError: Invalid array length
< !!!! location: <anonymous>:1:16
< !!!! stack: RangeError: Invalid array length
<     at <anonymous>:1:16
-
