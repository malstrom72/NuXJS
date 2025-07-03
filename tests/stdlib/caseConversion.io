> print("".toUpperCase())
< 
-
> print("abcd".toUpperCase())
< ABCD
-
> print("ABCD".toLowerCase())
< abcd
-
> print("\u038e".toUpperCase().length)
< 1
-
> print("\u038e".toUpperCase().charCodeAt(0).toString(16))
< 38e
-
> print("\u03cd".toUpperCase().charCodeAt(0).toString(16))
< 38e
-
> print("\u03cd".toLowerCase().length)
< 1
-
> print("\u038e".toLowerCase().charCodeAt(0).toString(16))
< 3cd
-
> print("\u03cd".toLowerCase().charCodeAt(0).toString(16))
< 3cd
-
> print("\u1e98".toUpperCase().length)
< 2
-
> print("\u1e98".toUpperCase().charCodeAt(1).toString(16))
< 30a
-
> print("\u1e98\uff47\u1fe3".toUpperCase().length)
< 6
-
> var s="\u1e98\uff47\u1fe3".toUpperCase(); for (i = 0; i < s.length; ++i) print(s.charCodeAt(i).toString(16))
< 77
< 30a
< ff27
< 3c5
< 308
< 301
-
> print("abcd".toLocaleUpperCase())
< ABCD
-
> print("ABCD".toLocaleLowerCase())
< abcd
-
