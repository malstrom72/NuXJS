> print(String.prototype.indexOf.hasOwnProperty('length'))
< true
-
> print(delete String.prototype.indexOf.length)
< false
-
> print(String.prototype.indexOf.hasOwnProperty('length'))
< true
-
> print("abc".indexOf("b"))
< 1
-
> print(Array.prototype.push.hasOwnProperty('length'))
< true
-
> print(delete Array.prototype.push.length)
< false
-
> print(Array.prototype.push.hasOwnProperty('length'))
< true
-
> a=[1];a.push(2);print(a.length)
< 2
-
> print(parseInt.hasOwnProperty('length'))
< true
-
> print(delete parseInt.length)
< false
-
> print(parseInt.hasOwnProperty('length'))
< true
-
> print(parseInt('42', 10))
< 42
-
> print(Date.hasOwnProperty('length'))
< true
-
> print(delete Date.length)
< false
-
> print(Date.hasOwnProperty('length'))
< true
-
> print(new Date(0).getUTCFullYear())
< 1970
-
