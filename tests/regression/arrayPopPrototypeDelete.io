// CLI:
> Object.prototype[1]=-1
> Object.prototype.pop=Array.prototype.pop
> var x={0:0,1:1,length:2}
> print(x.pop())
< 1
-
> print(x[1])
< -1
-
> delete Object.prototype[1]
> delete Object.prototype.pop
