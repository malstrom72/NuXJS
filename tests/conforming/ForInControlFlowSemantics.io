> print(eval('1234;for (i in [1,2,3]) 525'))
< 525
-
> print(eval('1234;for (i in []) 525'))
< 1234
-
> (function(o) { 1234;for (i in o) print(i); })([23,57,99])
< 0
< 1
< 2
-
> (function(o) { out: for (i in o) break; })([23])
-
> (function(o) { out: for (i in o) break out; })([23])
-
> (function(o) { for (i in o) continue; })([23])
-
> (function(o) { x: for (i in o) continue x; })([23])
-
> (function(o) { x: y: for (i in o) continue x; })([23])
-
> (function(o) { x: y: for (i in o) continue y; })([23])
-
> (function(o) { x: y: for (i in o) if (false) continue y; })([23])
-
> (function(o) { x: y: for (i in o) { for (i in o) if (false) continue y; } })([23])
-
