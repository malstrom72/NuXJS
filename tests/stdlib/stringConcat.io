> print("abcd".concat("efgh"))
< abcdefgh
-
> print("abcd".concat("efgh", "ijkl"))
< abcdefghijkl
-
> print("abcd".concat(1,2,3,4,5))
< abcd12345
-
> print("abcd".concat())
< abcd
-
> print("abcd".concat({ toString: function() { return "qwerty" } }))
< abcdqwerty
-
> print("abcd".concat({ valueOf: function() { return "qwerty" } }))
< abcd[object Object]
-
