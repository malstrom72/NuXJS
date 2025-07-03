> (function() { var o = { n: null }; first = o; for (var i = 0; i < 1000000; ++i) { o.n = { n: null }; o = o.n; } })();
> (function() { var o = first, count = 0; while (o.n) { ++count; o = o.n; }; print(count) })();
< 1000000
-
