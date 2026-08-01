// ES5.1 10.6: a strict function's arguments object is non-mapped, so its indexed values are a copy of what was
// passed, taken when control entered the function. The engine only has those values in the FunctionScope
// constructor, so it has to decide there whether to capture, from a compile-time flag. That flag used to be set
// only by a lexical reference to `arguments`; a *direct eval* reaches the same scope by name and can ask for
// `arguments` without the body ever naming it, and the object was then built from the parameter slots as they
// stood at that moment, silently behaving like a mapped one snapshotted late. Verified against V8.
// The lexical case was always right, and is the control for everything below.
> print((function (a) { "use strict"; a = 9; return arguments[0]; })(1))
< 1
// The bug: `arguments` appears only inside the eval string, so nothing lexical names it.
> print((function (a) { "use strict"; a = 9; return eval("arguments[0]"); })(1))
< 1
> print((function (a, b) { "use strict"; a = 9; b = 8; return eval("arguments[0] + ',' + arguments[1]"); })(1, 2))
< 1,2
-
// The flag is per function: an inner function captures its own arguments, and an outer one is not dragged in.
> print((function (a) { "use strict"; a = 9; return (function (b) { b = 7; return eval("arguments[0]"); })(5); })(1))
< 5
// A nested eval still reaches the same scope, and an eval that never runs still had to arm the capture.
> print((function (a) { "use strict"; a = 9; return eval("eval('arguments[0]')"); })(1))
< 1
> print((function (a) { "use strict"; a = 9; if (false) { eval("0") } return eval("arguments[0]"); })(1))
< 1
-
// Capturing at entry is what makes the object independent of the parameters in both directions.
> print((function (a) { "use strict"; var o = eval("arguments"); a = 9; return o[0]; })(1))
< 1
> print((function (a) { "use strict"; var o = eval("arguments"); o[0] = 7; return a + "/" + o[0]; })(1))
< 1/7
-
// The captured object is the whole argument list, not just the declared parameters, and it is a real 10.6 object
// with the poison pills and the "Arguments" class.
> print((function (a) { "use strict"; a = 9; return eval("arguments.length + ':' + arguments[0] + ',' + arguments[1]"); })(1, 2))
< 2:1,2
> print((function (a, b) { "use strict"; a = 9; return eval("arguments.length + ':' + arguments[0] + ',' + arguments[1]"); })(1))
< 1:1,undefined
> print((function (a) { "use strict"; return eval("try { arguments.callee } catch (e) { e.name }"); })(1))
< TypeError
> print((function (a) { "use strict"; a = 9; return eval("Object.prototype.toString.call(arguments)"); })(1))
< [object Arguments]
-
// Non-strict is mapped and must stay live in both directions, which is what the capture must not be applied to.
> print((function (a) { a = 9; return eval("arguments[0]"); })(1))
< 9
> print((function (a) { eval("arguments[0] = 7"); return a; })(1))
< 7
-
