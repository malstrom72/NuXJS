> function f(a, b){
> var d = Object.getOwnPropertyDescriptor(arguments, "0");
> print(d.value);
> print(d.writable);
> print(d.enumerable);
> print(d.configurable);
> d = Object.getOwnPropertyDescriptor(arguments, "length");
> print(d.value);
> print(d.writable);
> print(d.enumerable);
> print(d.configurable);
> d = Object.getOwnPropertyDescriptor(arguments, "callee");
> print(d.value === f);
> print(d.writable);
> print(d.enumerable);
> print(d.configurable);
> }
> f(42, 17);
< 42
< true
< true
< true
< 2
< true
< false
< true
< true
< true
< false
< true
-

