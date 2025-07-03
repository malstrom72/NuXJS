> print("abcd".charCodeAt(0))
< 97
-
> print("abcd".charCodeAt(1))
< 98
-
> print("abcd".charCodeAt(0.5))
< 97
-
> print("abcd".charCodeAt(-0.3))
< 97
-
> print("abcd".charCodeAt(-0.999999))
< 97
-
> print("abcd".charCodeAt(-1))
< NaN
-
> print("abcd".charCodeAt(Infinity))
< NaN
-
> print("abcd".charCodeAt(NaN))
< 97
-
> print("abcd".charCodeAt(4))
< NaN
-
> print("abcd".charCodeAt(3))
< 100
-
> print("\u9876".charCodeAt(0))
< 39030
-
> print(String.prototype.charCodeAt.call({ toString: function() { return "ABCD" } }, 3))
< 68
-
