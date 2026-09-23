// 11.2.3 step 7 asks the callee's Reference for its this value, and for an environment record that means
// ImplicitThisValue (10.2.1.2.6): an object environment record returns its binding object when withEnvironment
// is true, and undefined otherwise. So a bare-name call inside a `with` is called ON the with object, while the
// same call against the global environment gets undefined and is then coerced by 10.4.3. tests/es5/
// objectEnvironmentAccessors.io pins the READ side of the same environment record; this pins the RECEIVER the
// resulting call runs with, which is a separate path - the accessor can run correctly and the call still be
// given the wrong this. Verified against V8.
> function show(l, v) { print(l + ": " + v) }
> var G = (function () { return this })();
> function tag(x) { return x === undefined ? "undefined" : x === null ? "null" : x === G ? "global"
>		: (typeof x !== "object" && typeof x !== "function") ? "primitive:" + x : (x.id ? x.id : "?") }
-
// The callee is an accessor on the with object, so the getter runs and the function it returns is then called
// on that same object. Reading it correctly and calling it correctly are two different things.
> var o1 = { id: "o1" };
> Object.defineProperty(o1, "m", { get: function () { return function () { return tag(this) } } });
> with (o1) { show("accessor callee", m()) }
< accessor callee: o1
-
// The getter's own this and the call's this are both the binding object, and the getter runs exactly once.
> var seen = "none", calls = 0;
> var o2 = { id: "o2" };
> Object.defineProperty(o2, "g", { get: function () { ++calls; seen = tag(this); return function () { return tag(this) } } });
> with (o2) { show("call receiver", g()) }
< call receiver: o2
> show("getter receiver", seen); show("getter calls", calls)
< getter receiver: o2
< getter calls: 1
-
// Inherited through the with object's prototype chain: GetBase is the object named by the `with`, not whichever
// object along the chain carries the accessor.
> function P() {}
> Object.defineProperty(P.prototype, "pm", { get: function () { return function () { return tag(this) } } });
> var inst = new P(); inst.id = "inst";
> with (inst) { show("inherited accessor", pm()) }
< inherited accessor: inst
-
// The global environment record has withEnvironment false, so ImplicitThisValue is undefined and 10.4.3
// substitutes the global object for a non-strict callee. An accessor binding changes nothing here.
> Object.defineProperty(G, "gm", { get: function () { return function () { return tag(this) } }, configurable: true });
> show("global accessor callee", gm())
< global accessor callee: global
-
// 10.4.3 step 1: a strict callee keeps the this value it was given, uncoerced. Reached through a `with`, that
// value is the binding object, so the receiver has to survive rather than be replaced by the global object or
// dropped to undefined.
> var o3 = { id: "o3", s: function () { "use strict"; return tag(this) } };
> with (o3) { show("strict callee via with", s()) }
< strict callee via with: o3
-
// The same strict function called as a bare name with no `with` in scope gets undefined and keeps it, which is
// the ES5 half of 10.4.3 and what separates it from the ES3 behaviour.
> function sBare() { "use strict"; return tag(this) }
> show("strict bare call", sBare())
< strict bare call: undefined
-
// A name the with object does not carry falls through to the rest of the chain and brings no receiver with it,
// so a strict callee found further out is still undefined.
> with (o3) { show("strict fallthrough", sBare()) }
< strict fallthrough: undefined
-
// A non-strict callee reached the same way is coerced to the global object by 10.4.3, which is the contrast that
// makes the strict case above meaningful rather than incidental.
> function nBare() { return tag(this) }
> with (o3) { show("non-strict fallthrough", nBare()) }
< non-strict fallthrough: global
-
// The receiver is the binding object itself, so for a primitive wrapper it is the wrapper, never the primitive.
> var sw = new String("hi"); sw.id = "wrapper";
> sw.w = function () { return typeof this + "/" + tag(this) };
> with (sw) { show("wrapper receiver", w()) }
< wrapper receiver: object/wrapper
-
// A getter that throws propagates out of the call expression rather than being swallowed into a bad receiver.
> var o4 = {};
> Object.defineProperty(o4, "boom", { get: function () { throw new Error("from getter") } });
> try { with (o4) { boom() } } catch (e) { show("throwing getter", e.message) }
< throwing getter: from getter
-
// eval keeps its own call path, so a `with`-bound eval is still a direct eval and not routed through the
// receiver-carrying opcode.
> with ({ id: "o5" }) { show("eval in with", eval("1 + 1")) }
< eval in with: 2
