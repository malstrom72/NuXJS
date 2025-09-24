// CLI:
> var x=[]
> x[4294967295]=1
> print(x.length)
< 0
-
> print(x["4294967295"])
< 1
-
> x[-1]=2
> print(x.length)
< 0
-
> print(x["-1"])
< 2
-
> x[true]=3
> print(x.length)
< 0
-
> print(x["true"])
< 3
-
> print(x[1])
< undefined
-
