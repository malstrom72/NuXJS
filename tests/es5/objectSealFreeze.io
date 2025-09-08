> var o = {a:1};
> print(Object.isSealed(o));
< false
-
> Object.seal(o);
> print(Object.isSealed(o));
< true
-
> o.b = 2;
> print("b" in o);
< false
-
> delete o.a;
> print("a" in o);
< true
-
> Object.freeze(o);
> print(Object.isFrozen(o));
< true
-
> o.a = 3;
> print(o.a);
< 1
-
> delete o.a;
> print("a" in o);
< true
-
