> a=[1,2,3,4,5,6,7]
> print((b=a.slice()).toString())
> print(b==a)
< 1,2,3,4,5,6,7
< false
-
> print(a.slice(3).toString())
< 4,5,6,7
-
> print(a.slice(9).toString())
< 
-
> print(a.slice(-2).toString())
< 6,7
-
> print(a.slice(1,3).toString())
< 2,3
-
> print(a.slice(1,-1).toString())
< 2,3,4,5,6
-
> print(a.slice(1,-8).toString())
< 
-
> print(a.slice(0,-7).toString())
< 
-
> print(a.slice(0,-6).toString())
< 1
-
> print(a.slice(9,10).toString())
< 
-
> delete a[6]
> delete a[3]
> print(a.slice().toString())
< 1,2,3,,5,6,
-
> print(a.slice(-1).toString())
< 
-
