> x=1;23;out:{ try { switch (x) { case 1: print("hej");switch(x) { case 1: 3; break out };break; case 2: print("du");58 } } finally { print("fin");29;break out } }
< hej
< fin
-
> function f() { x=1;23;out:{ try { switch (x) { case 1: print("hej");switch(x) { case 1: 3; break out };break; case 2: print("du");58 } } finally { print("fin");29;break out } } }
-
> f()
< hej
< fin
-
> x=1;23;out:{ try { switch (x) { case 1: print("hej");switch(x) { case 1: 3; break out };break; case 2: print("du");58 } } finally { print("fin");29;break out } }
< hej
< fin
-
> x=1;23;out:{ try { switch (x) { case 1: print("hej");switch(x) { case 1: 3; break out };break; case 2: print("du");58 } } finally { print("fin");29 } }
< hej
< fin
-
> x=1;23;out:{ try { switch (x) { case 1: print("hej"); try { switch(x) { case 1: 3; break out } } finally { print("nif") };break; case 2: print("du");58 } } finally { print("fin");29 } }
< hej
< nif
< fin
-
> x=1;23;out:{ try { switch (x) { case 1: print("hej"); try { switch(x) { case 1: 3; break out } } finally { print("nif"); break out };break; case 2: print("du");58 } } finally { print("fin");29 } }
< hej
< nif
< fin
-
