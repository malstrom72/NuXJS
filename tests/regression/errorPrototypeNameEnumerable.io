// CLI:
> var e=new Error("msg")
> var seen=false
> for (var p in e) if (p==="name") seen=true
> print(seen)
< false
-
