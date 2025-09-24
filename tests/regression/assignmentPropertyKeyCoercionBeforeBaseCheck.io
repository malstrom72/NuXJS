// CLI:
> var invalidBase = null;
> var objectPropertyName = { toString: function() { print("to string called!"); return 'x' } };
> try { invalidBase[objectPropertyName] = 0 } catch (e) { print(e.name) }
< TypeError
-
