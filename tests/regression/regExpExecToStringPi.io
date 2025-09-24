// CLI:
> var r=/\.14/.exec({toString:function(){return Math.PI;}})
> print(r[0])
> print(r.index)
< .14
< 1
-
