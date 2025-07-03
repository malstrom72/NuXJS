> print(eval("with ({x:3}) { x }"))
< 3
-
> print(eval("try { y;with ({x:3,y:99}) { x } } catch (x) { x }"))
< ReferenceError: y is not defined
-
