// MAX_NESTED_COMPILE_DEPTH turns deeply nested source into a catchable RangeError rather than a crash. The limit
// is a proxy for stack bytes, and shapes cost different amounts of it: a function expression about three levels, an
// array one. It was 256 until 2026-10-07, which on the 1 MB default stack of Windows was above the real ceiling, so
// 86 nested function expressions exhausted the stack before the guard could fire. Above about 84 the RangeError also
// has too little stack left to unwind through the live compiler frames. These cases pin both ends.
> function nest(open, close, n) { var s = '', i; for (i = 0; i < n; ++i) s += open; for (i = 0; i < n; ++i) s += close; return s }
> function tryIt(s) { try { eval(s); return 'compiled' } catch (e) { return String(e) } }
> print(tryIt(nest('(function(){', '})', 20)))
< compiled
-
// used to exhaust the stack instead of reporting anything
> function nest(open, close, n) { var s = '', i; for (i = 0; i < n; ++i) s += open; for (i = 0; i < n; ++i) s += close; return s }
> function tryIt(s) { try { eval(s); return 'compiled' } catch (e) { return String(e) } }
> print(tryIt(nest('(function(){', '})', 86)))
< RangeError: Internal compiler limitations reached. Reduce code complexity.
-
// likewise for declarations, whose frames are smaller but which used to reach 254 before dying
> function nest(open, close, n) { var s = '', i; for (i = 0; i < n; ++i) s += open; for (i = 0; i < n; ++i) s += close; return s }
> function tryIt(s) { try { eval(s); return 'compiled' } catch (e) { return String(e) } }
> print(tryIt(nest('function f(){', '}', 254)))
< RangeError: Internal compiler limitations reached. Reduce code complexity.
-
// a cheap shape taken far past the limit: still an error, never a crash
> function nest(open, close, n) { var s = '', i; for (i = 0; i < n; ++i) s += open; for (i = 0; i < n; ++i) s += close; return s }
> function tryIt(s) { try { eval(s); return 'compiled' } catch (e) { return String(e) } }
> print(tryIt(nest('[', ']', 500)))
< RangeError: Internal compiler limitations reached. Reduce code complexity.
-
// the limit must stay high enough for the 62 levels tests/stdlib/JSON.io requires, since JSON.parse eval()s its input
> var s = '', i
> for (i = 0; i < 62; ++i) s += '['
> s += '234'
> for (i = 0; i < 62; ++i) s += ']'
> print(JSON.stringify(JSON.parse(s)).length)
< 127
-
