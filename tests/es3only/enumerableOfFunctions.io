// ES3 15.3.5.2 gives `prototype` only { DontDelete }, so it is enumerable and shows up in for-in.
// ES5.1 15.3.5.2 adds [[Enumerable]]: false; the twin is tests/es5/enumerableOfFunctions.io.
> function f() { }
-
> for (i in f) print(i)
< prototype
-
> for (i in Number) print(i)
-
> for (i in Number.prototype) print(i)
-
// A dynamically created function behaves the same way (moved here from tests/stdlib/checkEnumerablesInBuiltIn.io).
> function dump(o) { for (var k in o) print(k) }
> dump(new Function)
< prototype
-
