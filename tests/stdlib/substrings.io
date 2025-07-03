> print("abcd".substring())
< abcd
-
> print("abcd".substr())
< abcd
-
> print("abcd".substring(0))
< abcd
-
> print("abcd".substr(0))
< abcd
-
> print("abcd".substring(1))
< bcd
-
> print("abcd".substr(1))
< bcd
-
> print("abcd".substring(-1))
< abcd
-
> print("abcd".substr(-1))
< d
-
> print("abcd".substr(-2))
< cd
-
> print("abcd".substr(-0.5))
< abcd
-
> print("abcd".substring(0.3))
< abcd
-
> print("abcd".substr(0.3))
< abcd
-
> print("abcd".substring(0, 2))
< ab
-
> print("abcd".substr(0, 2))
< ab
-
> print("abcd".substring(1, 2))
< b
-
> print("abcd".substr(1, 2))
< bc
-
> print("abcd".substring(-1234, 1234))
< abcd
-
> print("abcd".substr(-1234, 1234))
< abcd
-
> print("abcd".substring(1.4, 2.3))
< b
-
> print("abcd".substr(1.4, 2.3))
< bc
-
> print("abcd".substring("1", "3"))
< bc
-
> print("abcd".substr("1", "2"))
< bc
-
> print("abcd".substring(3, 1))
< bc
-
> print("abcd".substring(2.1, 1.9))
< b
-
> print(String.prototype.substring.call({ toString: function() { return "abcdefgh" }, valueOf: function() { return 0 } }, { toString: function() { return "9999" }, valueOf: function() { return "1" } }, { toString: function() { return "9999" }, valueOf: function() { return "3.3" } }))
< bc
-
> print(String.prototype.substr.call({ toString: function() { return "abcdefgh" }, valueOf: function() { return 0 } }, { toString: function() { return "9999" }, valueOf: function() { return "1" } }, { toString: function() { return "9999" }, valueOf: function() { return "3.3" } }))
< bcd
-
