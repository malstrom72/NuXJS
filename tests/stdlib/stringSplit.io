> print("abcd".split("").toString())
< a,b,c,d
-
> print("abcd".split().toString())
< abcd
-
> print("abcd".split("b").toString())
< a,cd
-
> print("".split("").length)
< 0
-
> print("".split("x").length)
< 1
-
> print("..a..b..c..d..".split("..").toString())
< ,a,b,c,d,
-
> print("ab".split(/a*?/).toString())
< a,b
-
> print("ab".split(/a*/).toString())
< ,b
-
> print("a.b,c;d".split(/[.,;]/).toString())
< a,b,c,d
-
> print("a.b,c;d".split(/([.,;])/).toString())
< a,.,b,,,c,;,d
-
> print("A<B>bold</B>and<CODE>coded</CODE>".split(/<(\/)?([^<>]+)>/).toString())
< A,,B,bold,/,B,and,,CODE,coded,/,CODE,
-
> var x
> var __split = new String("1undefined").split(x);
> print(typeof __split)
< object
-
> print(__split.constructor === Array)
< true
-
> print(__split.length)
< 1
-
> print(__split[0])
< 1undefined
-
