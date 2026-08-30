// An Error keeps a C++ mirror of name, message and stack so that the engine can report a throw without running
// script. Every way script can change those, assignment, deletion and 8.12.9 define, has to refresh the mirror, and
// an accessor has to be read with [[Get]] rather than taken for undefined. 15.11.4.4 toString and the stack header
// then agree, as they must, since both describe the same object.
> function head(e) { return e.stack ? String(e.stack).split("\n")[0] : "(no stack)" }
-
// Object.defineProperty writes past setOwnProperty, straight into the table.
> var a = new Error("boom");
> Object.defineProperty(a, "message", { value: "redefined" });
> try { throw a } catch (c) { print(c.toString()); print(head(c)) }
< Error: redefined
< Error: redefined
-
// The same for the name, and for the stack itself.
> var g = new Error("named");
> Object.defineProperty(g, "name", { value: "MyError" });
> try { throw g } catch (c) { print(c.toString()); print(head(c)) }
< MyError: named
< MyError: named
> var h = new Error("h");
> Object.defineProperty(h, "stack", { value: "CUSTOM STACK" });
> print(h.stack)
< CUSTOM STACK
-
// An accessor would have to be run to be read, and the mirror is refreshed from the object model, which may not run
// script. The field keeps its default instead: the header says Error rather than the literal "undefined" a pure
// lookup yields for an accessor. toString is ordinary script and reports the accessor's value either way, so the two
// disagree here, deliberately, and only over the non-standard stack.
> var b = new Error("x");
> Object.defineProperty(b, "name", { get: function () { return "Gotten" } });
> try { throw b } catch (c) { print(c.toString()); print(head(c)) }
< Gotten: x
< Error: x
> var i = new Error("i");
> Object.defineProperty(i, "message", { get: function () { return "gotmsg" } });
> try { throw i } catch (c) { print(c.toString()); print(head(c)) }
< Error: gotmsg
< Error
-
// Plain assignment and deletion, the paths that always refreshed the mirror, still do.
> var d = new Error("plain");
> d.message = "assigned";
> try { throw d } catch (c) { print(c.toString()); print(head(c)) }
< Error: assigned
< Error: assigned
> var e = new Error("gone");
> delete e.message;
> try { throw e } catch (c) { print(c.toString()); print(head(c)) }
< Error
< Error
-
// A getter that throws is no different, the mirror never running one: the mutation of the error goes through and the
// header keeps the default. V8 formats the stack lazily and propagates the throw from that read instead.
> var f = new Error("thrower");
> Object.defineProperty(f, "name", { get: function () { throw new RangeError("nope") } });
> try { f.extra = 1; print("mutation ok, extra=" + f.extra) } catch (x) { print("mutation threw " + x.name) }
< mutation ok, extra=1
> try { throw f } catch (c) { print(head(c)) }
< Error: thrower
-
// A plain error is unaffected, and the mirror survives an unrelated property being added.
> var p = new Error("normal");
> p.code = 42;
> try { throw p } catch (c) { print(c.toString()); print(head(c)); print(c.code) }
< Error: normal
< Error: normal
< 42
-
