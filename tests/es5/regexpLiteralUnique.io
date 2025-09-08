> var a = /a/, b = /a/;
> print(a === b);
< false
-
> function make() { return /b/; }
> print(make() === make());
< false
-
