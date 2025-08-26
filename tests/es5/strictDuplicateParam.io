> function f(a, a){ "use strict"; }
! !!!! Line: 1
! !!!! SyntaxError: Duplicate parameter name not allowed in strict code
-
> function g(a, a){ return a; }
> print(g(1))
< undefined
-
> eval("\"use strict\"; function h(a, a){ return a; }")
! !!!! SyntaxError: Duplicate parameter name not allowed in strict code
-
