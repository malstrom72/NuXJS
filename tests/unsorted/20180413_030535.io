> (function() { x=1;23;out:{ try { switch (x) { case 1: print("hej"); try { switch(x) { case 1: 3; return 99; } } finally { print("nif"); break out };break; case 2: print("du");58 } } finally { print("fin");29 } } })()
< hej
< nif
< fin
-
> print((function() { x=1;23;out:{ try { switch (x) { case 1: print("hej"); try { switch(x) { case 1: 3; return 99; } } finally { print("nif"); break out };break; case 2: print("du");58 } } finally { print("fin");29 } } })())
< hej
< nif
< fin
< undefined
-
> print((function() { x=1;23;out:{ try { switch (x) { case 1: print("hej"); try { switch(x) { case 1: 3; } } finally { print("nif"); break out };break; case 2: print("du");58 } } finally { print("fin");29 } } })())
< hej
< nif
< fin
< undefined
-
> print((function() { x=1;23;out:{ try { switch (x) { case 1: print("hej"); try { switch(x) { case 1: 3; } } finally { print("nif"); return 99; break out };break; case 2: print("du");58 } } finally { print("fin");29 } } })())
< hej
< nif
< fin
< 99
-
> print((function() { x=1;23;out:{ try { switch (x) { case 1: print("hej"); try { switch(x) { case 1: 3; } } finally { print("nif"); break out };break; case 2: print("du");58 } } finally { print("fin");29; return 99 } } })())
< hej
< nif
< fin
< 99
-
