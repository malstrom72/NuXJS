> (function f() { print(arguments.callee === f); arguments.callee=5; print(arguments.callee); print(delete arguments.callee); print(arguments.callee); })()
< true
< 5
< true
< undefined
-
