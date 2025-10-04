> print((function() { out: try { if (false) return 3 } finally { print("bye"); break out }; print("here") })())
< bye
< here
< undefined
-
> print((function() { try { if (false) return 3 } finally { print("bye"); return 7 } })())
< bye
< 7
-
> print((function() { try { return 3 } finally { print("bye"); return 7 } })())
< bye
< 7
-
> print((function() { try { return 3 } finally { print("bye"); } })())
< bye
< 3
-
