> function dump(o) { for (var k in o) print(k) }
> dump(Array)
-
> dump(Boolean)
-
> dump(Date)
-
> dump(Function)
-
> dump(Math)
-
> dump(Number)
-
> dump(Object)
-
> dump(RegExp)
-
> dump(String)
-
> dump(new Array)
-
> dump(new Boolean)
-
> dump(new Date)
-
// `new Function` is covered by the enumerableOfFunctions twins instead: ES3 15.3.5.2 leaves `prototype`
// enumerable here, ES5.1 15.3.5.2 does not, so the expectation differs per build.
> dump(new Number)
-
> dump(new Object)
-
> dump(new RegExp)
-
> dump(new String)
-
