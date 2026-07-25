// ES5.1 13.2.3: a strict-mode function object's own caller and arguments are [[ThrowTypeError]] poison pills;
// reading or writing either throws a TypeError.
> function f() { "use strict"; return 42; }
> try { f.caller; print("no throw") } catch (e) { print(e.name) }
< TypeError
> try { f.arguments; print("no throw") } catch (e) { print(e.name) }
< TypeError
> try { f.caller = 1; print("no throw") } catch (e) { print(e.name) }
< TypeError
> try { f.arguments = 1; print("no throw") } catch (e) { print(e.name) }
< TypeError
-
// The function is otherwise normal: callable, with intact name / length / prototype.
> print(f()); print(typeof f); print(f.name); print(f.length); print(typeof f.prototype)
< 42
< function
< f
< 0
< object
-
// caller / arguments are non-enumerable poison pills, not data properties.
> var d = Object.getOwnPropertyDescriptor(f, "caller");
> print(typeof d.get); print(typeof d.set); print(d.enumerable); print(d.configurable)
< function
< function
< false
< false
-
// A non-strict function is unaffected (caller / arguments are the legacy undefined here, not poison pills).
> function g() { return 1; }
> print(typeof g.caller); print(typeof g.arguments)
< undefined
< undefined
-
