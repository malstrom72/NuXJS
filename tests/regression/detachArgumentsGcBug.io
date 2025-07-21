> function make(){ return arguments }
-
> make(1,2,3)
> gc();gc();gc();
> var base = gc().postCount
> var ok = true
> for(var n=0;n<50;n++){
>   make(1,2,3)
>   gc();gc();gc();
>   if(gc().postCount!==base) { ok=false; break }
> }
> print(ok)
> gc();gc();gc();
< true
