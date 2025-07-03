> print(Object.getPrototypeOf(Error) == Function.prototype)
< true
-
> print(Object.getPrototypeOf(Error.prototype) == Object.prototype)
< true
-
> print(Object.getPrototypeOf(RangeError) == Function.prototype)
< true
-
> print(Object.getPrototypeOf(RangeError.prototype) == Error.prototype)
< true
-
> print(Object.prototype.toString.call(RangeError.prototype))
< [object Error]
-
