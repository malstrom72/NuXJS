// ES5.1 15.3.4.5 Function.prototype.bind. The returned function forwards calls to the target with the bound this
// and the bound arguments prepended, constructs the target ignoring the bound this (15.3.4.5.2), and defers
// instanceof to the target (15.3.4.5.3). Verified against V8, except for the two places ES2015 changed the rules;
// those are in docs/specs/ES5.1 vs modern divergences.md and ES5.1 arbitrates.
// Partial application, and the bound this winning over any later receiver.
> function g(a, b) { return this.tag + "|" + a + "|" + b; } print(g.bind({tag:"T"})(1, 2))
< T|1|2
> function g(a, b) { return this.tag + "|" + a + "|" + b; } print(g.bind({tag:"T"}, 1)(2))
< T|1|2
> function g(a, b) { return this.tag + "|" + a + "|" + b; } print(g.bind({tag:"T"}, 1, 2)())
< T|1|2
> function g(a, b) { return this.tag + "|" + a + "|" + b; } print(g.bind({tag:"T"}, 1)(2, 3))
< T|1|2
-
// 15.3.4.5.1: call and apply cannot override the bound this, and re-binding cannot either.
> function g(a) { return this.t + "/" + a; } var b = g.bind({t:"B"}, 1); print(b.call({t:"X"}, 9) + " " + b.apply({t:"Y"}, [9]))
< B/1 B/1
> function g(a, c) { return this.t + "/" + a + "/" + c; } print(g.bind({t:"A"}, 1).bind({t:"B"}, 2)())
< A/1/2
-
// Steps 15-17: length is what is left of the target's arity, floored at 0, and read-only / non-enumerable /
// non-configurable per 15.3.5.1. bind itself has length 1.
> function g(a, b) { } print(g.bind(null).length + " " + g.bind(null, 1).length + " " + g.bind(null, 1, 2, 3).length)
< 2 1 0
> function g(a, b, c) { } print(g.bind(null, 1).bind(null, 1).length)
< 1
> print(Function.prototype.bind.length)
< 1
> function g(a, b) { } var d = Object.getOwnPropertyDescriptor(g.bind(null), "length"); print(d.writable + " " + d.enumerable + " " + d.configurable)
< false false false
-
// 15.3.5.2 NOTE: a bound function has no prototype property at all.
> function g() { } var b = g.bind(null); print(("prototype" in b) + " " + b.prototype)
< false undefined
-
// Steps 20-21: caller and arguments are [[ThrowTypeError]] pills regardless of whether the target is strict.
> function g() { } try { g.bind(null).caller; print("no throw") } catch (e) { print(e.name) }
< TypeError
> function g() { } try { g.bind(null).arguments; print("no throw") } catch (e) { print(e.name) }
< TypeError
> function g() { } try { g.bind(null).caller = 1; print("no throw") } catch (e) { print(e.name) }
< TypeError
-
// 15.3.4.5.2: new on a bound function constructs the target, so the bound this is ignored and the new object gets
// the target's prototype rather than the bound function's (which does not have one).
> function P(x, y) { this.x = x; this.y = y; } P.prototype.sum = function () { return this.x + this.y; }; var B = P.bind(null); var p = new B(3, 4); print(p.x + "," + p.y + " " + p.sum())
< 3,4 7
> function P(x, y) { this.x = x; this.y = y; } var B = P.bind(null, 3); var p = new B(4); print(p.x + "," + p.y)
< 3,4
> function P(x, y) { this.x = x; this.y = y; } var B = P.bind({tag:"IGNORED"}, 1); var p = new B(2); print(p.x + "," + p.y)
< 1,2
> function P() { } var B = P.bind(null); print((new B()) instanceof P)
< true
> function P() { } var B = P.bind(null); print((new B()).constructor === P)
< true
-
// The target's prototype is read at construction time, not captured when bind ran.
> function P() { } var B = P.bind(null); P.prototype = { moved: true }; print(!!(new B()).moved)
< true
-
// 15.3.4.5.3: instanceof against a bound function asks the target, so an object made by the target matches.
> function P() { } var B = P.bind(null); print((new P()) instanceof B)
< true
> function P() { } print(P.bind(null) instanceof Function)
< true
-
// Step 2: bind on a non-callable this is a TypeError, and constructing a bound non-constructor is one too.
> try { Function.prototype.bind.call({}, null); print("no throw") } catch (e) { print(e.name) }
< TypeError
> try { Function.prototype.bind.call(null); print("no throw") } catch (e) { print(e.name) }
< TypeError
> try { new (Math.max.bind(null))(1); print("no throw") } catch (e) { print(e.name) }
< TypeError
-
// A bound function is an ordinary extensible Function object otherwise, and its own properties are all hidden.
> function g() { } var b = g.bind(null); print(typeof b)
< function
> function g() { } var b = g.bind(null); b.extra = 1; print(b.extra + " " + Object.isExtensible(b))
< 1 true
> function g() { } var b = g.bind(null); var ks = []; for (var k in b) ks.push(k); print("[" + ks.join(",") + "]")
< []
> function g() { } print(Object.prototype.toString.call(g.bind(null)))
< [object Function]
-
// 15.3.4.5 steps 20-21 mean caller and arguments really are own properties here, which ES2015 later removed.
> function g(a) { } print(Object.getOwnPropertyNames(g.bind(null)).sort().join(","))
< arguments,caller,length,name
-
// Built-ins bind too, and a bound constructor that returns an object still returns it.
> print(Math.max.bind(null, 1, 5)(3))
< 5
> print([].slice.bind([1,2,3], 1)().join(","))
< 2,3
> function C() { return { tag: "R" }; } print((new (C.bind(null))()).tag)
< R
-
