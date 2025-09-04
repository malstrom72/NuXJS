> function Foo(){}
> var keys = [];
> for (var k in Foo) keys[keys.length] = k;
> print(keys.length);
< 0
-
> print(Object.keys(Foo).length);
< 0
-
> print('prototype' in Foo);
< true
-
> print(Object.prototype.propertyIsEnumerable.call(Foo, 'prototype'));
< false
-
