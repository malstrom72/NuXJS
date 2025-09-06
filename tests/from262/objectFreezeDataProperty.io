> var obj = { foo: 10 };
> Object.freeze(obj);
> var desc = Object.getOwnPropertyDescriptor(obj, 'foo');
> print(desc.writable === false);
> print(desc.configurable === false);
> obj.foo = 20;
> print(obj.foo);
> delete obj.foo;
> print(Object.prototype.hasOwnProperty.call(obj, 'foo'));
< true
< true
< 10
< true
-
