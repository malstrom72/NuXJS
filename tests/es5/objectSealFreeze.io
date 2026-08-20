// ES5.1 15.2.3.8 Object.seal / 15.2.3.11 Object.isSealed.
> var o = { a: 1, b: 2 };
> print(Object.seal(o) === o); print(Object.isSealed(o))
< true
< true
// Sealed: not configurable (no delete, no new props) but data stays writable.
> print(delete o.a); o.c = 3; print(o.c); o.a = 9; print(o.a)
< false
< undefined
< 9
> print(Object.getOwnPropertyDescriptor(o, "a").configurable); print(Object.getOwnPropertyDescriptor(o, "a").writable)
< false
< true
-
// 15.2.3.9 Object.freeze / 15.2.3.12 Object.isFrozen.
> var f = { x: 1 };
> print(Object.freeze(f) === f); print(Object.isFrozen(f)); print(Object.isSealed(f))
< true
< true
< true
> f.x = 99; print(f.x); print(delete f.x)
< 1
< false
> var df = Object.getOwnPropertyDescriptor(f, "x"); print(df.writable); print(df.configurable)
< false
< false
-
// A frozen accessor property keeps working; only its configurability is affected.
> var ac = { get p() { return 42; } }; Object.freeze(ac);
> print(Object.isFrozen(ac)); print(ac.p); print(Object.getOwnPropertyDescriptor(ac, "p").configurable)
< true
< 42
< false
-
// An empty non-extensible object is both sealed and frozen; an extensible one is neither.
> var g = {}; print(Object.isSealed(g)); print(Object.isFrozen(g))
< false
< false
> Object.preventExtensions(g); print(Object.isSealed(g)); print(Object.isFrozen(g))
< true
< true
-
// A non-extensible object with a writable data property is sealed but not frozen.
> var h = {}; h.w = 1; Object.seal(h); print(Object.isSealed(h)); print(Object.isFrozen(h))
< true
< false
-
// 15.2.3.x step 1: non-object arguments throw a TypeError (ES5.1, unlike ES6 which returns the argument).
> try { Object.seal(5); } catch (e) { print(e.name) }
< TypeError
> try { Object.freeze("x"); } catch (e) { print(e.name) }
< TypeError
> try { Object.isFrozen(1); } catch (e) { print(e.name) }
< TypeError
> try { Object.isSealed(true); } catch (e) { print(e.name) }
< TypeError
-
// 15.2.3.8 on an accessor pair: sealing clears configurable but the pair keeps running, and with no writable bit
// to stay true, an all-accessor sealed object is frozen as well (15.2.3.12 step 2 only looks at data properties).
> var saLog = "", sa = { get p() { return 5 }, set p(v) { saLog += "set" + v } };
> Object.seal(sa);
> sa.p = 9; print(Object.isSealed(sa) + " " + sa.p + " " + saLog)
< true 5 set9
> var saD = Object.getOwnPropertyDescriptor(sa, "p"); print(saD.configurable + " " + ("writable" in saD) + " " + (typeof saD.set))
< false false function
> print(Object.isFrozen(sa))
< true
-
