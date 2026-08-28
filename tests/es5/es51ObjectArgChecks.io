// 15.2.3.7 (1): defineProperties runs ToObject on its property bag, so null and undefined are TypeErrors;
// Object.create (15.2.3.5 (4)) forwards a present-and-not-undefined bag to the same check.
> try { Object.defineProperties({}, null); } catch (e) { print(e.name) }
< TypeError
> try { Object.defineProperties({}, undefined); } catch (e) { print(e.name) }
< TypeError
> try { Object.create({}, null); } catch (e) { print(e.name) }
< TypeError
> print(Object.create({}, undefined) !== null)
< true
-
// A primitive bag is ToObject-wrapped, not rejected: a number has no own enumerable names, so nothing lands.
> print(Object.keys(Object.defineProperties({}, 42)).length)
< 0
-
// 15.11.4.4 (8-10): empty name returns the message alone; empty message the name alone; both empty, "".
> var e = new Error("ErrorMessage"); e.name = ""; print("[" + e + "]")
< [ErrorMessage]
> var e2 = new Error(); e2.name = ""; print("[" + e2 + "]")
< []
> var e3 = new Error("m"); e3.name = "N"; print("[" + e3 + "]")
< [N: m]
> var e4 = new Error(); e4.name = "N"; e4.message = 0; print("[" + e4 + "]")
< [N: 0]
-
// 10.4.3: replace's callback is called with no receiver, so a strict callback sees undefined (not null).
> var got = "unset"; function f() { "use strict"; got = this; return "x"; }
> print("ab".replace("b", f) + " " + (got === void 0 ? "undefined" : "" + got))
< ax undefined
> got = "unset"; print("ab".replace(/b/, f) + " " + (got === void 0 ? "undefined" : "" + got))
< ax undefined
-
