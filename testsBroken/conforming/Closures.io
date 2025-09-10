> f = function(i) { return (function() { return ++i; }) }
> g = f(3000)
> print(g())
< 3001
-
> print(g())
< 3002
-
> print(g())
< 3003
-
> f = function(i,b) { try { throw i; } catch (x) { return (function() { return ++x + b; }) } }
> g = f(1234,1000)
-
> print(g())
< 2235
-
> print(g())
< 2236
-
> print(g())
< 2237
-
> f = function(i,b) { with({x:i}) { return (function() { return ++x + b; }) } }
> g = f(5555,100)
-
> print(g())
< 5656
-
> print(g())
< 5657
-
> print(g())
< 5658
-
> f = function(i, b) { try { throw {x:i}; } catch (e) { with (e) { return (function() { return ++x + b; }) } } }
> g = f(10000,100)
-
> print(g())
< 10101
-
> print(g())
< 10102
-
> print(g())
< 10103
-
> f = function(i) { return eval("(function() { return ++i; })") }
> g = f(3000)
> print(g())
< 3001
-
> print(g())
< 3002
-
> print(g())
< 3003
-
> f = function(i,b) { try { throw i; } catch (x) { return eval("(function() { return ++x + b; })") } }
> g = f(1234,1000)
-
> print(g())
< 2235
-
> print(g())
< 2236
-
> print(g())
< 2237
-
> f = function(i,b) { with({x:i}) { return eval("(function() { return ++x + b; })") } }
> g = f(5555,100)
-
> print(g())
< 5656
-
> print(g())
< 5657
-
> print(g())
< 5658
-
> f = function(i, b) { try { throw {x:i}; } catch (e) { with (e) { return eval("(function() { return ++x + b; })") } } }
> g = f(10000,100)
-
> print(g())
< 10101
-
> print(g())
< 10102
-
> print(g())
< 10103
-
