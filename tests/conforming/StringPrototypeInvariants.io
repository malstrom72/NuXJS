> print(String.prototype.length)
< 0
-
> print(typeof String.prototype.length)
< number
-
> print('x'+String.prototype+'y')
< xy
-
> String.prototype.toString = Object.prototype.toString
> print(String.prototype.toString())
< [object String]
-
