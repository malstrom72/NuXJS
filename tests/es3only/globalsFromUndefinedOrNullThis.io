> var globals = this;
-
> // Following is true in ES>3 too because of conversion described in 10.4.3, however in ES>3 this only applies to script functions
> (function() { print(this === globals); }).call(null);
< true
-
> // Following is true in ES>3 too because of conversion described in 10.4.3, however in ES>3 this only applies to script functions
> (function() { print(this === globals); }).call(undefined);
< true
-
> print(String.prototype.charAt.call(null, 0))
< [
-
> print(String.prototype.charAt.call(undefined, 0))
< [
-
> print(String.prototype.charCodeAt.call(null, 0))
< 91
-
> print(String.prototype.charCodeAt.call(undefined, 0))
< 91
-
> // ES3 10.2.3 boxes a primitive receiver too, so `this` is never the value that was handed in. ES5.1 10.4.3
> // narrows the coercion to non-strict function code; twin: tests/es5/strictThisBinding.io.
> function f() { return typeof this + "/" + (this === 5); }
> print(f.call(5) + " " + f.apply(5))
< object/false object/false
-
> Number.prototype.t = function () { return typeof this + "/" + (this === 5); };
> String.prototype.t = function () { return typeof this + "/" + (this === "abc"); };
> print((5).t() + " " + "abc".t())
< object/false object/false
-
