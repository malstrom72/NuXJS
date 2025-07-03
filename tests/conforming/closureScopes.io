> var f = (function() { var a = "b"; try { } catch (x) { } finally { return function(x) { return x + a } } })()
-
> print(f("c"))
< cb
-
> print(f("d"))
< db
-
> var f = (function() { var a = "b"; try { return function(x) { throw "yo" } } catch (x) { print("caught: " + x) } })()
-
> try { print(f("c")) } catch (x) { print("caught here: " + x) }
< caught here: yo
-
> var f = (function() { var a = "b"; try { throw "z" } catch (x) { return function(y) { return a + x + y } } })()
-
> print(f("d"))
< bzd
-
> var f = (function() { var a = "b"; try { throw { m: "n" } } catch (x) { with (x) { return function(y) { return a + m + y } } } })()
-
> print(f("e"))
< bne
-
