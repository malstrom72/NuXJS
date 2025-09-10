// from v8 (0.3.9.5) test suite
> var foo = 'fisk';
> print(foo);
< fisk
-
> var foo;
> print(foo);
< fisk
-
> var foo = 'hest';
> print(foo)
< hest
-
> this.bar = 'fisk';
> print(bar)
< fisk
-
> var bar;
> print(bar)
< fisk
-
> var bar = 'hest';
> print(bar)
< hest
-
> this.baz = 'fisk';
> print(baz)
< fisk
-
> eval('var baz;');
> print(baz)
< fisk
-
> eval('var baz = "hest";');
> print(baz)
< hest
-
