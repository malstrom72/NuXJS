> a=[]
> print(a.length)
< 0
> a=[,]
> print(a.length)
< 1
> a=[   ,    ]
> print(a.length)
< 1
> a= [ , , ]
> print(a.length)
< 2
> a = [ 1, 2, 3, 4, 5 ]
> print(a.length)
< 5
> a = [ 1,2,,,4,5 ]
> print(a.length)
< 6
> print(a.toString())
< 1,2,,,4,5
> a = [1,2,,,,,]
> print(a.toString())
< 1,2,,,,
> Array.prototype[1]='x'
> a=[1,,,,,4]
> print(a.toString())
< 1,x,,,,4
