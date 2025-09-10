> var invalidBase = null;
> function getRHS() { print("rhs"); return 1; }
> try { invalidBase.x = getRHS(); } catch (e) { print(e.name) }
< TypeError
-
