// ES5.1 10.4.2 (Entering Eval Code): non-strict eval shares the calling context's variable environment, so its
// var/function declarations LEAK to the caller. Strict eval code - whether strict by its own directive or because a
// direct eval was called from strict code (strictness is inherited) - gets its OWN environment, so declarations are
// discarded when it returns. Reads and writes of pre-existing outer bindings still reach the enclosing scope.
// Non-strict direct eval leaks a declared var into the calling function.
> function ns() { eval("var leak1 = 11;"); return typeof leak1; }
> print(ns())
< number
-
// A direct eval from strict code is itself strict (inherited), so its declarations do NOT leak.
> function inh() { "use strict"; eval("var leak2 = 22;"); return typeof leak2; }
> print(inh())
< undefined
-
// Eval code with its own "use strict" directive is strict too - same isolation, even without an enclosing strict scope.
> function own() { eval("'use strict'; var leak3 = 33;"); return typeof leak3; }
> print(own())
< undefined
-
// Strict eval can still READ an outer binding it did not declare.
> function rd() { "use strict"; var x = 5; return eval("x + 1"); }
> print(rd())
< 6
-
// Strict eval can still WRITE an existing outer binding (only its own new declarations are isolated).
> function wr() { "use strict"; var x = 5; eval("x = 9"); return x; }
> print(wr())
< 9
-
// A var declared inside strict eval shadows in the eval's own env only; the outer binding of the same name is untouched.
> var g1 = 100;
> function sh() { "use strict"; eval("var g1 = 7;"); return g1; }
> print(sh()); print(g1)
< 100
< 100
-
// Inherited strictness applies at PARSE time: `with` is a SyntaxError in the strict-inheriting eval code.
> function wth() { "use strict"; try { eval("with({}){}"); return "no throw"; } catch (e) { return e.name; } }
> print(wth())
< SyntaxError
-
// A non-strict direct eval still accepts `with`.
> function wok() { try { eval("with({a:1}){ }"); return "ok"; } catch (e) { return e.name; } }
> print(wok())
< ok
-
// Indirect eval (called through a reference other than the plain `eval` name) does NOT inherit caller strictness and
// runs in the global scope, so `with` is accepted even though the caller is strict.
> function ind() { "use strict"; var e = eval; return e("with({}){ }; 'ok'"); }
> print(ind())
< ok
-
