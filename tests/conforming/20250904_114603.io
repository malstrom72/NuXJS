// 15.4: only a property name that is an unsigned 32-bit integer *below* 2^32-1 is an array index, so
// a["4294967295"] is an ordinary property and leaves length alone, while a["4294967294"] is the last legal
// index and pushes length to 2^32-1.
> a=[]
> a["4294967295"]=1
> print(a.length)
< 0
> a["4294967294"]=2
> print(a.length)
< 4294967295
> print(a["4294967295"])
< 1
> print(a["4294967294"])
< 2
-
