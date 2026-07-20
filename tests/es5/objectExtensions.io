// ES5.1 15.2.3.10 Object.preventExtensions, 15.2.3.13 Object.isExtensible, 8.6.2 [[Extensible]].
// New objects (and arrays) are extensible.
> print(Object.isExtensible({}))
< true
> print(Object.isExtensible([]))
< true
> print(Object.isExtensible(function () {}))
< true
-
// preventExtensions returns the object and flips [[Extensible]] to false.
> var o = { a: 1 };
> print(Object.preventExtensions(o) === o)
< true
> print(Object.isExtensible(o))
< false
-
// 8.12.4 [[CanPut]]: a non-extensible object silently rejects new own properties (outside strict mode)...
> o.b = 2; print(o.b)
< undefined
// ...but existing properties remain writable and deletable (preventExtensions is not seal).
> o.a = 10; print(o.a)
< 10
> delete o.a; print(o.a)
< undefined
-
// A new own property that would shadow an inherited one is also refused when non-extensible.
> function F() {} F.prototype.p = "proto";
> var i = new F(); Object.preventExtensions(i); i.p = "own"; print(i.p); print(i.hasOwnProperty("p"))
< proto
< false
-
// 15.2.3.10 step 1 / 15.2.3.13 step 1: non-object argument throws a TypeError.
> try { Object.preventExtensions(42); } catch (e) { print(e.name) }
< TypeError
> try { Object.isExtensible("s"); } catch (e) { print(e.name) }
< TypeError
-
