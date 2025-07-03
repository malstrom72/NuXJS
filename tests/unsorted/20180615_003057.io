> String.prototype.toString = function() { return "zzz" }
> String.prototype.valueOf = function() { return "xxx" }
-
> s = new String("aaa")
-
> print(s.toString())
< zzz
-
> print('' + s)
< xxx
-
> print(JSON.stringify(s))
< "zzz"
-
