// ES5.1 12.6.4: for-in over null or undefined enumerates nothing instead of throwing (ES3 threw a TypeError).
// The ES3 expectation lives in tests/es3only/forInNullUndefined.io.
> for (var i in null) print("BAD"); print("ok")
< ok
-
> for (var i in undefined) print("BAD"); print("ok")
< ok
-
> var o = { reached: false }; for (o.k in null) o.reached = true; print(o.reached); print(o.k)
< false
< undefined
-
