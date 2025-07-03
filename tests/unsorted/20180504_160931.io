> callbackTest(1,2,3,function() { print("cb 4") },5)
< 1
< 2
< 3
< cb 4
< 5
-
> callbackTest(1,2,3,function() { print("cb 4") },5,callbackTest)
< 1
< 2
< 3
< cb 4
< 5
! !!!! RangeError: Stack overflow
-
> callbackTest(1,2,3,function() { print("cb 4") },5,function f() { callbackTest(f) })
< 1
< 2
< 3
< cb 4
< 5
! !!!! RangeError: Stack overflow
-
