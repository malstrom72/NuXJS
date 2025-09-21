> a=[]
> a["0x3f"]=23
> print(a.length)
< 0
-
> a[4294967295]=45
> print(a.length)
< 0
-
> a["4294967295"]=45
> print(a.length)
< 0
-
> a[4294967296]=78
> print(a.length)
< 0
-
> a["4294967296"]=78
> print(a.length)
< 0
-
> a[5000000000]=91
> print(a.length)
< 0
-
> a["5000000000"]=91
> print(a.length)
< 0
-
> a[-1]=33
> print(a.length)
< 0
-
> a["-1"]=33
> print(a.length)
< 0
-
> a["0123"]=44
> print(a.length)
< 0
-
> a[""]=55
> print(a.length)
< 0
-
> a["12E"]=66
> print(a.length)
< 0
-
> a[4294967294]=101
> print(a.length)
< 4294967295
-
> a["4294967294"]=19
> print(a.length)
< 4294967295
-
> print(a[4294967294])
< 19
-
> b=[]
> for (var p in a) b.push(p)
> b.sort();
> print(b.join());
< ,-1,0123,0x3f,12E,4294967294,4294967295,4294967296,5000000000
-
