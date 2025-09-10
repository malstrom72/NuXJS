> (function() { try { throw 1 } catch (e) { print(e) } })()
< 1
-
> try { eval("(function() { try { throw\n1 } catch (e) { print(e) } })()") } catch (e) { print(e.name) }
< SyntaxError
-
