> print("hej".charAt(0))
< h
-
> print("hej".charAt(2))
< j
-
> print("hej".charAt(3))
< 
-
> print("hej".charAt(+Infinity))
< 
-
> print("hej".charAt(-1))
< 
-
> print("hej".charAt(-0.1))
< h
-
> print("hej".charAt(0.1))
< h
-
> print("hej".charAt(0.999))
< h
-
> print("hej".charAt(1.3))
< e
-
> print("hej".charAt(NaN))
< h
-
> print(String.prototype.charAt.call({ toString: function() { return "abcd" } }, { valueOf: function() { return 2 } }))
< c
-
