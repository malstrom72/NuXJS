// CLI:
> Array.prototype[1] = -1
> var arr = [0, 1]
> arr.length = 2
> print(arr.shift())
< 0
> print(arr[0])
< 1
> print(arr[1])
< -1
> delete Array.prototype[1]
-
> Object.prototype[1] = -1
> Object.prototype.length = 2
> Object.prototype.shift = Array.prototype.shift
> var obj = {0: 0, 1: 1}
> print(obj.shift())
< 0
> print(obj[0])
< 1
> print(obj[1])
< -1
> print(obj.length)
< 1
> delete obj.length
> print(obj.length)
< 2
> delete Object.prototype[1]
> delete Object.prototype.length
> delete Object.prototype.shift
