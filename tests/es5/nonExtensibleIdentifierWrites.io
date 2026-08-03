// 8.12.4 [[CanPut]] refuses a *new* own property on a non-extensible object, and 8.12.5 then drops the store
// outside strict mode and throws inside it. 10.2.1.2 makes a `with` object and the global object object
// environment records, so a bare identifier writing to one has to obey exactly what `o.x = v` obeys. The
// identifier paths used to store with setOwnProperty, which never consults the flag, or to discard the result of
// setProperty, which reports it. Verified against V8.
> function show(l, v) { print(l + ": " + v) }
-
// A with object that inherits the name: the store would have to create an own property, so it is refused.
> var proto1 = { p: 1 };
> var o1 = Object.create(proto1);
> Object.preventExtensions(o1);
> (function () { with (o1) { p = "W" } })();
> show("inherited", o1.hasOwnProperty("p") + "/" + o1.p);
< inherited: false/1
-
// The same through a for-in target, which is the other opcode and used to disagree with the assignment above.
> var o2 = Object.create({ q: 1 });
> Object.preventExtensions(o2);
> (function () { with (o2) { for (q in { z: 1 }) {} } })();
> show("for-in", o2.hasOwnProperty("q") + "/" + o2.q);
< for-in: false/1
-
// An *own* writable property is still updated: preventExtensions does not seal what is already there.
> var o3 = { r: 1 };
> Object.preventExtensions(o3);
> (function () { with (o3) { r = 2 } })();
> show("own update", o3.r);
< own update: 2
-
// Freeze makes the own property read-only too, so now even the update is dropped.
> var o4 = Object.freeze({ s: 1 });
> (function () { with (o4) { s = 2 } })();
> show("frozen", o4.s);
< frozen: 1
-
// A strict function nested in a with block still reaches the with object, and strict turns the drop into a throw.
> var o5 = Object.freeze({ t: 1 });
> var f5;
> (function () { with (o5) { f5 = function () { "use strict"; t = 2 } } })();
> try { f5(); print("no error") } catch (e) { print(e.name) }
< TypeError
-
// The global object is an object environment record too, and this is where it actually bites: `with` is a
// SyntaxError in strict code but a non-extensible global is ordinary ES5.
> Object.defineProperty(Object.prototype, "gInherit", { value: 1, writable: true, configurable: true });
> Object.preventExtensions(this);
> try { eval('"use strict"; gInherit = 5;'); print("no error, gInherit=" + gInherit) } catch (e) { print(e.name) }
< TypeError
-
// The same store outside strict mode is silently dropped rather than thrown, and the inherited value stands.
> (function () { gInherit = 7 })();
> show("sloppy", this.hasOwnProperty("gInherit") + "/" + gInherit);
< sloppy: false/1
-
// Compound assignment and ++ take the same write path, so they must agree.
> try { eval('"use strict"; gInherit += 1;'); print("no error") } catch (e) { print(e.name) }
< TypeError
> try { eval('"use strict"; gInherit++;'); print("no error") } catch (e) { print(e.name) }
< TypeError
-
// The property form of the very same store, which is the behaviour all of the above is being held to.
> var o6 = Object.create({ u: 1 });
> Object.preventExtensions(o6);
> try { eval('"use strict"; o6.u = 2;'); print("no error") } catch (e) { print(e.name) }
< TypeError
> show("property drop", o6.hasOwnProperty("u") + "/" + o6.u);
< property drop: false/1
-
