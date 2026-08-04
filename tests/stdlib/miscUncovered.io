// 15.4.3.2 Array.isArray. Not an ES3 method, an intentional extension, and it had no behavioural test.
> print(Array.isArray([]) + " " + Array.isArray([1,2]) + " " + Array.isArray(Array.prototype))
< true true true
-
> print(Array.isArray({}) + " " + Array.isArray("x") + " " + Array.isArray(null) + " " + Array.isArray(void 0))
< false false false false
-
> print(Array.isArray({length: 0}) + " " + (function () { return Array.isArray(arguments) })())
< false false
-
// 15.8.2.14 Math.random: only the contract is checkable.
> var r = Math.random(); print(typeof r); print(r >= 0 && r < 1);
< number
< true
-
> var a = Math.random(), b = Math.random(), c = Math.random(); print(a !== b || b !== c);
< true
-
