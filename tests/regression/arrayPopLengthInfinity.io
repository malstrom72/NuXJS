// CLI:
> obj={}
> obj.length=Number.POSITIVE_INFINITY
> obj.pop=Array.prototype.pop
> print(obj.pop())
< undefined
-
> print(obj.length)
< 0
-
