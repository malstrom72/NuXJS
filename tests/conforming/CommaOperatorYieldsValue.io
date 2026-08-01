// 11.14: the comma operator applies GetValue to both of its operands, so its result is a value and never a
// Reference. The compiler used to hand the right operand's ExpressionResult straight back, which leaked a
// reference into every construct that asks "is this a Reference, and to what?". Each case below is paired with
// the parenthesised form, which must keep the reference (11.1.6), and with the bare form as a control.
// Verified against V8, except where noted.
> var theGlobal = this;
> function attempt(src) { try { return eval(src) } catch (e) { return e.name } }
-
// 11.2.3: the this value of a call comes from the base of the callee reference. A comma has no base, so the
// call gets undefined and a non-strict function substitutes the global object.
> var o = { f: function () { return this === o ? "obj" : (this === theGlobal ? "global" : "other") } };
> print(o.f() + " " + (o.f)() + " " + (0, o.f)())
< obj obj global
// The function itself is still the same one, it is only reached without a base.
> print((0, o.f) === o.f)
< true
-
// 15.1.2.1.1: an eval call is direct only when the callee expression is a reference named "eval". A comma makes
// it indirect, so 10.4.2 runs the code in the global scope, where the caller's locals are not visible.
> var shadowed = "global";
> function readDirect() { var shadowed = "local"; return eval("shadowed") }
> function readParens() { var shadowed = "local"; return (eval)("shadowed") }
> function readComma() { var shadowed = "local"; return (0, eval)("shadowed") }
> print(readDirect() + " " + readParens() + " " + readComma())
< local local global
// Not visible means not writable either, which is the part that matters for sandboxing.
> function writeDirect() { var x = 1; eval("x = 99"); return x }
> function writeComma() { var x = 1; (0, eval)("x = 99"); return x }
> print(writeDirect() + " " + writeComma())
< 99 1
-
// 11.4.3 answers "undefined" for an unresolvable Reference. A comma has already called GetValue on it, so
// 11.14 throws before typeof ever sees it.
> print(attempt("typeof undecl") + " " + attempt("typeof (undecl)") + " " + attempt("typeof (0, undecl)"))
< undefined undefined ReferenceError
-
// 11.4.1 answers true for an operand that is not a Reference, so the comma form reports a deletion it did not
// do. The parenthesised form still reaches the var, which is DontDelete.
> var deletable = 1;
> print(attempt("delete (deletable)") + " " + attempt("delete (0, deletable)") + " " + deletable)
< false true 1
-
// 11.13.1 and 11.3.1: PutValue on something that is not a Reference is a ReferenceError. V8 rejects both of
// these earlier, as a SyntaxError, which is an ES5.1 versus modern divergence and not an engine difference.
> var target = 1;
> print(attempt("(target) = 5") + " " + target)
< 5 5
> print(attempt("(0, target) = 9") + " " + target)
< ReferenceError 5
> print(attempt("(0, target)++") + " " + target)
< ReferenceError 5
-
// What must not change: both operands are still evaluated, left to right, and the left one is still resolved
// (so it can still throw) before its value is discarded.
> var log = "";
> function step(n) { log += n; return n }
> print((step(1), step(2)) + " " + log)
< 2 12
> print((1, 2, 3) + " " + attempt("(undecl, 1)"))
< 3 ReferenceError
-
// A comma that separates arguments or array elements is not the operator and is untouched.
> var a = [(1, 2), 3];
> print(a.length + " " + a[0] + " " + a[1] + " " + [1, 2].length)
< 2 2 3 2
> for (var i = 0, j = 5, r = ""; i < 3; ++i, --j) r += "" + i + j + ",";
> print(r)
< 05,14,23,
-
