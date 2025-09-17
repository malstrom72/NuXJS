> var obj = {}
> obj.push = Array.prototype.push
> obj.length = NaN
> print(obj.push(-1))
< 1
> print(obj.length)
< 1
> print(obj[0])
< -1
-
> obj = { push: Array.prototype.push }
> obj.length = Number.POSITIVE_INFINITY
> obj.push(-4)
! !!!! TypeError: Invalid array length
-
> print(obj.length)
< Infinity
> print(obj.hasOwnProperty("0"))
< false
-
> obj = { push: Array.prototype.push }
> obj.length = Number.NEGATIVE_INFINITY
> print(obj.push(-7))
< 1
> print(obj.length)
< 1
> print(obj[0])
< -7
-
> obj = { push: Array.prototype.push }
> obj.length = 4294967295
> obj.push(1, 2)
! !!!! TypeError: Invalid array length
-
> print(obj.length)
< 4294967295
> print("4294967295" in obj)
< false
