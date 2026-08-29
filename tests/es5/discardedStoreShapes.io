// The value-producing store tail (11.13.1 step 6) versus the discarded statement form: whichever shape the
// compiler emits, an assignment used as a value must yield the ASSIGNED value, never a setter's return.
> var log = [], o = {};
> Object.defineProperty(o, "s", { set: function (v) { log.push(v); return 999; } });
> var r = (o.s = 7); print(r + " " + log.join(","))
< 7 7
> o.s = 8; print(log.join(","))
< 7,8
-
// eval completion value of an assignment expression statement (10.4.2): the value form must survive there.
> print(eval("o.s = 9") + " " + log.join(","))
< 9 7,8,9
-
// Postfix on a property keeps the OLD value as its result, stored value landing regardless.
> var p = { n: 5 }; var old = p.n++; print(old + " " + p.n)
< 5 6
> p.n++; print(p.n)
< 7
-
// Comma discards its left side; the completion is the right.
> var q = {}; print((q.a = 1, q.a + 1) + " " + q.a)
< 2 1
-
// Ternary arms that assign, whole expression discarded: both stores land.
> var t = {}; true ? (t.x = 1) : (t.x = 2); false ? (t.y = 3) : (t.y = 4); print(t.x + " " + t.y)
< 1 4
-
// for-statement increment position: a discarded store per iteration.
> var c = {}, i; for (i = 0; i < 3; c.k = i, ++i) {} print(c.k + " " + i)
< 2 3
-
// A discarded strict store still throws where 11.13.1 asks: read-only property and non-extensible target.
> (function () { "use strict"; var f = {}; Object.defineProperty(f, "ro", { value: 1 }); try { f.ro = 2; print("no throw"); } catch (e) { print(e.name); } })()
< TypeError
> (function () { "use strict"; var f = Object.preventExtensions({}); try { f.nu = 1; print("no throw"); } catch (e) { print(e.name); } })()
< TypeError
-
// A named write through a with-object accessor, discarded: the setter still runs, its return still ignored.
> var w = {}, got = []; Object.defineProperty(w, "wv", { set: function (v) { got.push(v); return 111; } });
> with (w) { wv = 42; }
> print(got.join(","))
< 42
> with (w) { print(wv = 43); }
< 43
