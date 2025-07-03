> var globals = this;
> function f() { print(typeof this); print(this === globals); }
> f.call(5)
< object
< false
-
> f.call('asdf')
< object
< false
-
> f.call(null)
< object
< true
-
