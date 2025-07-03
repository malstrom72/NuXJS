> x=1
> switch (x) { case 1: print("hej") }
< hej
-
> print(eval('23;switch (x) { case 1: print("hej") }'))
< hej
< undefined
-
> x=2
-
> print(eval('23;switch (x) { case 1: print("hej") }'))
< 23
-
> x=3;print(eval('23;switch (x) { case 1: print("hej");switch(x) { case 1: 3 };break; case 2: print("du");58 }'))
< 23
-
> x=2;print(eval('23;switch (x) { case 1: print("hej");switch(x) { case 1: 3 };break; case 2: print("du");58 }'))
< du
< 58
-
> x=1;print(eval('23;switch (x) { case 1: print("hej");switch(x) { case 1: 3 };break; case 2: print("du");58 }'))
< hej
< 3
-
> x=1;print(eval('23;switch (x) { case 1: print("hej");switch(x) { case 1: 3 };break; case 2: print("du");58; default:99 }'))
< hej
< 3
-
> x=-1;print(eval('23;switch (x) { case 1: print("hej");switch(x) { case 1: 3 };break; case 2: print("du");58; default:99 }'))
< 99
-
