> g=(function f() { var i = 0, f; do { if (i == 1) return f; f = (function() { return i }); ++i; } while (true) })()
> print(g())
< 1
-
> g=(function f() { var i = 234, f; return f; function f() { return i } })()
> print(g())
< 234
-
