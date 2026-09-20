// A store tail armed by makeAssignment stays live across the end of an eval statement, because eval keeps the
// completion value and makeRValue emits nothing for PUSHED. markBackwardBranch() emits nothing either, so before
// it cleared storeTailEnd the next statement's discard() -> dropStoreTailValue() deleted an instruction out from
// under the loop target: the loop re-entered one instruction into its own body and the operand stack desynced.
// The three cases below are the three symptoms one shape produced - a segfault, a bogus TypeError, and a silently
// wrong answer - which are worth keeping apart because a half-regression need not show all three.
> print(eval("var o = {}, i = 0; o.a = 1; do { i = i + 1; } while (i < 3); i"))
< 3
> print(eval("var o = {}, m = 0; o.a = 1; do { m++; o.b = m; } while (m < 3); o.b"))
< 3
> print(eval("var o = {}, i = 0; o.p = 1; do o.q = ++i; while (i < 3); o.q"))
< 3
-
// makeAssignment arms the tail for a NAMED target as well as a PROPERTY one.
> print(eval("var g = 0, n = 0; g = 1; do { n = n + 1; } while (n < 4); n + g"))
< 5
-
// while and for reach markBackwardBranch() by their own routes, and switchStatement marks once per `case` and
// again for `default`, which is the second caller that had the hole.
> print(eval("var o = {}, i = 0; o.a = 1; while (i < 3) { i = i + 1; } i"))
< 3
> print(eval("var o = {}, s = 0; o.a = 1; for (var i = 0; i < 4; ++i) { s += i; } s"))
< 6
> print(eval("var o = {}; o.a = 1; switch (2) { case 1: 'one'; break; case 2: 'two'; break; default: 'other' }"))
< two
-
