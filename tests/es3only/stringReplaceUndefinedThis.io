// NuXJS substitutes the global object when the receiver is null or undefined.
// This keeps borrowed string built-ins side-effect free but diverges from ES3,
// which would stringify the actual receiver ("undefined"). ES5.1 15.5.4.11 makes
// it a TypeError instead; see tests/es5/checkObjectCoercible.io.
> print(String.prototype.replace.call(undefined, "d", "D"))
< [object Object]
-
