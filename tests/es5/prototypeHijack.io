// The ES5 library shares one object graph with the script, so nothing in it may reach a helper through a method or
// a global binding that the script can replace (docs/Standard Library Guidelines.md, PRIO 1). Every hijack below
// used to change an answer. The damage persists for the rest of the file, so keep new tests ahead of it or in a
// file of their own.
> var realCall = Function.prototype.call, realObject = Object;
> var seal = Object.seal, freeze = Object.freeze, isSealed = Object.isSealed, isFrozen = Object.isFrozen;
> var create = Object.create, defineProperties = Object.defineProperties, gopd = Object.getOwnPropertyDescriptor;
> print(typeof realCall + " " + typeof seal + " " + typeof create)
< function function function
-
// String.prototype.charCodeAt and .substring: 15.5.4.20 trim and the 15.1.2.2 leading-whitespace scan.
> String.prototype.charCodeAt = function () { return 0x41 };
> String.prototype.substring = function () { return "HIJACKED" };
> print("  padded  ".trim() + "|" + "\t x ".trim() + "|" + "".trim() + "|" + "abc".trim())
< padded|x||abc
> print(parseInt("  42px") + "|" + parseInt(" -17", 10) + "|" + parseInt("0x1f") + "|" + parseInt("z"))
< 42|-17|31|NaN
-
// Function.prototype.call: the 15.4.4.14-22 callbacks, 15.4.4.11 sort and 15.9.5.44 toJSON all invoke through it.
> Function.prototype.call = function () { throw new Error("call hijacked") };
> Function.prototype.apply = function () { throw new Error("apply hijacked") };
> print([1, 2, 3].map(function (v) { return v * 2 }).join(",") + "|" + [1, 2, 3].filter(function (v) { return v > 1 }).join(","))
< 2,4,6|2,3
> print([1, 2, 3].every(function (v) { return v > 0 }) + "|" + [1, 2, 3].some(function (v) { return v > 2 }))
< true|true
> var seen = []; [4, 5].forEach(function (v, i, o) { seen[seen.length] = v + ":" + i + ":" + o.length });
> print(seen.join(" "))
< 4:0:2 5:1:2
> print([1, 2, 3].reduce(function (a, b) { return a + b }) + "|" + ["a", "b"].reduceRight(function (a, b) { return a + b }))
< 6|ba
> print([3, 1, 2].sort().join(",") + "|" + [3, 1, 2].sort(function (a, b) { return b - a }).join(","))
< 1,2,3|3,2,1
> print(new Date(0).toJSON())
< 1970-01-01T00:00:00.000Z
-
// The library reuses one scratch argument list across the whole traversal, so a callback writing through its own
// (mapped) arguments object must not be visible to the next element or to the array being walked.
> var src = [7, 8], out = [];
> src.forEach(function (v, i) { arguments[0] = 99; out[out.length] = v + ":" + i });
> print(out.join(" ") + "|" + src.join(","))
< 99:0 99:1|7,8
-
// Array.prototype.push: 15.2.3.14 Object.keys collects into an array.
> Array.prototype.push = function () { return 0 };
> print(Object.keys({ a: 1 }).join(",") + "|" + Object.keys([9, 9]).join(",") + "|" + Object.keys({ a: 1, b: 2 }).length)
< a|0,1|2
-
// 15.2.3.8-12 are specified against the [[GetOwnProperty]] and [[DefineOwnProperty]] internal methods, not the
// same-named library functions sitting beside them.
> Object.getOwnPropertyNames = function () { return [] };
> Object.getOwnPropertyDescriptor = function () { return { configurable: true, writable: true } };
> Object.defineProperty = function () { throw new Error("defineProperty hijacked") };
> Object.defineProperties = function () { throw new Error("defineProperties hijacked") };
> Object.preventExtensions = function (o) { return o };
> Object.isExtensible = function () { return true };
> var f = freeze({ x: 1 }); f.x = 9; print(f.x + "|" + isFrozen(f) + "|" + isSealed(f) + "|" + (delete f.x))
< 1|true|true|false
> var s = seal({ y: 1 }); s.y = 9; s.z = 3; print(s.y + "|" + s.z + "|" + isSealed(s) + "|" + isFrozen(s))
< 9|undefined|true|false
> var c = create({ p: 7 }, { q: { value: 8, enumerable: true } }); print(c.p + "|" + c.q + "|" + Object.keys(c).join(","))
< 7|8|q
> var d = {}; defineProperties(d, { m: { value: 1 }, n: { get: function () { return 2 } } });
> print(d.m + "|" + d.n + "|" + gopd(d, "m").writable + "|" + gopd(d, "m").configurable)
< 1|2|false|false
-
// 15.2.3.7 runs step 5 (ToPropertyDescriptor for every entry) to completion before step 6 defines any of them, so
// no conversion may observe a property this same call already defined. `value` is read through [[Get]].
> function count(o) { var c = 0, k; for (k in o) ++c; return c }
> var t = {}, seen = "";
> function mk(n) { return { enumerable: true, get value() { seen += count(t); return n } } }
> defineProperties(t, { one: mk(1), two: mk(2) });
> print(seen + "|" + count(t) + "|" + t.one + t.two)
< 00|2|12
-
// The same ordering makes a malformed descriptor leave the entries converted ahead of it undefined.
> var e = {}; try { defineProperties(e, { aaa: { value: 1 }, zzz: { get: 5 } }) } catch (x) { print(x instanceof TypeError) }
> print(count(e) + "|" + ("aaa" in e))
< true
< 0|false
-
// The global bindings themselves. ToObject, ToString and IsFinite are internal operations; a script reassigning
// the constructor of the same name must not reach them.
> Function.prototype.call = realCall;
> Object = function () { throw new Error("Object hijacked") };
> String = function () { return "HIJACKED" };
> Array = function () { return { length: 0 } };
> isFinite = function () { return false };
> print("  x  ".trim() + "|" + [1, 2].map(function (v) { return v + 1 }).join(",") + "|" + new Date(0).toJSON())
< x|2,3|1970-01-01T00:00:00.000Z
> print(parseInt({ toString: function () { return "  77" }, valueOf: function () { return 5 } }))
< 77
> var m = [1, , 3].map(function (v) { return v });
> print(m.length + "|" + (1 in m) + "|" + m[2])
< 3|false|3
> print(realObject.prototype.toString.call(7) + realObject.prototype.toString.call([]))
< [object Number][object Array]
-
