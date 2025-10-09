> function f0(x) { switch (x) { case 1: print("hej");switch(x) { case 1: return 19283; };break; case 2: print("du"); return 478; } }
-
> print(f0(2))
< du
< 478
-
> print(f0(1))
< hej
< 19283
-
> function f1(x) { out: switch (x) { case 1: print("hej");switch(x) { case 1: break out; };break; case 2: print("du"); return 478; } }
-
> print(f1(0))
< undefined
-
> print(f1(2))
< du
< 478
-
> print(f1(1))
< hej
< undefined
-
> function f2(x) { out: { switch (x) { case 1: print("hej");switch(x) { case 1: break out; }; case 2: print("du"); return 478; }; print("here"); } }
-
> print(f2(1))
< hej
< undefined
-
> print(f2(2))
< du
< 478
-
> print(f2(3))
< here
< undefined
-
