> print(eval("var q =\u30001; q"))
< 1
-
> print(eval("var q =\u1680\u202f1; q"))
< 1
-
> print(Number("\u16801"))
< 1
-
> print(parseInt("\u202f1"))
< 1
-
> print(/\s/.test("\u200b"))
< true
-
> print(/\s/.test("\u180e"))
< false
-
> print(isNaN(Number("\u180e1")))
< true
-
> print("\u2000\u2001\u2002\u2003\u2004\u2005\u2006\u2007\u2008\u2009\u200a".replace(/\s/g, "").length)
< 0
-
