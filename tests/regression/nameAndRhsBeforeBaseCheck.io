// CLI:
> var log = [];
> var key = { toString: function() { log.push("key"); return "p"; } };
> function rhs() {
>	log.push("rhs");
>	return 1;
> }
> try { null[key] = rhs(); } catch (e) { print(e.name); }
> print(log.join(","));
< TypeError
<
-
