> (function f(doit) { if (!doit) return; var i = 0; do { print(i); f(false); eval("var f = (function() { print('hello') })"); } while (++i < 2); })(true)
< 0
< 1
< hello
-
> print(this.f)
< undefined
-
> (function f(doit) { if (!doit) return; var i = 0; do { print(i); f(false); var e = eval; e("var f = (function() { print('hello') })"); } while (++i < 2); })(true)
< 0
< 1
-
> print(this.f)
< function () { print('hello') }
-
