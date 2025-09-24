// CLI:
> var invalidBase = null;
> var objectPropertyName = { toString: function() { print("to string called!"); return 'x' } };
> try { invalidBase[objectPropertyName] } catch (e) { print(e.name) }
< TypeError
-
