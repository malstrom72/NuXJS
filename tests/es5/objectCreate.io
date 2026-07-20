// ES5.1 15.2.3.4 Object.getOwnPropertyNames: every own name, including non-enumerable (sorted for stability).
> var o = { a: 1 }; Object.defineProperty(o, "h", { value: 2, enumerable: false });
> print(Object.getOwnPropertyNames(o).sort().join(","))
< a,h
> print(Object.keys(o).join(","))
< a
-
// Arrays include indices and length; functions include length, name, prototype.
> print(Object.getOwnPropertyNames([10, 20]).sort().join(","))
< 0,1,length
> print(Object.getOwnPropertyNames(function () {}).sort().join(","))
< length,name,prototype
> print(Object.getOwnPropertyNames(Object("ab")).sort().join(","))
< 0,1,length
-
// 15.2.3.5 Object.create with a null prototype yields a bare object.
> var n = Object.create(null);
> print(Object.getPrototypeOf(n)); n.x = 1; print(n.x)
< null
< 1
-
// create links the new object to the given prototype.
> var proto = { greet: function () { return "hi"; } };
> var c = Object.create(proto);
> print(c.greet()); print(Object.getPrototypeOf(c) === proto); print(c.hasOwnProperty("greet"))
< hi
< true
< false
-
// The optional second argument runs Object.defineProperties.
> var w = Object.create(Object.prototype, { a: { value: 1, enumerable: true }, b: { get: function () { return 2; }, enumerable: true } });
> print(w.a + w.b); print(Object.keys(w).sort().join(","))
< 3
< a,b
-
// 15.2.3.4 step 1 / 15.2.3.5 step 1: bad arguments throw a TypeError.
> try { Object.getOwnPropertyNames(5); } catch (e) { print(e.name) }
< TypeError
> try { Object.create(42); } catch (e) { print(e.name) }
< TypeError
-
