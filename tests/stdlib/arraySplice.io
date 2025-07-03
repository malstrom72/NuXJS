> a=['a','b','c','d','e'];
> print(a.toString())
< a,b,c,d,e
-
> print((a.splice(2,2)).toString())
> print(a.toString())
< c,d
< a,b,e
-
> print((a.splice(1,0,"i","j","k","l")).toString())
> print(a.toString())
< 
< a,i,j,k,l,b,e
-
> print((a.splice(2,2,"m","n","o","p")).toString())
> print(a.toString())
< j,k
< a,i,m,n,o,p,l,b,e
-
> print((a.splice(2,4,"q","r")).toString())
> print(a.toString())
< m,n,o,p
< a,i,q,r,l,b,e
-
> print((a.splice(-2,1)).toString())
> print(a.toString())
< b
< a,i,q,r,l,e
-
> print((a.splice(-100,2)).toString())
> print(a.toString())
< a,i
< q,r,l,e
-
> print((a.splice(0,-10)).toString())
> print(a.toString())
< 
< q,r,l,e
-
> print((a.splice(100,100,"z")).toString())
> print(a.toString())
< 
< q,r,l,e,z
-
> print((a.splice(2)).toString())
> print(a.toString())
< l,e,z
< q,r
-
> print((a.splice()).toString())
> print(a.toString())
< 
< q,r
-
> a = [1,2,3,4,5];
> print((a.splice(3,undefined)).toString())
> print(a.toString())
< 
< 1,2,3,4,5
-
> a = [1,2,3,4,5];
> print((a.splice(-2)).toString())
> print(a.toString())
< 4,5
< 1,2,3
-
> a=['a',,'c','d','e',,];
> print(a.toString())
< a,,c,d,e,
-
> print((a.splice(2,2)).toString())
> print(a.toString())
< c,d
< a,,e,
-
> print((a.splice(1,0,"i","j","k","l")).toString())
> print(a.toString())
< 
< a,i,j,k,l,,e,
-
> print((a.splice(2,2,"m","n","o","p")).toString())
> print(a.toString())
< j,k
< a,i,m,n,o,p,l,,e,
-
> print((a.splice(2,4,"q","r")).toString())
> print(a.toString())
< m,n,o,p
< a,i,q,r,l,,e,
-
> print((a.splice(-4)).toString())
> print(a.toString())
< l,,e,
< a,i,q,r
-
> print((a.splice(-10000000000)).toString())
> print(a.toString())
< a,i,q,r
< 
-
> o = {splice:Array.prototype.splice,length:5,"0":"z","1":"x","2":"y","3":"c","4":"v"};
> o.splice(0,3,"b")
> for (var i = 0; i < 5; ++i) print(o[i])
< b
< c
< v
< undefined
< undefined
-
