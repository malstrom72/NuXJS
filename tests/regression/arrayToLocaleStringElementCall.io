// CLI:
> var calls = 0
> var arr = []
> arr[0] = { toLocaleString: function() { calls += 1; return "wrapped"; } }
> arr[1] = null
> arr[2] = void 0
> print(arr.toLocaleString())
< wrapped,,
> print(calls)
< 1
-
