// ES5.1 8.12.5 / 11.13.1: in strict mode a failed property assignment throws instead of failing silently.
// Assigning to a non-writable data property.
> "use strict";
> var o = {}; Object.defineProperty(o, "x", { value: 1 });
> try { o.x = 2; } catch (e) { print(e.name) } print(o.x)
< TypeError
< 1
-
// Adding a property to a non-extensible object.
> "use strict";
> var f = Object.freeze({ a: 1 });
> try { f.b = 2; } catch (e) { print(e.name) } print(f.b)
< TypeError
< undefined
-
// Assigning to an accessor property that has no setter.
> "use strict";
> var g = { get p() { return 1; } };
> try { g.p = 2; } catch (e) { print(e.name) } print(g.p)
< TypeError
< 1
-
// 11.4.1: deleting a non-configurable property throws in strict mode.
> "use strict";
> var d = {}; Object.defineProperty(d, "c", { value: 1 });
> try { delete d.c; } catch (e) { print(e.name) } print(d.c)
< TypeError
< 1
-
// Successful strict operations do not throw, and deleting a missing property is fine.
> "use strict";
> var ok = { a: 1 }; ok.a = 5; print(ok.a); print(delete ok.a); print(ok.a)
> print(delete ({}).notHere)
< 5
< true
< undefined
< true
-
// Outside strict mode the same failures are silent (no throw).
> var frozen = Object.freeze({ a: 1 });
> frozen.a = 99; print(frozen.a)
> frozen.b = 2; print(frozen.b)
> print(delete frozen.a); print(frozen.a)
< 1
< undefined
< false
< 1
-
