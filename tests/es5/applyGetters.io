// ES5.1 15.3.4.3 (4, 8): Function.prototype.apply reads argArray's length and elements with [[Get]], so accessors
// there run, their side effects are observable and an exception from one propagates out of apply.
> function f() { return arguments.length + ":" + Array.prototype.join.call(arguments, ",") }
-
// A length getter decides the argument count; element getters supply the values.
> print(f.apply(null, { get length() { return 2 }, 0: "a", 1: "b" }))
< 2:a,b
> var log = [];
> print(f.apply(null, { get length() { log.push("len"); return 2 }, get 0() { log.push("g0"); return "x" }, get 1() { log.push("g1"); return "y" } }))
< 2:x,y
-
// Every getter ran, length first and then the indices in ascending order.
> print(log.join(","))
< len,g0,g1
-
// An accessor element on a genuine Array is read the same way.
> var arr = [1, 2];
> Object.defineProperty(arr, "1", { get: function () { return "from getter" }, configurable: true });
> print(f.apply(null, arr))
< 2:1,from getter
-
// A throwing getter completes apply abruptly instead of being swallowed, whether it is length or an element.
> try { f.apply(null, { get length() { throw new TypeError("boom") } }); print("swallowed") } catch (e) { print(e.name + ": " + e.message) }
< TypeError: boom
> try { f.apply(null, { length: 1, get 0() { throw new RangeError("elem") } }); print("swallowed") } catch (e) { print(e.name + ": " + e.message) }
< RangeError: elem
-
// [[Get]] walks the prototype chain and holes read as undefined; length is converted with ToUint32 as before.
> print(f.apply(null, { length: 3, 1: "mid" }))
< 3:,mid,
> var proto = { get 0() { return "inherited" } };
> var o = Object.create(proto); o.length = 1;
> print(f.apply(null, o))
< 1:inherited
> print(f.apply(null, { length: "2", 0: "p", 1: "q" }))
< 2:p,q
-
// 15.3.4.3 (6) takes ToUint32 of the length, which for an object is ToNumber and so runs valueOf. A negative or
// unusable length still yields no arguments rather than ToUint32's four billion, which is what every engine does.
> print(f.apply(null, { length: { valueOf: function () { return 2 } }, 0: "p", 1: "q" }))
< 2:p,q
> print(f.apply(null, { length: new Number(2), 0: "p", 1: "q" }))
< 2:p,q
> print(f.apply(null, { length: { toString: function () { return "2" } }, 0: "p", 1: "q" }))
< 2:p,q
> print(f.apply(null, { length: -1, 0: "p" }))
< 0:
> print(f.apply(null, { length: null, 0: "p" }))
< 0:
> print(f.apply(null, { 0: "p" }))
< 0:
-
// The length is read once, before the elements, and a throwing valueOf completes apply abruptly.
> var order = [];
> print(f.apply(null, { get length() { order.push("len"); return 1 }, get 0() { order.push("elem"); return "v" } }))
< 1:v
> print(order.join(","))
< len,elem
> try { f.apply(null, { length: { valueOf: function () { throw new TypeError("badlen") } } }); print("swallowed") } catch (e) { print(e.name + ": " + e.message) }
< TypeError: badlen
-
// The ordinary paths are unchanged: call, a real array, and no argArray at all.
> print(f.call(null, "c1", "c2"))
< 2:c1,c2
> print(f.apply(null, [1, 2, 3]))
< 3:1,2,3
> print(f.apply(null))
< 0:
-
