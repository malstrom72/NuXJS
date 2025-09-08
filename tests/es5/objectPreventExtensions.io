> var o = {a:1};
> print(Object.isExtensible(o));
< true
-
> print(Object.preventExtensions(o) === o);
< true
-
> print(Object.isExtensible(o));
< false
-
> o.b = 2;
> print("b" in o);
< false
-
> o.a = 3;
> print(o.a);
< 3
