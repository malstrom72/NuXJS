// 15.4.4.11 lets an inconsistent comparefn make the resulting order implementation-defined, but not the sort
// itself unbounded. qsort scans out from a pivot and stops on it, `cmp(mid, mid)` answering neither > 0 nor < 0 -
// which leans on the comparator for its bounds. One that never answers <= 0 used to run `high` off the bottom and
// leave the partition point at `from`, so the outer for made no progress and spun; one that always answers < 0 ran
// `low` off the top and recursed on its own range until the stack went. Pinning the split to from < low <= to ends
// both. Only termination is asserted below, never an order, since the order is exactly what is unspecified here.
// Note that a regression shows up as the suite hanging rather than as a failure, this being the shape of the bug.
> function terminates(f) { var a = [3, 1, 2, 9, 4, 7, 0, 5]; a.sort(f); return a.length }
-
// Never <= 0, in the four spellings that reach it. `a < b ? -1 : 1` is the one worth having: it is an ordinary
// thing to write and is inconsistent only because it forgets the equal case.
> print(terminates(function (a, b) { return 1 }))
< 8
> print(terminates(function (a, b) { return true }))
< 8
> print(terminates(function (a, b) { return a >= b }))
< 8
> print(terminates(function (a, b) { return a < b ? -1 : 1 }))
< 8
-
// Always < 0, which took the recursion rather than the loop.
> print(terminates(function (a, b) { return -1 }))
< 8
-
// A comparator that answers differently every call, and one that answers NaN - the NaN case was already handled at
// the comparator (it is folded to +0), and is here so the two guards stay tested together.
> print(terminates(function (a, b) { return Math.random() < 0.5 ? -1 : 1 }))
< 8
> print(terminates(function (a, b) { return NaN }))
< 8
-
// The clamp must be inert for a well-behaved comparator: the pivot already holds the split inside the range, so a
// consistent sort has to come back exactly as before, holes and undefined included (15.4.4.11 ranks undefined after
// everything and a hole after even that; whether the hole is still absent afterwards is the es5 sort wrapper's
// business and is pinned in tests/es5/arrayMutatorThrowFlag.io, not here).
> var a = [5, 1, 4, 1, 5, 9, 2, 6]; a.sort(function (x, y) { return x - y }); print(a.join(","))
< 1,1,2,4,5,5,6,9
> var b = [3, 1, 2]; b.sort(); print(b.join(","))
< 1,2,3
> var c = [, 3, void 0, 1]; c.sort(); print(c.join(",") + " " + c.length)
< 1,3,, 4
> var d = ["b", "a", "c"]; d.sort(function (x, y) { return x < y ? -1 : x > y ? 1 : 0 }); print(d.join(","))
< a,b,c
-
