> var n = new Number(42); print(n.toJSON());
< 42
-
> print(new Number(NaN).toJSON());
< null
-
> print((-Infinity).toJSON());
< null
-
