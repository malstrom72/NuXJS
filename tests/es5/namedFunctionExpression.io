// ES5.1 13: `function Identifier ( ... ) { ... }` used as an expression gets its own declarative environment
// holding an immutable binding for Identifier, created before the closure and initialised to it. So the name is
// visible inside, invisible outside, and cannot be reassigned. Verified against V8.
> var f = function me() { return typeof me; }; print(f())
< function
> var f = function me() { return me === f; }; print(f())
< true
> var f = function me() { }; print(typeof me)
< undefined
-
// The binding is immutable (10.2.1.1.5), so a non-strict assignment to it is silently ignored rather than
// rebinding, and the name still resolves to the function afterwards.
> var f = function me() { me = 5; return typeof me; }; print(f())
< function
> var f = function me() { me = 5; return me === f; }; print(f())
< true
> var f = function me() { me = 5; }; f(); print(typeof me)
< undefined
-
// In strict code the same assignment is a TypeError instead of a silent no-op.
> var f = eval("(function me() { 'use strict'; me = 5; })"); try { f(); print("no throw") } catch (e) { print(e.name) }
< TypeError
-
// The environment sits between the closure and the function's own scope, so a parameter or a var of the same name
// shadows it, and it does not disturb an outer binding that happens to share the name.
> var f = function me(me) { return me; }; print(f(7))
< 7
> var f = function me() { var me = 3; return me; }; print(f())
< 3
> var outer = 1; var f = function outer() { return outer; }; f(); print(outer)
< 1
> var outer = 1; var f = function outer() { return outer === f; }; print(f() + " " + outer)
< true 1
-
// It is per-closure and survives being returned, since it lives in the function's own environment record.
> function make() { return function me() { return me; }; } var a = make(), b = make(); print((a() === a) + " " + (b() === b) + " " + (a === b))
< true true false
> var f = function me() { return function () { return me; }; }; print(f()() === f)
< true
-
// A function *declaration* is different: it binds its name in the enclosing scope, and that binding is mutable.
> function decl() { return typeof decl; } print(decl() + " " + typeof decl)
< function function
> function decl2() { decl2 = 5; return typeof decl2; } print(decl2())
< number
-
