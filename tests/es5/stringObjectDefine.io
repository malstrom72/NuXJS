// ES5.1 15.5.5.1 / 15.5.5.2: a String object's characters and length are its own non-configurable, non-writable data
// properties (characters enumerable, length not). 8.12.9 therefore accepts a descriptor only when it asks for what is
// already there, and rejects everything else, rather than shadowing the wrapped string with a table property.
> function t(fn) { try { print(fn()) } catch (e) { print(e.name) } }
> var s = new String("ab");
-
// A character cannot be given another value, made writable, made configurable or turned into an accessor.
> t(function () { Object.defineProperty(s, "0", { value: "x" }); return "accepted" })
< TypeError
> t(function () { Object.defineProperty(s, "0", { writable: true }); return "accepted" })
< TypeError
> t(function () { Object.defineProperty(s, "0", { configurable: true }); return "accepted" })
< TypeError
> t(function () { Object.defineProperty(s, "0", { get: function () { return "g" } }); return "accepted" })
< TypeError
> t(function () { Object.defineProperty(s, "0", { enumerable: false }); return "accepted" })
< TypeError
-
// A descriptor that changes nothing is accepted (step 5 / step 12), which is what lets Object.freeze through.
> t(function () { return Object.defineProperty(s, "0", { value: "a" }) === s ? "same object" : "other object" })
< same object
> t(function () { Object.defineProperty(s, "0", {}); return "accepted" })
< accepted
> t(function () { Object.defineProperty(s, "0", { enumerable: true }); return "accepted" })
< accepted
-
// length is the same story, except that it is not enumerable.
> t(function () { Object.defineProperty(s, "length", { value: 9 }); return "accepted" })
< TypeError
> t(function () { Object.defineProperty(s, "length", { enumerable: true }); return "accepted" })
< TypeError
> t(function () { Object.defineProperty(s, "length", { value: 2 }); return "accepted" })
< accepted
-
// None of the rejected defines left anything behind: reads and descriptors still report the wrapped string.
> print(s[0]); print(s.length)
< a
< 2
> var d = Object.getOwnPropertyDescriptor(s, "0");
> print(d.value); print(d.writable); print(d.enumerable); print(d.configurable)
< a
< false
< true
< false
> var l = Object.getOwnPropertyDescriptor(s, "length");
> print(l.value); print(l.writable); print(l.enumerable); print(l.configurable)
< 2
< false
< false
< false
-
// Indices past the end and ordinary names are not the wrapped string's, so they define as on any other object.
> t(function () { Object.defineProperty(s, "5", { value: "q", enumerable: true, configurable: true }); return s[5] })
< q
> t(function () { Object.defineProperty(s, "foo", { value: 1 }); return s.foo })
< 1
-
// Freezing works, and leaves each name exactly once: no shadow property behind the wrapped one.
> var f = new String("ab");
> t(function () { Object.freeze(f); return Object.isFrozen(f) })
< true
> print(Object.getOwnPropertyNames(f).join(","))
< 0,1,length
> print(Object.getOwnPropertyNames(Object.seal(new String("q"))).join(","))
< 0,length
> print(Object.keys(new String("ab")).join(","))
< 0,1
-
// String.prototype is itself a String object wrapping the empty string.
> t(function () { Object.freeze(String.prototype); return Object.isFrozen(String.prototype) })
< true
> print(String.prototype.length); print(typeof String.prototype.charAt)
< 0
< function
-
