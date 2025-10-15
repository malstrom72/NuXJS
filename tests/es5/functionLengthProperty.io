> function f(a, b){}
> print(f.length);
< 2
-
> f.length = 5;
> print(f.length);
< 2
-
> print(delete f.length);
< false
-
> print(f.length);
< 2
-
