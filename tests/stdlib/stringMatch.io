> print(("abcd".match("bcd")).join(','))
< bcd
-
> print(("abc".match("((a)|(ab))((c)|(bc))")).join(','))
< abc,a,a,,bc,,bc
-
> print(("abcdef".match("a()(b)c")).join(','))
< abc,,b
-
> print(("abcdef".match(/abc/)).join('.'))
< abc
-
> print(("abcdef".match(/.(d)./)).join(','))
< cde,d
-
> print(("abcdef".match(/123/)))
< null
-
> print(("abcdefabc".match(/abc/g)).join(','))
< abc,abc
-
> print(("a1a2a3b1b2b3".match(/.1/g)).join(','))
< a1,b1
-
> print(("a1a2a3b1b2b3".match(/../g)).join(','))
< a1,a2,a3,b1,b2,b3
-
> print(("a1a2a3b1b2b3".match(/..|()/g)).join(','))
< a1,a2,a3,b1,b2,b3,
-
> print(("a1a2a3b1b2b3".match(/()|../g)).join(','))
< ,,,,,,,,,,,,
-
> print(("a1a2a3b1b2b3".match(/(a.a.)|(.1)/g)).join(','))
< a1a2,b1
-
> print("a1a2a3b1b2b3".match(/123/g))
< null
-
> r=/abc/
> r.exec=function() { print("nope") }
> print("abc".match(r).join(','))
< abc
-
> RegExp.prototype.exec=function() { print("nope") }
> print("abc".match(r).join(','))
< abc
-
> print("abcd".match())
< [object Array]
-
> print("abcd".match().length)
< 1
-
> print("abcd".match()[0])
< 
-
