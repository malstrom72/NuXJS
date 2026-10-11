// Named reads, writes, deletes and var declarations through a scope chain of tens of thousands of scopes.
> var o = { }, count = 0, open = "", close = ""
> for (var i = 0; i < 15; ++i) { open += "return (function () { "; close += "})() " }
> var src = "(function () { with (o) try { throw 0 } catch (e) { " + open + "++count; tmp = count; delete tmp; return eval(src) " + close + "} })"
> var g = eval(src)
> for (var i = 0; i < 1200; ++i) g = g()
> print(count + " " + typeof tmp + " " + typeof g)
< 1200 undefined function
-
> var depth = 0, s = "with (o) { var q; if (++depth < 1000) eval(s) }"
> eval(s)
> print(depth + " " + ("q" in this))
< 1000 true
-
