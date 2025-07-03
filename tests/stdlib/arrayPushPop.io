> a=[]
> print(a.push(12, 34, 56, 78))
< 4
-
> print(a.push("last"))
< 5
-
> print(a.pop())
< last
-
> print(a.pop())
< 78
-
> print(a.pop())
< 56
-
> print(a.pop())
< 34
-
> print(a.pop())
< 12
-
> print(a.pop())
< undefined
-
> print(a.length)
> print(''+a)
< 0
< 
-
> o={pop:Array.prototype.pop}
> print(o.pop())
> print(o.length)
< undefined
< 0
-
> o={length:3.3}
> print(Array.prototype.push.call(o, 'a', 'b', 'c'))
< 6
-
> print(Array.prototype.pop.call(o))
< c
-
