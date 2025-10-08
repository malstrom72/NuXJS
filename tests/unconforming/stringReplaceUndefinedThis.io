// NuXJS substitutes the global object when the receiver is null or undefined.
// This keeps borrowed string built-ins side-effect free but diverges from ES3,
// which would stringify the actual receiver ("undefined").
> print(String.prototype.replace.call(undefined, "d", "D"))
< [object Object]
-
