// ES5.1 15.2.4.2 Object.prototype.toString. ES5 added the explicit undefined and null cases ahead of ToObject, and
// 10.6 gave the arguments object the class "Arguments" where ES3 10.1.8 gave it "Object". Twin for the ES3 answer:
// tests/es3only/objectToStringTag.io. Verified against V8.
> var ts = Object.prototype.toString; print((function () { return ts.call(arguments); })())
< [object Arguments]
> var ts = Object.prototype.toString; print(ts.call(undefined) + " " + ts.call())
< [object Undefined] [object Undefined]
-
// 15.2.4.2 step 2: a null receiver is its own tag, distinguishable from undefined only because a strict callee
// receives the this value verbatim (10.4.3).
> var ts = Object.prototype.toString; print(ts.call(null))
< [object Null]
-
// The class of every other built-in is unchanged from ES3.
> var ts = Object.prototype.toString; print([ts.call([]), ts.call(function () {}), ts.call(5), ts.call("s"), ts.call(true)].join(" "))
< [object Array] [object Function] [object Number] [object String] [object Boolean]
> var ts = Object.prototype.toString; print([ts.call(new Date(0)), ts.call(/x/), ts.call(new Error()), ts.call(Math), ts.call(JSON)].join(" "))
< [object Date] [object RegExp] [object Error] [object Math] [object JSON]
> var ts = Object.prototype.toString; print(ts.call({}) + " " + ts.call(Object.create(null)))
< [object Object] [object Object]
-
// It stays non-enumerable and writable like every other built-in method, and toLocaleString still routes through it.
> var d = Object.getOwnPropertyDescriptor(Object.prototype, "toString"); print(d.writable + " " + d.enumerable + " " + d.configurable)
< true false true
> print((function () { return Object.prototype.toLocaleString.call(arguments); })())
< [object Arguments]
-
