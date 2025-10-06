> var obj = {}
> obj.shift = Array.prototype.shift
> obj[0] = "x"
> obj[1] = "y"
> obj.length = -4294967294
> print(obj.shift())
< x
> print(obj.length)
< 1
> print(obj[0])
< y
> print(obj[1])
< undefined
