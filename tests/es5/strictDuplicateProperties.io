// ES5.1 11.1.5: an ObjectLiteral with more than one definition of the same data property is a SyntaxError in strict
// code (non-strict code keeps the last definition). Data/accessor collisions and duplicate same-kind accessors are
// errors in BOTH modes. These are early errors, so they are probed through eval.
// NOTE: ES2015 removed the strict duplicate-data-property restriction, so V8 accepts all of these; ES5.1 arbitrates.
// Two data properties with the same name: legal non-strict (last wins), SyntaxError in strict code.
> print(eval("({a:1, a:2}).a"))
< 2
> try { eval("'use strict'; ({a:1, a:2})"); print("no throw") } catch (e) { print(e.name) }
< SyntaxError
-
// The names are compared after conversion to String, so a numeric and a string key can collide.
> try { eval("'use strict'; ({1:1, '1':2})"); print("no throw") } catch (e) { print(e.name) }
< SyntaxError
> print(eval("({1:1, '1':2})['1']"))
< 2
-
// Three or more, and non-adjacent duplicates, are caught too.
> try { eval("'use strict'; ({a:1, b:2, a:3})"); print("no throw") } catch (e) { print(e.name) }
< SyntaxError
-
// Distinct names remain fine in strict code.
> print(eval("'use strict'; var o = {a:1, b:2, c:3}; o.a + o.b + o.c"))
< 6
-
// A data / accessor collision is an error in both modes (11.1.5 cases 2 and 3).
> try { eval("({get a(){}, a:2})"); print("no throw") } catch (e) { print(e.name) }
< SyntaxError
> try { eval("({a:2, get a(){}})"); print("no throw") } catch (e) { print(e.name) }
< SyntaxError
-
// Two getters (or two setters) for the same name collide in both modes (11.1.5 case 4).
> try { eval("({get a(){}, get a(){}})"); print("no throw") } catch (e) { print(e.name) }
< SyntaxError
> try { eval("({set a(v){}, set a(v){}})"); print("no throw") } catch (e) { print(e.name) }
< SyntaxError
-
// A getter and a setter for the same name are the one legal pairing, in both modes.
> var o = eval("'use strict'; ({get a(){ return 7 }, set a(v){ this.w = v }})");
> o.a = 3; print(o.a); print(o.w)
< 7
< 3
-
// 11.1.5: a setter parameter named eval or arguments is a SyntaxError in strict code.
> try { eval("'use strict'; ({set x(eval){}})"); print("no throw") } catch (e) { print(e.name) }
< SyntaxError
> try { eval("'use strict'; ({set x(arguments){}})"); print("no throw") } catch (e) { print(e.name) }
< SyntaxError
-
