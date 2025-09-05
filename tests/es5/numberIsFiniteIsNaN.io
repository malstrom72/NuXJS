> print(Number.isNaN(NaN));
< true
-
> print(Number.isNaN('foo'));
< false
-
> print(Number.isNaN(0/0));
< true
-
> print(Number.isFinite(1/0));
< false
-
> print(Number.isFinite(1));
< true
-
> print(Number.isFinite('10'));
< false
-
> print(Number.isFinite(NaN));
< false
-
