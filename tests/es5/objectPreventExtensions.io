> var o = {a:1};
> print(Object.isExtensible(o));
> print(Object.preventExtensions(o) === o);
> print(Object.isExtensible(o));
> o.b = 2;
> print("b" in o);
> o.a = 3;
> print(o.a);
