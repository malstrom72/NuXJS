// ES5.1 15.2.3.6 Object.defineProperty / 8.12.9 [[DefineOwnProperty]] / 8.10.5 ToPropertyDescriptor.
// A new property's absent attribute fields default to false (8.12.9 step 4).
> var o = {}; Object.defineProperty(o, "x", { value: 42, enumerable: true });
> print(o.x)
< 42
> o.x = 99; print(o.x)
< 42
> var ks = []; for (var k in o) ks.push(k); print(ks.join(","))
< x
> print(delete o.x)
< false
-
// Accessor properties: get/set run with this bound to the receiver.
> var d = { _v: 1 };
> Object.defineProperty(d, "p", { get: function () { return this._v; }, set: function (v) { this._v = v; }, configurable: true });
> print(d.p); d.p = 7; print(d.p)
< 1
< 7
-
// 8.12.9 step 7/10: a non-configurable, non-writable property rejects value and writable-up redefinition,
// but writable may still go true -> false.
> var nc = {}; Object.defineProperty(nc, "c", { value: 1 });
> try { Object.defineProperty(nc, "c", { value: 2 }); } catch (e) { print(e.name) } print(nc.c)
< TypeError
< 1
> try { Object.defineProperty(nc, "c", { configurable: true }); } catch (e) { print(e.name) }
< TypeError
> try { Object.defineProperty(nc, "c", { enumerable: true }); } catch (e) { print(e.name) }
< TypeError
> Object.defineProperty(nc, "c", { value: 1 }); print("noop-redefine-ok")
< noop-redefine-ok
-
> var w = {}; Object.defineProperty(w, "v", { value: 1, writable: true, configurable: false });
> Object.defineProperty(w, "v", { writable: false }); w.v = 2; print(w.v)
< 1
> try { Object.defineProperty(w, "v", { writable: true }); } catch (e) { print(e.name) }
< TypeError
-
// 8.12.9 step 9: data <-> accessor conversion is allowed only when configurable.
> var cv = {}; Object.defineProperty(cv, "a", { value: 5, configurable: true });
> Object.defineProperty(cv, "a", { get: function () { return 9; } }); print(cv.a)
< 9
> Object.defineProperty(cv, "a", { value: 3, writable: true, configurable: true }); print(cv.a); cv.a = 4; print(cv.a)
< 3
< 4
> var frozenKind = {}; Object.defineProperty(frozenKind, "k", { value: 1 });
> try { Object.defineProperty(frozenKind, "k", { get: function () {} }); } catch (e) { print(e.name) }
< TypeError
-
// 15.2.3.7 Object.defineProperties applies each own enumerable descriptor.
> var m = {};
> Object.defineProperties(m, { a: { value: 1, enumerable: true }, b: { get: function () { return 2; }, enumerable: true } });
> print(m.a + m.b)
< 3
-
// 8.10.5 ToPropertyDescriptor rejects invalid attribute objects.
> try { Object.defineProperty({}, "z", { value: 1, get: function () {} }); } catch (e) { print(e.name) }
< TypeError
> try { Object.defineProperty({}, "z", { get: 5 }); } catch (e) { print(e.name) }
< TypeError
> try { Object.defineProperty({}, "z", "not an object"); } catch (e) { print(e.name) }
< TypeError
-
// 15.2.3.6 step 1: non-object target throws.
> try { Object.defineProperty(42, "z", {}); } catch (e) { print(e.name) }
< TypeError
-
// Works on functions; named properties work on arrays.
> var f = function () {}; Object.defineProperty(f, "g", { value: 1, enumerable: true }); print(f.g)
< 1
> var arr = [1, 2]; Object.defineProperty(arr, "foo", { value: "F", enumerable: true }); print(arr.foo); print(arr.length)
< F
< 2
-
// Arrays run the real 15.4.5.1, so an accessor on an index works too. Length maintenance, truncation and every
// reject path live in tests/es5/arrayDefineOwnProperty.io.
> var arr = [1, 2, 3]; Object.defineProperty(arr, "0", { value: 9, writable: true, enumerable: true, configurable: true });
> print(arr[0]); print(arr.length)
< 9
< 3
> var arr = [1, 2, 3]; Object.defineProperty(arr, "length", { value: 1 }); print(arr.length)
< 1
> var arr = [1]; Object.defineProperty(arr, "1", { get: function () { return 5; } }); print(arr[1] + " " + arr.length)
< 5 2
-
// 15.2.3.6 step 2 / 15.2.3.3 step 2 convert P with ToString, which is hint String: toString runs before valueOf.
// A "" + P concatenation would take the hint Number path and name the property "vo" instead.
> var key = { toString: function () { return "ts" }, valueOf: function () { return "vo" } };
> var o = {}; Object.defineProperty(o, key, { value: 7, enumerable: true });
> print(Object.getOwnPropertyNames(o).join("|"))
< ts
> print(Object.getOwnPropertyDescriptor(o, key).value)
< 7
> print("" + key)
< vo
-
