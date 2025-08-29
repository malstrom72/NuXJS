> f=function(){ "use strict"; return this===undefined; }
> print(f())
< true
-
> g=function(){ return this===undefined; }
> print(g())
< false
-
