> hit = 0
-
> function rhs() { hit = 1; return 1; }
-
> undefVar = rhs()
! !!!! ReferenceError: undefVar is not defined
> hit
0
-
