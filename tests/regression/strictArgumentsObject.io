> function f(a){ "use strict"; arguments[0] = 2; return a === 1 && arguments[0] === 2; }
> print(f(1))
< true
-
> function g(a){ "use strict"; a = 3; return arguments[0] === 1; }
> print(g(1))
< true
-
