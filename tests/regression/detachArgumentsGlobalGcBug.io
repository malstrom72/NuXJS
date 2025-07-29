> g=null
-
> f=function() { var lastG=g; g=arguments }
-
> f(3,5);gc();gc();gc();
> var base = gc().postCount
> var ok = true
> for(var n=0;n<50;n++){
>   f(3,5);
>   gc();gc();gc();
>   if(gc().postCount!==base) { ok=false; break }
> }
> print(ok)
> gc();gc();gc();
< true

