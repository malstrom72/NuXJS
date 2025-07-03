> print(eval('"hej";for (i in [1,2,3,4]) { i*3; }'))
< 9
-
> print(eval('"hej";for (i in [1,2,3,4]) { if (i==2) break; i*3; }'))
< 3
-
> print(eval('"hej";for (i in []) { if (i==2) break; i*3; }'))
< hej
-
> (function() { "hej";for (i in [1,2,3,4]) { if (i==2) break; print(i*3); } })()
< 0
< 3
-
> (function() { "hej";for (i in [1,2,3,4]) { if (i==2) continue; print(i*3); } })()
< 0
< 3
< 9
-
