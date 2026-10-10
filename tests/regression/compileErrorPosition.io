// a compile error from eval or new Function names its own position first, before the caller's frames
> try { eval("var a = 1;\nvar b = (;") } catch (e) { print(e.stack.split("\n")[1]) }
<     at <eval>:2:10
-
> function f() { eval("1 +") } try { f() } catch (e) { print(e.stack.split("\n").slice(1, 3).join("|")) }
<     at <eval>:1:4|    at f (<eval>:1:27)
-
> try { new Function("a", "return a +") } catch (e) { print(e.stack.split("\n")[1]) }
<     at <anonymous>:3:1
-
