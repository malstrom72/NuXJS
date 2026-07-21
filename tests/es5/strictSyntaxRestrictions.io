// ES5.1 strict-mode syntax restrictions (compile-time SyntaxErrors). Verified to match V8.
// 12.10.1: `with` is forbidden in strict mode.
> try { eval('"use strict"; with ({}) {}'); print("no error") } catch (e) { print(e.name) }
< SyntaxError
// ...but allowed in non-strict code.
> with ({}) {} print("with-ok")
< with-ok
-
// 11.4.1: `delete` of a direct identifier reference is a SyntaxError in strict mode.
> try { eval('"use strict"; var x = 1; delete x;'); print("no error") } catch (e) { print(e.name) }
< SyntaxError
// ...whether the identifier is a local variable, an undeclared name, or a parameter.
> try { eval('"use strict"; delete undeclaredName;'); print("no error") } catch (e) { print(e.name) }
< SyntaxError
> try { eval('"use strict"; (function (a) { return delete a; });'); print("no error") } catch (e) { print(e.name) }
< SyntaxError
-
// delete of a property reference is always allowed.
> "use strict";
> var o = { p: 1 }; print(delete o.p); print(o.p)
< true
< undefined
-
// Non-strict delete of an identifier is allowed (and returns false for a non-configurable binding).
> var y = 1; print(delete y); print(typeof y)
< false
< number
-
// delete of a non-reference expression is fine in strict mode.
> "use strict";
> print(delete "not a reference"); print(delete (1 + 1))
< true
< true
-
