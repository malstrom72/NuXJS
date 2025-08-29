> eval("\"use strict\"; var x = 1; delete x;")
! !!!! SyntaxError: Deleting identifier in strict code
-
> function f(){ "use strict"; var y; delete y; }
! !!!! Line: 1
! !!!! SyntaxError: Deleting identifier in strict code
-
