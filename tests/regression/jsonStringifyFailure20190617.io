> var a = []; for (var i = 0; i < 100; ++i) { var b = []; for (var j = 0; j < 100; ++j) b[j] = j; a[i] = b; }
> var s = JSON.stringify(a)
> print("OK")
< OK
-
