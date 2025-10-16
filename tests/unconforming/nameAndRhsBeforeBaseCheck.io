> var log = [];
> var key = { toString: function() { log.push("key"); return "p"; } };
> function rhs() {
> log.push("rhs");
> return 1;
> }
> try { null[key] = rhs(); } catch (e) { print(e.name); }
> print(log.join(","));
// NuXJS now matches the ES5.1 evaluation order, so the key and RHS hooks
// never run when the base object is null or undefined.
< TypeError
<
-
