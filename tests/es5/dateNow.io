> print(typeof Date.now);
< function
-
> delta = Math.abs(Date.now() - new Date().getTime());
-
> print(delta < 10);
< true
-
