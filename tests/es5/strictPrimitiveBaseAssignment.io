// ES5.1 8.7.2 PutValue: when a reference has a primitive base the store goes through the special [[Put]] defined
// there, acting on the transient object ToObject(base) produces. Nothing is ever kept: step 4 (an own data property)
// and step 7 (creating a new own property) both throw a TypeError for a strict reference and are silent no-ops
// otherwise, and only an inherited accessor with a setter actually runs. ES3 11.2.1 step 5 resolved the base to an
// object when the reference was built, which erased the distinction, so this is guarded by NUXJS_ES5. Against V8.
// A new property on a number, boolean or string base is 8.7.2 step 7, so strict code throws.
> var s = ["(5).x = 1", "true.x = 1", "'ab'.x = 1", "(5)['x'] = 1"]; for (var i = 0; i < s.length; i++) { try { eval("'use strict';" + s[i]); print("no throw") } catch (e) { print(e.name) } }
< TypeError
< TypeError
< TypeError
< TypeError
-
// An own data property of the transient wrapper is step 4: it throws rather than writing to the throwaway.
> var s = ["'ab'.length = 9", "'ab'[0] = 'z'"]; for (var i = 0; i < s.length; i++) { try { eval("'use strict';" + s[i]); print("no throw") } catch (e) { print(e.name) } }
< TypeError
< TypeError
-
// An inherited writable data property is no different, it is still a request to create an own property (step 7).
> try { eval("'use strict'; (5).toFixed = 1"); print("no throw") } catch (e) { print(e.name) }
< TypeError
-
// Compound assignment and ++/-- read through 8.7.1 and then write through 8.7.2, so they throw too.
> var s = ["(5).x++", "--(5).x", "(5).x += 1", "'ab'.length++"]; for (var i = 0; i < s.length; i++) { try { eval("'use strict';" + s[i]); print("no throw") } catch (e) { print(e.name) } }
< TypeError
< TypeError
< TypeError
< TypeError
-
// Non-strict code silently ignores every one of them, leaving no trace on the primitive or on the string pool.
> (5).x = 1; true.x = 1; "ab".x = 1; "ab".length = 9; "ab"[0] = "z"; print((5).x + " " + "ab".x + " " + "ab".length + " " + "ab"[0])
< undefined undefined 2 a
-
// An inherited accessor with a setter is the one case that runs, and it runs in both modes (step 6).
> Object.defineProperty(Number.prototype, "sink", { set: function (v) { print("set " + v) } }); (5).sink = 1; eval("'use strict'; (5).sink = 2")
< set 1
< set 2
-
// An accessor without a setter fails [[CanPut]], so step 2 throws in strict code and stays silent otherwise.
> Object.defineProperty(Number.prototype, "ro", { get: function () { return 1 } }); (5).ro = 1; print("sloppy ok"); try { eval("'use strict'; (5).ro = 1"); print("no throw") } catch (e) { print(e.name) }
< sloppy ok
< TypeError
-
// A wrapper object is not a primitive base, so it stores normally even in strict code.
> print(eval("'use strict'; var n = new Number(5); n.x = 1; n.x"))
< 1
-
// `delete` is not a PutValue, so it still resolves the base to an object and reports success.
> print(eval("'use strict'; delete (5).x"))
< true
-
// 11.2.1 checks the base for null/undefined when the reference is built, after the key but before the right hand side.
> try { null.x = print("rhs ran") } catch (e) { print(e.name) }
< TypeError
> try { null[print("key ran")] = print("rhs ran") } catch (e) { print(e.name) }
< key ran
< TypeError
-
// 8.7.2 step 6 hands the setter the base itself, not the transient box the lookup went through, so a strict
// setter sees the primitive and a non-strict one its wrapper. Checked against V8.
> Object.defineProperty(Number.prototype, "ss", { set: function (v) { "use strict"; print(typeof this + "/" + (this === 5)) } });
> Object.defineProperty(Number.prototype, "sl", { set: function (v) { print(typeof this + "/" + (this === 5)) } });
> (5).ss = 1; (5).sl = 1;
< number/true
< object/false
-
