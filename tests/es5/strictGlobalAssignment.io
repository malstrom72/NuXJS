// ES5.1 8.7.2 / 11.13.1: strict-mode assignment to an unresolvable or read-only identifier throws at runtime.
// Verified against V8. (Read-only *global constants* NaN/Infinity/undefined become non-writable with the §7
// read-only-globals change; once that lands, strict assignment to them throws TypeError through this same path.)
// Assignment to an undeclared identifier throws a ReferenceError instead of creating a global binding.
> function f() { "use strict"; undeclaredXYZ = 1; }
> try { f(); print("no error") } catch (e) { print(e.name) }
< ReferenceError
> function inc() { "use strict"; missingName++; }
> try { inc(); print("no error") } catch (e) { print(e.name) }
< ReferenceError
> function cmp() { "use strict"; missingName += 5; }
> try { cmp(); print("no error") } catch (e) { print(e.name) }
< ReferenceError
-
// Assignment to a read-only binding throws a TypeError. A named function expression's own name is read-only.
> var h = function named() { "use strict"; named = 1; return 1; };
> try { h(); print("no error") } catch (e) { print(e.name) }
< TypeError
-
// Assigning to a writable binding (a declared variable, or a writable global) is allowed in strict mode.
> "use strict";
> Object = Object; var declared; declared = 9; declared = declared + 1; print(declared)
< 10
-
// In non-strict code, assigning to an undeclared name creates a global (no error).
> nonStrictGlobal = 42; print(nonStrictGlobal)
< 42
-
