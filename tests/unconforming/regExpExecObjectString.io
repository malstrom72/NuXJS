> var r=/a[a-z]{2,4}/.exec(new Object("abcdefghi"))
> print(r[0])
> print(r.index)
< abcde
< 0
-
