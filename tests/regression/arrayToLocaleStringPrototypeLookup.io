// CLI:
> var sentinel = { toLocaleString: function() { return "proto"; } }
> Array.prototype[0] = sentinel
> var sparse = []
> sparse.length = 1
> print(sparse.toLocaleString())
< proto
> delete Array.prototype[0]
-
