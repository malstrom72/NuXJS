> obj={}
> obj.shift=Array.prototype.shift
> obj[0]='x'
> obj[1]='y'
> obj.length=-4294967294
> print(obj.shift())
< undefined
-
> print(obj.length)
< 0
-
> print(obj[0])
< x
-
> print(obj[1])
< y
-
