> var r=/a[a-z]{2,4}?/.exec({toString:function(){return "abcdefghi";}})
> print(r[0])
> print(r.index)
< abc
< 0
-
