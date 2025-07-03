> print(parseInt(''))
< NaN
-
> print(parseInt('  notAnInt  '))
< NaN
-
> print(parseInt('3'))
< 3
-
> print(parseInt('-3'))
< -3
-
> print(parseInt('   -3'))
< -3
-
> print(parseInt('   +3'))
< 3
-
> print(parseInt('   - 3'))
< NaN
-
> print(parseInt('  \n \t  3333'))
< 3333
-
> print(parseInt('  \n \t  0x10'))
< 16
-
> print(parseInt('  \n \t  0x101010'))
< 1052688
-
> print(parseInt('  \n \t  0x101010koko'))
< 1052688
-
> print(parseInt('  \n \t  0x101010   \n'))
< 1052688
-
> print(parseInt('0x1234', 16))
< 4660
-
> print(parseInt('1234', 16))
< 4660
-
> print(parseInt('1234', 15))
< 3874
-
> print(parseInt('1234', 14))
< 3182
-
> print(parseInt('1234', 13))
< 2578
-
> print(parseInt('1234', 35))
< 45434
-
> print(parseInt('1234', 36))
< 49360
-
> print(parseInt('1234z', 36))
< 1776995
-
> print(parseInt('1234y', 36))
< 1776994
-
> print(parseInt('1234', 37))
< NaN
-
> print(parseInt('1234', -1))
< NaN
-
> print(parseInt('1234', -0.5))
< 1234
-
> print(parseInt({ toString: function() { return "2345" } }, { valueOf: function() { return 7 } }))
< 866
-
