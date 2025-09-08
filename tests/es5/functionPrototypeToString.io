> try { Function.prototype.toString.call({}); } catch (e) { print(e instanceof TypeError); }
< true
-
> print(Function.prototype.toString.call(print));
< function() { [native code] }
-
> var s = Function.prototype.toString.call(function f(a,b){ return a+b; });
> print(s.indexOf("function f(a,b)") === 0);
< true
-
