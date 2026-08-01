// ES5.1 15.3.5 Properties of Function Instances, and 15.3.4.2 Function.prototype.toString.
// 15.3.5.1: length is { [[Writable]]: false, [[Enumerable]]: false, [[Configurable]]: false }. ES2015 later made it
// configurable, so V8 disagrees on the last flag; ES5.1 arbitrates. See docs/specs/ES5.1 vs modern divergences.md.
> function g(a, b) { } var d = Object.getOwnPropertyDescriptor(g, "length"); print(d.value + " " + d.writable + " " + d.enumerable + " " + d.configurable)
< 2 false false false
> function g(a, b) { } g.length = 99; print(g.length)
< 2
> function g(a, b) { } print(delete g.length)
< false
-
// 15.3.5.2: prototype is { [[Writable]]: true, [[Enumerable]]: false, [[Configurable]]: false }. The DontEnum is
// the ES5 change; ES3 15.3.5.2 gave it only { DontDelete }. Twin: tests/es3only/enumerableOfFunctions.io.
> function g() { } var d = Object.getOwnPropertyDescriptor(g, "prototype"); print(d.writable + " " + d.enumerable + " " + d.configurable)
< true false false
> function g() { } var p = {}; g.prototype = p; print(g.prototype === p)
< true
> function g() { } print(delete g.prototype)
< false
> function g() { } var ks = []; for (var k in g) ks.push(k); print("[" + ks.join(",") + "]")
< []
> function g() { } print(Object.getOwnPropertyNames(g).sort().join(","))
< length,name,prototype
-
// `name` is NOT an ES5.1 property: 15.3.5 defines only length and prototype. NuXJS carries it as an extension and
// deliberately leaves it writable, which stdlib.js relies on when it names the error constructors.
> function g() { } var d = Object.getOwnPropertyDescriptor(g, "name"); print(d.value + " " + d.writable + " " + d.enumerable + " " + d.configurable)
< g true false true
> print(TypeError.name + " " + RangeError.name + " " + SyntaxError.name)
< TypeError RangeError SyntaxError
-
// 15.3.4.2: toString returns a representation with the syntax of a FunctionDeclaration. The exact whitespace is
// implementation-dependent, so this only checks that the source text survives.
> function add(x) { return x + 1; } print(add.toString().replace(/\s+/g, " "))
< function add(x) { return x + 1; }
> var f = function (y) { return y * 2; }; print(f.toString().replace(/\s+/g, " "))
< function (y) { return y * 2; }
-
// 15.3.4.2: toString is not generic, so a non-Function this is a TypeError.
> try { Function.prototype.toString.call({}); print("no throw") } catch (e) { print(e.name) }
< TypeError
> try { Function.prototype.toString.call(5); print("no throw") } catch (e) { print(e.name) }
< TypeError
> try { Function.prototype.toString.call(null); print("no throw") } catch (e) { print(e.name) }
< TypeError
> try { Function.prototype.toString.call([]); print("no throw") } catch (e) { print(e.name) }
< TypeError
-
// A bound function has no prototype at all (15.3.5.2 NOTE), so the descriptor is undefined rather than a hole.
> function g() { } print(Object.getOwnPropertyDescriptor(g.bind(null), "prototype"))
< undefined
-
