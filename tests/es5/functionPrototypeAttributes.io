> function Foo(){}
> var desc = Object.getOwnPropertyDescriptor(Foo, 'prototype');
> print(desc.writable);
< true
-
> print(desc.enumerable);
< false
-
> print(desc.configurable);
< false
-
> desc = Object.getOwnPropertyDescriptor(Foo, 'name');
> print(desc.writable);
< false
-
> print(desc.enumerable);
< false
-
> print(desc.configurable);
< true
-
