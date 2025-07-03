> function f(x) { var y = (x > 0 ? f(x - 1) : 0); return x * 10 + y; }
> print(f(1000))
< 5005000
-
> print(f(10000))
! !!!! RangeError: Stack overflow
-
> print(f(100000))
! !!!! RangeError: Stack overflow
-
> print(f(1000000))
! !!!! RangeError: Stack overflow
-
