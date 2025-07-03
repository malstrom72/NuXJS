> (function() { var i = 123; try { throw "x" } catch (x) { print(i) } })()
< 123
-
> (function() { var i = 123; try { throw "x" } catch (x) { (function() { print(i) })() } })()
< 123
-
> (function() { var j = 456, x = 101112; (function() { var i = 123, y = 131415; try { throw 789 } catch (x) { (function() { print(i); print(j); print(x) })() } })() })()
< 123
< 456
< 789
-
> (function() { var j = 456; (function() { var i = 123; with ({}) { (function() { print(i); print(j) })() } })() })()
< 123
< 456
-
> (function() { var j = 456; (function() { var i = 123; try { return; } finally { (function() { print(i); print(j) })() } })() })()
< 123
< 456
-
> (function() { var j = 456; (function() { var i = 123; try { return; } finally { (function() { print(i); print(j); return })() } })() })()
< 123
< 456
-
> (function() { var j = 456; (function() { var i = 123; try { return; } finally { (function() { print(i); print(j); return; print("no") })() } })() })()
< 123
< 456
-
> (function() { var j = 456; (function() { var i = 123; try { return; } finally { (function() { print(i); print(j) })(); return; print("no") } })() })()
< 123
< 456
-
> (function() { with({x:"yeah"}) { (function() { print(x) })() } })()
< yeah
-
> (function() { var x = "nope"; with({x:"yeah"}) { (function() { print(x) })() } })()
< yeah
-
