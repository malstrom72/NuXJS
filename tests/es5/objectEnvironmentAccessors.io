// 10.2.1.2: a `with` object and the global object are *object* environment records, so a binding can be an
// accessor and a bare identifier has to run the getter (8.12.3) or the setter (8.12.5), exactly as `o.x` does.
// The identifier path used to read and write the raw property slot, so a getter never ran, a read answered
// undefined and a write was silently discarded. Verified against V8.
> function show(l, v) { print(l + ": " + v) }
-
// Reading through a with-scope runs the getter, and a data property is unaffected.
> var o1 = { get x() { return "G" }, y: "data" };
> (function () { var x = "outer", y = "outer"; with (o1) { show("get", x); show("data", y) } })();
< get: G
< data: data
-
// Writing through a with-scope runs the setter, and does not touch the outer binding.
> var seen = "none";
> var o2 = { get x() { return "G" }, set x(v) { seen = v } };
> (function () { var x = "outer"; with (o2) { x = "W" } show("outer", x) })();
< outer: outer
> print(seen)
< W
-
// An accessor with no setter silently drops the store outside strict mode, and keeps its getter.
> var o3 = { get x() { return "GONLY" } };
> (function () { with (o3) { x = "ignored" } })();
> print(o3.x)
< GONLY
-
// The accessor may be inherited, and a declarative binding still shadows the object.
> var o4 = Object.create({ get x() { return "PROTO" } });
> (function () { var x = "outer"; with (o4) { show("inherited", x) } })();
< inherited: PROTO
> (function () { with (o1) { var x = "local"; show("shadowed", x) } })();
< shadowed: G
-
// The same for the global object, which is where this actually bites: `with` is a SyntaxError in strict code
// but a global accessor is ordinary ES5.
> Object.defineProperty(this, "g1", { get: function () { return "GG" }, set: function (v) { seen = "g:" + v }, configurable: true });
> show("global read", g1);
< global read: GG
> g1 = "GW";
> print(seen)
< g:GW
-
// 11.4.3 takes GetValue unless the reference is unresolvable, so typeof runs the getter too.
> print(typeof g1)
< string
> print(typeof neverDeclaredZZ)
< undefined
-
// A getter that throws propagates rather than being swallowed.
> Object.defineProperty(this, "g2", { get: function () { throw new Error("boom") }, configurable: true });
> try { print(g2) } catch (e) { print(e.message) }
< boom
-
// A compound assignment runs the getter and then the setter, which is the read-modify-write path.
> Object.defineProperty(this, "g3", { get: function () { return 10 }, set: function (v) { seen = "g3:" + v }, configurable: true });
> g3 += 5;
> print(seen)
< g3:15
-
// The value of an assignment expression is the assigned value, not whatever the setter returned.
> Object.defineProperty(this, "g4", { set: function (v) { seen = v }, get: function () { return "ignored" }, configurable: true });
> print(g4 = "assigned")
< assigned
-
