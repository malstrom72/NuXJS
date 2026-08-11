// 15.4.5.1 step 3 runs ToUint32 over an array length's new value (3.c) and throws a RangeError when that does not
// round trip through ToNumber (3.d), both of them ahead of every reject in the algorithm. An object value therefore
// has to have its valueOf run, which the array's store path may not do: it hands such a store back to the VM, which
// enters support.setArrayLength in its place exactly as it enters a setter. Object.defineProperty needs no VM help,
// its value being converted in stdlib.js before the native sees it. The es3 build has neither and keeps the old
// RangeError; the twin is tests/es3only/cantAssignObjectToArrayLength.io.
> function p(l, f) { var r; try { r = f() } catch (e) { r = "THREW " + e.name } print(l + ": " + r) }
-
// Plain assignment, 15.4.5.1 through 8.12.5. valueOf runs and the number it gives is the new length.
> var seen = false; var a = []; a.length = { valueOf: function () { seen = true; return 3 } };
> print(a.length + " " + seen)
< 3 true
-
// The computed form takes the same opcode, so it must agree.
> var b = [], k = "length"; b[k] = { valueOf: function () { return 4 } };
> print(b.length)
< 4
-
// ToNumber, so valueOf is asked before toString, and toString alone is enough.
> var c = []; c.length = { valueOf: function () { return 5 }, toString: function () { return "9" } };
> var d = []; d.length = { toString: function () { return "6" } };
> print(c.length + " " + d.length)
< 5 6
-
// 3.d still applies to what valueOf returned: -1 is not a uint32, so the RangeError comes from the helper's store.
> p("valueOf gives -1  ", function () { var e = []; e.length = { valueOf: function () { return -1 } }; return e.length })
< valueOf gives -1  : THREW RangeError
-
// Neither hook yields a primitive, so ToNumber itself throws before any length is computed.
> p("no primitive      ", function () { var f = []; f.length = { valueOf: function () { return {} }, toString: function () { return {} } }; return f.length })
< no primitive      : THREW TypeError
-
// 8.12.5 puts [[CanPut]] ahead of the store, so a read-only length is settled without converting anything at all.
> var untouched = true;
> var g = [1, 2]; Object.defineProperty(g, "length", { writable: false });
> g.length = { valueOf: function () { untouched = false; return 9 } };
> print(g.length + " " + untouched)
< 2 true
-
// Object.defineProperty reaches 15.4.5.1 directly, and its six test262 shapes are the same ToNumber.
> var h = []; Object.defineProperty(h, "length", { value: { valueOf: function () { return 2 } } });
> var i = []; Object.defineProperty(i, "length", { value: { toString: function () { return '2' } } });
> print(h.length + " " + i.length)
< 2 2
-
// valueOf first: a toString beside it is never asked, and one returning an object falls through to toString.
> var tsSeen = false, voSeen = false;
> var j = []; Object.defineProperty(j, "length", { value: { toString: function () { tsSeen = true; return '2' }, valueOf: function () { voSeen = true; return 3 } } });
> print(j.length + " " + tsSeen + " " + voSeen)
< 3 false true
-
> var k2 = []; var ts2 = false;
> Object.defineProperty(k2, "length", { value: { valueOf: function () { return {} }, toString: function () { ts2 = true; return '2' } } });
> print(k2.length + " " + ts2)
< 2 true
-
// The hooks may be inherited rather than own, and valueOf still wins wherever it sits.
> var proto = { valueOf: function () { return 2 } };
> var Ctor = function () { }; Ctor.prototype = proto;
> var child = new Ctor(); child.toString = function () { return 3 };
> var l = []; Object.defineProperty(l, "length", { value: child });
> print(l.length)
< 2
-
// Neither hook primitive: a TypeError out of ToNumber, not the RangeError the range check would have given.
> p("define, no primitive", function () { var m = []; Object.defineProperty(m, "length", { value: { valueOf: function () { return {} }, toString: function () { return {} } } }); return m.length })
< define, no primitive: THREW TypeError
-
// 3.4 throws ahead of 3.7, so an illegal value on a read-only length is a RangeError and not a reject.
> function ro() { var a = [1, 2]; Object.defineProperty(a, "length", { writable: false }); return a }
> p("read-only, value -1 ", function () { Object.defineProperty(ro(), "length", { value: -1 }); return "no throw" })
< read-only, value -1 : THREW RangeError
-
// 3.6 hands a grow to the default 8.12.9, whose step 6 lets an unchanged value through even when non-writable.
> p("read-only, same     ", function () { var a = ro(); Object.defineProperty(a, "length", { value: 2 }); return a.length })
< read-only, same     : 2
-
// A different value is a real change, so the same algorithm rejects it, growing or shrinking alike.
> p("read-only, grow     ", function () { var a = ro(); Object.defineProperty(a, "length", { value: 5 }); return a.length })
< read-only, grow     : THREW TypeError
> p("read-only, shrink   ", function () { var a = ro(); Object.defineProperty(a, "length", { value: 1 }); return a.length })
< read-only, shrink   : THREW TypeError
-
// 8.12.9 (10.b.i) rejects only a writable field that is present and true; absent asks for nothing.
> p("read-only, w:true   ", function () { Object.defineProperty(ro(), "length", { writable: true }); return "no throw" })
< read-only, w:true   : THREW TypeError
> p("read-only, w:false  ", function () { Object.defineProperty(ro(), "length", { writable: false }); return "no throw" })
< read-only, w:false  : no throw
-
// length stays a data property throughout, non-enumerable and non-configurable, whatever has been defined on it.
> var desc = Object.getOwnPropertyDescriptor(ro(), "length");
> print(desc.value + " " + desc.writable + " " + desc.enumerable + " " + desc.configurable + " " + ("get" in desc))
< 2 false false false false
-
