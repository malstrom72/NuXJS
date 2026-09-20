// A store tail armed by makeAssignment stays live across the end of an eval statement, because eval keeps the
// completion value and makeRValue emits nothing for PUSHED. markBackwardBranch() emits nothing either, so before
// it cleared storeTailEnd the next statement's discard() -> dropStoreTailValue() deleted an instruction out from
// under the loop target: the loop re-entered one instruction into its own body and the operand stack desynced.
// `o.a = 1` (a PROPERTY store) arms the tail, the do/while marks, and the identifier after it discards.
> print(eval("var o = {}, i = 0; o.a = 1; do { i = i + 1; } while (i < 3); i"))
< 3
-
// The same shape with a property store inside the loop, which used to report `undefined is not a function`.
> print(eval("var o = {}, m = 0; o.a = 1; do { m++; o.b = m; } while (m < 3); o.b"))
< 3
-
// And the silent one: this answered 1 rather than 3, no error at all.
> print(eval("var o = {}, i = 0; o.p = 1; do o.q = ++i; while (i < 3); o.q"))
< 3
-
// A NAMED store arms the tail too (makeAssignment arms it for NAMED and PROPERTY alike).
> print(eval("var g = 0, n = 0; g = 1; do { n = n + 1; } while (n < 4); n + g"))
< 5
-
// while and for mark the same way, so they take the identical path.
> print(eval("var o = {}, i = 0; o.a = 1; while (i < 3) { i = i + 1; } i"))
< 3
> print(eval("var o = {}, s = 0; o.a = 1; for (var i = 0; i < 4; ++i) { s += i; } s"))
< 6
-
// switchStatement marks backwards for every `case` and for `default`, so a store tail ahead of a switch reaches
// the same code path through markBackwardBranch().
> print(eval("var o = {}; o.a = 1; switch (2) { case 1: 'one'; break; case 2: 'two'; break; default: 'other' }"))
< two
> print(eval("var o = {}; o.a = 1; switch (9) { case 1: 'one'; break; default: 'other' }"))
< other
-
// Nested loops after a store tail, so the marker is dropped more than once in one statement run.
> print(eval("var o = {}, t = 0; o.a = 1; do { var j = 0; do { t = t + 1; j = j + 1; } while (j < 2); } while (t < 6); t"))
< 6
-
// The peephole itself still has to work: a discarded store is the whole point of dropStoreTailValue, and these
// run in eval code where the marker survives the statement. Values, not shapes, but a desync shows up here too.
> print(eval("var o = { p: 0 }; o.p = 7; o.p"))
< 7
> print(eval("var o = { p: 0 }, k = 0; o.p = 7; k = 8; o.p + k"))
< 15
-
