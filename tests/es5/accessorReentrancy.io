// Accessor re-entrancy hazards: getters run as ordinary VM frames, so exceptions, recursion, garbage
// collection, and mutation during property access must all behave like normal function calls.
> try { ({ get boom() { throw new Error("from getter"); } }).boom; } catch (x) { print("caught: " + x.message) }
< caught: from getter
-
// A recursive getter must die as a managed RangeError, never a host crash.
> var r = { get rec() { return this.rec; } };
> try { r.rec; } catch (x) { print("caught: " + x) }
< caught: RangeError: Stack overflow
-
// Mutually recursive accessors likewise.
> var a = { get x() { return b.x; } }, b = { get x() { return a.x; } };
> try { a.x; } catch (x) { print("caught: " + x) }
< caught: RangeError: Stack overflow
-
// A getter that allocates on every call must survive garbage collection cycles.
> var gv = { get g() { return [1, 2, 3].concat([4]); } };
> var sum = 0; for (var z = 0; z < 2000; ++z) { sum += gv.g.length; } print(sum)
< 8000
-
// A getter that deletes itself mid-read: the delete succeeds and later reads see it gone.
> var self = { get once() { delete self.once; return "first"; } };
> print(self.once); print(self.once)
< first
< undefined
-
// A setter that replaces the property with a plain data property on the same object.
> var swap = { set s(v) { delete swap.s; swap.s = v * 2; } };
> swap.s = 21; print(swap.s)
< 42
-
// A getter throwing through a compound assignment leaves the target unchanged.
> var t = { n: 1, get bad() { throw new Error("no read"); }, set bad(v) { this.n = v; } };
> try { t.bad += 1; } catch (x) { print(x.message) } print(t.n)
< no read
< 1
-
