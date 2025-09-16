> o = { };
> Object.defineProperty(o, 'test', { value: 'x' })
> print(o.test)
< x
-
> o.test=7;
-
> print(o.test)
< x
-
> print(delete o.test)
< false
-
> print(o.test)
< x
-
> for (i in o) print(i)
-
> print(o.hasOwnProperty('test'));
< true
-
> print(o.propertyIsEnumerable('test'));
< false
-
> o = { };
> Object.defineProperty(o, 'test', { value: 'x', writable: true })
> print(o.test)
< x
-
> o.test=7;
-
> print(o.test)
< 7
-
> print(delete o.test)
< false
-
> print(o.test)
< 7
-
> for (i in o) print(i)
-
> print(o.hasOwnProperty('test'));
< true
-
> print(o.propertyIsEnumerable('test'));
< false
-
> o = { };
> Object.defineProperty(o, 'test', { value: 'x', configurable: true })
> print(o.test)
< x
-
> o.test=7;
-
> print(o.test)
< x
-
> print(delete o.test)
< true
-
> print(o.test)
< undefined
-
> for (i in o) print(i)
-
> print(o.hasOwnProperty('test'));
< false
-
> print(o.propertyIsEnumerable('test'));
< false
-
> o = { };
> Object.defineProperty(o, 'test', { value: 'x', enumerable: true })
> print(o.test)
< x
-
> o.test=7;
-
> print(o.test)
< x
-
> print(delete o.test)
< false
-
> print(o.test)
< x
-
> for (i in o) print(i)
< test
-
> print(o.hasOwnProperty('test'));
< true
-
> print(o.propertyIsEnumerable('test'));
< true
-
