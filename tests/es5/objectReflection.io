// ES5.1 15.2.3.3 Object.getOwnPropertyDescriptor + FromPropertyDescriptor (8.10.4).
// A plain assigned property is writable, enumerable, and configurable.
> var o = { a: 1 };
> var d = Object.getOwnPropertyDescriptor(o, "a");
> print([d.value, d.writable, d.enumerable, d.configurable].join(","))
< 1,true,true,true
> print("get" in d); print("set" in d)
< false
< false
-
// defineProperty with only a value leaves the other data attributes at their false defaults.
> Object.defineProperty(o, "h", { value: 2 });
> var dh = Object.getOwnPropertyDescriptor(o, "h");
> print([dh.value, dh.writable, dh.enumerable, dh.configurable].join(","))
< 2,false,false,false
-
// An accessor descriptor reports get/set (not value/writable).
> var ac = {}; Object.defineProperty(ac, "p", { get: function () { return 9; }, enumerable: true });
> var da = Object.getOwnPropertyDescriptor(ac, "p");
> print([typeof da.get, da.set === undefined, da.enumerable, da.configurable, ("value" in da), ("writable" in da)].join(","))
< function,true,true,false,false,false
-
// A missing own property yields undefined; inherited properties are not own.
> print(Object.getOwnPropertyDescriptor(o, "nope"))
< undefined
> function F() {} F.prototype.inherited = 1;
> print(Object.getOwnPropertyDescriptor(new F(), "inherited"))
< undefined
-
// 15.2.3.14 Object.keys: own enumerable string keys (order is for-in order; sorted here for stability).
> print(Object.keys({ a: 1, b: 2, c: 3 }).sort().join(","))
< a,b,c
> var K = {}; Object.defineProperty(K, "hidden", { value: 1, enumerable: false }); K.shown = 2;
> print(Object.keys(K).join(","))
< shown
> print(Object.keys([10, 20, 30]).join(","))
< 0,1,2
> print(Object.keys({}).length)
< 0
-
// keys only lists own, not inherited enumerable properties.
> function G() { this.own = 1; } G.prototype.proto = 2;
> print(Object.keys(new G()).join(","))
< own
-
// 15.2.3.2 Object.getPrototypeOf.
> print(Object.getPrototypeOf(new F()) === F.prototype)
< true
> print(Object.getPrototypeOf({}) === Object.prototype)
< true
-
// 15.2.3.x step 1: non-object arguments throw a TypeError.
> try { Object.keys(5); } catch (e) { print(e.name) }
< TypeError
> try { Object.getOwnPropertyDescriptor("s", "length"); } catch (e) { print(e.name) }
< TypeError
> try { Object.getPrototypeOf(null); } catch (e) { print(e.name) }
< TypeError
-
