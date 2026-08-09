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
< 57
< 30a
< ff27
< 3a5
< 308
< 301
-
> print("\xb5".toUpperCase().charCodeAt(0).toString(16))
< 39c
-
> var s="\u0149".toUpperCase(); print(s.charCodeAt(0).toString(16) + " " + s.charCodeAt(1).toString(16))
< 2bc 4e
-
> print("\u2126".toLowerCase().charCodeAt(0).toString(16))
< 3c9
-
> print("\u212a".toLowerCase().charCodeAt(0).toString(16))
< 6b
-
> print("\u10a0".toLowerCase().charCodeAt(0).toString(16))
< 10a0
-
> print("abcd".toLocaleUpperCase())
< ABCD
-
> print("ABCD".toLocaleLowerCase())
< abcd
-
