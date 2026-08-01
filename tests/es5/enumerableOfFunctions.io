// ES5.1 15.3.5.2 gives `prototype` { [[Writable]]: true, [[Enumerable]]: false, [[Configurable]]: false },
// so unlike ES3 it never appears in for-in. Twin: tests/es3only/enumerableOfFunctions.io.
> function f() { }
-
> for (i in f) print(i)
-
> for (i in Number) print(i)
-
> for (i in Number.prototype) print(i)
-
// A dynamically created function behaves the same way (moved here from tests/stdlib/checkEnumerablesInBuiltIn.io).
> function dump(o) { for (var k in o) print(k) }
> dump(new Function)
-
