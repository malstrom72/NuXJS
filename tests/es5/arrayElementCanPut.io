// ES5.1 8.12.5 step 1 and 8.12.4: an array element store asks [[CanPut]] before creating anything, which walks to
// Array.prototype and Object.prototype. An inherited accessor runs or refuses, and an inherited read-only refuses.
> function show(l, v) { print(l + ": " + v) }
> function own(o, k) { return Object.prototype.hasOwnProperty.call(o, k) }
> function p(l, f) { var r; try { r = f() } catch (e) { r = "THREW " + e.name } show(l, r) }
-
// 8.12.4 step 8.2: an inherited read-only element refuses the store; 8.12.5 step 1.1 throws in strict code.
> Object.defineProperty(Array.prototype, "123", { value: 456, writable: false, configurable: true })
> var a = []; a[123] = 789; show("ro sloppy", a[123] + " own=" + own(a, "123") + " len=" + a.length)
< ro sloppy: 456 own=false len=0
> p("ro strict", function () { "use strict"; var b = []; b[123] = 789; return "stored" })
< ro strict: THREW TypeError
> delete Array.prototype[123]
-
// 8.12.5 step 5: an inherited setter runs with the array as this, and no own element is created.
> var log = "", c = []
> Object.defineProperty(Array.prototype, "7", { set: function (v) { log += "set:" + v + "@" + (this === c) }, configurable: true })
> c[7] = 3; show("setter", "log=" + log + " own=" + own(c, "7") + " len=" + c.length)
< setter: log=set:3@true own=false len=0
> delete Array.prototype[7]
-
// 8.12.4 step 7.1: an inherited accessor with no setter refuses.
> Object.defineProperty(Array.prototype, "5", { get: function () { return "g" }, configurable: true })
> var d = []; d[5] = 1; show("getter-only sloppy", d[5] + " own=" + own(d, "5"))
< getter-only sloppy: g own=false
> p("getter-only strict", function () { "use strict"; var e = []; e[5] = 1; return "stored" })
< getter-only strict: THREW TypeError
> delete Array.prototype[5]
-
// 8.12.4 step 8.2 and 8.12.5 step 6: an inherited writable element is unobservable, the store making an own one.
> Array.prototype[9] = "proto"
> var f = []; f[9] = "own"; show("writable inherited", f[9] + " own=" + own(f, "9") + " len=" + f.length + " proto=" + Array.prototype[9])
< writable inherited: own own=true len=10 proto=proto
> delete Array.prototype[9]
-
// 8.12.4 step 2: an existing own element is settled there and shadows an inherited setter at the same index.
> log = ""
> Object.defineProperty(Array.prototype, "0", { set: function (v) { log += "set" }, configurable: true })
> var g = [10]; g[0] = 20; show("own shadows setter", g[0] + " log=[" + log + "]")
< own shadows setter: 20 log=[]
> delete Array.prototype[0]
-
// A hole inside length is not an own element, so it consults the chain exactly as an append does.
> log = ""
> Object.defineProperty(Array.prototype, "2", { set: function (v) { log += "set:" + v }, configurable: true })
> var h = [1, 2]; h.length = 5; h[2] = "y"; show("hole inside length", "log=" + log + " own=" + own(h, "2") + " len=" + h.length)
< hole inside length: log=set:y own=false len=5
> delete Array.prototype[2]
-
// 8.12.4 step 6: nothing can be created past a non-extensible array's end, and strict code throws.
> var k = [1]; Object.preventExtensions(k); k[1] = 2; show("non-extensible", "len=" + k.length + " own1=" + own(k, "1"))
< non-extensible: len=1 own1=false
> p("non-extensible strict", function () { "use strict"; var m = [1]; Object.preventExtensions(m); m[1] = 2; return "stored" })
< non-extensible strict: THREW TypeError
-
// 15.4.5.1: the store updates an element defineProperty placed rather than shadowing it, so it is listed once.
> var n = []; Object.defineProperty(n, "0", { value: 1, writable: true, enumerable: true, configurable: true }); n[0] = 5
> show("names", JSON.stringify(Object.getOwnPropertyNames(n)) + " n0=" + n[0])
< names: ["0","length"] n0=5
-
// The walk reaches Object.prototype too, not only Array.prototype.
> log = ""
> Object.defineProperty(Object.prototype, "4", { set: function (v) { log += "oset:" + v }, configurable: true })
> var q = []; q[4] = "z"; show("object.prototype setter", "log=" + log + " own=" + own(q, "4"))
< object.prototype setter: log=oset:z own=false
> delete Object.prototype[4]
-
