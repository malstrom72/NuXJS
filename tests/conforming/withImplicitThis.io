// 11.2.3 gives a call the this value of the Reference it was reached through: step 6 takes GetBase of the
// MemberExpression, and step 7 keeps that base unless it is an activation object, in which case "null is used as
// the this value of the call" (10.1.6). A `with` puts its object at the front of the scope chain, so a name found
// on that object yields a Reference whose base is the object itself - not an activation object - and the call
// receives it as this. NuXJS resolved such names correctly but dropped the base on the floor, so every one of
// these calls ran with the global object as this instead.
// What governs this throughout is the *definition* site, never the call site: `with` extends the lexical scope
// chain, so a function merely called from inside the block sees nothing of it (the ReferenceError section below).
> var globalObject = (function () { return this })()
> function tag(x) { return (x === undefined ? "undefined" : (x === globalObject ? "global" : (x && x.id ? x.id : "?"))) }
> var o = { id: "o", m: function () { return tag(this) } }
-
// The plain case: a bare-name call inside the block is called on the with object.
> with (o) { print(m()) }
< o
-
// Definition site, not call site - so the closure still carries the receiver after the block has exited, and
// through any depth of nesting.
> var later; with (o) { later = function () { return m() } } print(later())
< o
> var deep; with (o) { deep = function () { return function () { return m() } } } print(deep()())
< o
-
// A function defined outside the block sees nothing when called from inside it, and that stays a ReferenceError.
// Being a method of the with object itself buys nothing either - `sib` was defined where no `with` was in scope -
// and this is the case an over-eager fix would be tempted to make work, which would be wrong.
> function outside() { try { return m() } catch (e) { return e.name } } with (o) { print(outside()) }
< ReferenceError
> var p = { id: "p", m: function () { return tag(this) }, sib: function () { try { return m() } catch (e) { return e.name } } }
> with (p) { print(sib()) }
< ReferenceError
-
// A name the with object does not carry falls through to the rest of the chain and brings no receiver with it.
> function g() { return tag(this) } with (o) { print(g()) }
< global
-
// GetBase is the object named by the `with`, not whichever object along its prototype chain actually holds the
// property.
> function Proto() { } Proto.prototype.m = function () { return tag(this) }
> var q = new Proto(); q.id = "q"; with (q) { print(m()) }
< q
-
// The with object shadows a local of the enclosing function, receiver included.
> function shadow() { var m = function () { return tag(this) }; with (o) { return m() } } print(shadow())
< o
