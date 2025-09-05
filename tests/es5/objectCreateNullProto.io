> o = Object.create(null);
> print(Object.getPrototypeOf(o) === null);
< true
> print('toString' in o);
< false
> o.x = 1;
> print(o.x);
< 1
-
