> var x = 3;
> eval("var props = { }");
> var count = 0;
> for (i in this) { props[i] = true; ++count; }
> var y = 5;
> print('x' in props);
> print('y' in props);
> print('i' in props);
> print('i' in this);
> print('props' in props);
> print('count' in props);
< true
< true
< false
< true
< true
< true
-
