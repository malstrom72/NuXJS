// MAX_NESTED_COMPILE_DEPTH turns deeply nested source into a catchable RangeError rather than a crash. These cases
// pin both ends of its margin; "Nesting limits" in NuXJS Documentation.md has the measurements behind them.
> function nest(open, close, n) { var s = '', i; for (i = 0; i < n; ++i) s += open; for (i = 0; i < n; ++i) s += close; return s }
> function tryIt(s) { try { eval(s); return 'compiled' } catch (e) { return String(e) } }
> print(tryIt(nest('(function(){', '})', 10)))
< compiled
-
// the shape that used to exhaust the stack before the guard could fire
> function nest(open, close, n) { var s = '', i; for (i = 0; i < n; ++i) s += open; for (i = 0; i < n; ++i) s += close; return s }
> function tryIt(s) { try { eval(s); return 'compiled' } catch (e) { return String(e) } }
> print(tryIt(nest('(function(){', '})', 86)))
< RangeError: Internal compiler limitations reached. Reduce code complexity.
-
// declarations cost one level each, so this is the shape that decides the ceiling
> function nest(open, close, n) { var s = '', i; for (i = 0; i < n; ++i) s += open; for (i = 0; i < n; ++i) s += close; return s }
> function tryIt(s) { try { eval(s); return 'compiled' } catch (e) { return String(e) } }
> print(tryIt(nest('function f(){', '}', 400)))
< RangeError: Internal compiler limitations reached. Reduce code complexity.
-
// a cheap shape taken far past the limit: still an error, never a crash
> function nest(open, close, n) { var s = '', i; for (i = 0; i < n; ++i) s += open; for (i = 0; i < n; ++i) s += close; return s }
> function tryIt(s) { try { eval(s); return 'compiled' } catch (e) { return String(e) } }
> print(tryIt(nest('[', ']', 500)))
< RangeError: Internal compiler limitations reached. Reduce code complexity.
-
// the limit must stay above the 40 levels tests/stdlib/JSON.io requires, since JSON.parse eval()s its input
> var s = '', i
> for (i = 0; i < 40; ++i) s += '['
> s += '234'
> for (i = 0; i < 40; ++i) s += ']'
> print(JSON.stringify(JSON.parse(s)).length)
< 83
-
