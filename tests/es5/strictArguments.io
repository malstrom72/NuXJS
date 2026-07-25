// ES5.1 10.6: the strict-mode arguments object is non-mapped, captures its values at entry, and has
// [[ThrowTypeError]] poison-pill callee and caller. (Non-strict arguments is mapped, per 10.6.)
// Non-mapped: writing arguments[i] does not change the parameter, and vice versa.
> function f(a) { "use strict"; arguments[0] = 99; return a; }
> print(f(1))
< 1
> function g(a) { "use strict"; a = 7; return arguments[0]; }
> print(g(1))
< 1
-
// Values are captured at entry, so reassigning the parameter first does not change arguments[i].
> function entry(a) { "use strict"; a = 500; return arguments[0]; }
> print(entry(42))
< 42
-
// Non-strict arguments remains mapped (writing arguments[i] updates the parameter).
> function mapped(a) { arguments[0] = 99; return a; }
> print(mapped(1))
< 99
-
// length is the number of arguments actually passed.
> function len() { "use strict"; return arguments.length; }
> print(len(10, 20, 30)); print(len())
< 3
< 0
-
// 10.6: strict arguments.callee and arguments.caller are poison pills (both throw TypeError in ES5.1).
// The get AND set are the [[ThrowTypeError]] pill, so reading or writing either throws.
> function pc() { "use strict"; try { return arguments.callee; } catch (e) { return e.name; } }
> print(pc())
< TypeError
> function pl() { "use strict"; try { return arguments.caller; } catch (e) { return e.name; } }
> print(pl())
< TypeError
> function ps() { "use strict"; try { arguments.callee = 1; return "no throw"; } catch (e) { return e.name; } }
> print(ps())
< TypeError
-
// Non-strict arguments.callee is the function itself.
> function sl() { return arguments.callee === sl; }
> print(sl())
< true
-
// Indexed access still reads the passed value in strict mode.
> function idx(a, b) { "use strict"; return arguments[0] + ":" + arguments[1] + ":" + arguments.length; }
> print(idx(5, 6))
< 5:6:2
-
