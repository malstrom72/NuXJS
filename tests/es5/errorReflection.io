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
// An accessor is script the mirror must run: taking it for undefined used to put the literal "undefined" in the header.
> var b = new Error("x");
> Object.defineProperty(b, "name", { get: function () { return "Gotten" } });
> try { throw b } catch (c) { print(c.toString()); print(head(c)) }
< Gotten: x
< Gotten: x
> var i = new Error("i");
> Object.defineProperty(i, "message", { get: function () { return "gotmsg" } });
> try { throw i } catch (c) { print(c.toString()); print(head(c)) }
< Error: gotmsg
< Error: gotmsg
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
// A throwing getter must not make an unrelated mutation of the error fail; that field falls back to its default
// instead. NuXJS reads the accessors when the error is mutated, where V8 defers them to the stack being formatted,
// so a throw from one is observable here and not there. Only the non-standard stack differs; toString agrees.
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
