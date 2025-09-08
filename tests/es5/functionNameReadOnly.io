> function Foo(){}
> var desc = Object.getOwnPropertyDescriptor(Foo, 'name');
> print(desc.writable);
< false
-
> Foo.name = 'Bar';
> print(Foo.name);
< Foo
