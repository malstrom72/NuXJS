// ES3 10.1.8 gives the arguments object the class "Object", and 15.2.4.2 has no special case for a null or
// undefined receiver, so all three report "[object Object]". ES5.1 changes both; twin: tests/es5/objectToStringTag.io.
> var ts = Object.prototype.toString; print((function () { return ts.call(arguments); })())
< [object Object]
> var ts = Object.prototype.toString; print(ts.call(undefined) + " " + ts.call(null))
< [object Object] [object Object]
-
// The class of every other built-in is the same in both editions.
> var ts = Object.prototype.toString; print([ts.call([]), ts.call(function () {}), ts.call(5), ts.call(new Date(0)), ts.call(/x/)].join(" "))
< [object Array] [object Function] [object Number] [object Date] [object RegExp]
-
