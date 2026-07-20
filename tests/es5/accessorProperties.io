// ES5.1 11.1.5 (get/set object literals), 8.12.3 ([[Get]]), 8.12.5 ([[Put]]): accessor properties.
> var log = []; var o = { get x() { log.push("get"); return 42; }, set x(v) { log.push("set " + v); } };
> print(o.x)
< 42
> o.x = 7
> print(log.join(","))
< get,set 7
-
// 11.13.1: the value of an assignment is the assigned value, not the setter's return value.
> var o = { set x(v) { return "ignored"; } };
> print(o.x = 99)
< 99
-
// Getter and setter share the property; this binds to the receiver.
> var p = { get both() { return this.a; }, set both(v) { this.a = v; } };
> p.both = 5; print(p.both)
< 5
-
// 8.12.3 / 8.12.5: accessors are found on the prototype chain; the setter writes via this (the receiver).
> function F() {} F.prototype = { get v() { return "inherited:" + this.tag; }, set v(x) { this.stored = x; } };
> var i = new F(); i.tag = "me"; print(i.v)
< inherited:me
> i.v = 12; print(i.stored); print(i.hasOwnProperty("v"))
< 12
< false
-
// Compound assignment and post-increment go through both the getter and the setter.
> var c = { n: 10, get twice() { return this.n * 2; }, set twice(v) { this.n = v / 2; } };
> c.twice += 4; print(c.n)
< 12
> var pc = { _v: 5, get p() { return this._v; }, set p(v) { this._v = v; } };
> print(pc.p++); print(pc._v)
< 5
< 6
-
// 11.2.3: a method fetched through a getter is called with the base object as this.
> var m = { get f() { return function() { return "called:" + (this === m); }; } };
> print(m.f())
< called:true
-
// Accessor properties are configurable and enumerable when created by object literals.
> var d = { get g() { return 1; } };
> print(delete d.g); print(d.g)
< true
< undefined
> var e = { get a() { return 1; }, b: 2 };
> var ks = []; for (var k in e) ks.push(k); print(ks.sort().join(","))
< a,b
-
// 8.12.5: writing without a setter and reading without a getter are silent no-op / undefined outside strict mode.
> var go = { get only() { return 3; } };
> go.only = 99; print(go.only)
< 3
> var so = { set only(v) { } };
> print(so.only)
< undefined
-
// get / set remain valid ordinary property names and accessor names.
> print(({ get: 1, set: 2 }).get + ({ get: 1, set: 2 }).set)
< 3
> print(({ get get() { return "gg"; } }).get)
< gg
-
// 11.1.5: PropertyName in accessors may be a string or a number literal.
> var sn = { get "str"() { return 1; }, get 42() { return 2; } };
> print(sn["str"] + sn[42])
< 3
-
// 11.1.5: getters take no parameters, setters exactly one.
> try { eval("({ get x(a) {} })"); } catch (x) { print(x) }
< SyntaxError: Getters must have no parameters
> try { eval("({ set x() {} })"); } catch (x) { print(x) }
< SyntaxError: Setters must have exactly one parameter
-
// 11.1.5: duplicate same-kind accessors and data / accessor collisions are syntax errors;
// duplicate data properties stay legal outside strict mode.
> try { eval("({ get x() {}, get x() {} })"); } catch (x) { print(x) }
< SyntaxError: Illegal duplicate property in object literal
> try { eval("({ x: 1, get x() {} })"); } catch (x) { print(x) }
< SyntaxError: Illegal duplicate property in object literal
> try { eval("({ get x() {}, x: 1 })"); } catch (x) { print(x) }
< SyntaxError: Illegal duplicate property in object literal
> print(({ x: 1, x: 2 }).x)
< 2
> var gs = { get x() { return "g"; }, set x(v) { } }; print(gs.x)
< g
-
