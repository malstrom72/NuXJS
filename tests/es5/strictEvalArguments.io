// ES5.1: strict mode forbids `eval` and `arguments` as assignment targets and as binding names, and forbids
// duplicate parameter names. All cases verified to match V8.
// 11.13.1 / 11.4.4 / 11.4.5: eval / arguments may not be an assignment or ++/-- target.
> try { eval('"use strict"; eval = 1;'); print("no error") } catch (e) { print(e.name) }
< SyntaxError
> try { eval('"use strict"; arguments = 1;'); print("no error") } catch (e) { print(e.name) }
< SyntaxError
> try { eval('"use strict"; eval++;'); print("no error") } catch (e) { print(e.name) }
< SyntaxError
> try { eval('"use strict"; --arguments;'); print("no error") } catch (e) { print(e.name) }
< SyntaxError
> try { eval('"use strict"; arguments += 1;'); print("no error") } catch (e) { print(e.name) }
< SyntaxError
-
// 12.2.1 / 13.1: eval / arguments may not be bound by var, function, parameter, or catch.
> try { eval('"use strict"; var eval;'); print("no error") } catch (e) { print(e.name) }
< SyntaxError
> try { eval('"use strict"; function arguments() {}'); print("no error") } catch (e) { print(e.name) }
< SyntaxError
> try { eval('"use strict"; function f(eval) {}'); print("no error") } catch (e) { print(e.name) }
< SyntaxError
> try { eval('"use strict"; try {} catch (arguments) {}'); print("no error") } catch (e) { print(e.name) }
< SyntaxError
> try { eval('"use strict"; (function eval() {});'); print("no error") } catch (e) { print(e.name) }
< SyntaxError
-
// 13.1: duplicate parameter names are a SyntaxError in strict mode.
> try { eval('"use strict"; function f(a, a) {}'); print("no error") } catch (e) { print(e.name) }
< SyntaxError
> try { eval('"use strict"; function f(a, b, a) {}'); print("no error") } catch (e) { print(e.name) }
< SyntaxError
-
// The strictness may come from an own directive that appears after the parameter list (checked retroactively).
> try { eval('function f(a, a) { "use strict"; }'); print("no error") } catch (e) { print(e.name) }
< SyntaxError
> try { eval('(function eval() { "use strict"; });'); print("no error") } catch (e) { print(e.name) }
< SyntaxError
-
// ...or be inherited from enclosing strict code without an own directive.
> try { eval('"use strict"; function outer() { function f(x, x) {} }'); print("no error") } catch (e) { print(e.name) }
< SyntaxError
-
// Only *bare identifier* references are restricted; property names eval / arguments are fine.
> "use strict";
> var o = {}; o.eval = 1; o.arguments = 2; o.eval++;
> print(o.eval + "," + o.arguments)
< 2,2
-
// Legitimate strict code is unaffected.
> "use strict";
> var e = 1; e = 2; e++; function g(a, b) { return a + b; }
> print(e); print(g(3, 4))
< 3
< 7
-
// In non-strict code, all of these are allowed (a duplicate parameter keeps the last binding).
> var eval2; eval2 = 1; function f(a, a) { return a; }
> print(f(1, 2)); print(eval2)
< 2
< 1
-
