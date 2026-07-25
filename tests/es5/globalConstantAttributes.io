// ES5.1 15.1.1.1-3: the global NaN, Infinity and undefined have the attributes
// { [[Writable]]: false, [[Enumerable]]: false, [[Configurable]]: false }. ES3 15.1.1 left them writable, so this is
// an ES5 change (the tests/es3only twin asserts the ES3 attributes).
> function descOf(name) {
> 	var d = Object.getOwnPropertyDescriptor(this, name);
> 	return "writable:" + d.writable + " enumerable:" + d.enumerable + " configurable:" + d.configurable;
> }
-
> print(descOf("NaN"))
< writable:false enumerable:false configurable:false
> print(descOf("Infinity"))
< writable:false enumerable:false configurable:false
> print(descOf("undefined"))
< writable:false enumerable:false configurable:false
-

// The values are unchanged by making them read-only.
> print(isNaN(NaN)); print(Infinity); print(typeof undefined)
< true
< Infinity
< undefined
-

// 8.12.5: a write to a non-writable property is silently ignored in non-strict code.
> NaN = 1; Infinity = 2; undefined = 3;
> print(isNaN(NaN)); print(Infinity); print(typeof undefined)
< true
< Infinity
< undefined
-

// 8.12.5 / 11.13.1: the same write throws a TypeError in strict mode.
> print(eval("'use strict'; try { NaN = 1; 'no throw' } catch (e) { e.name }"))
< TypeError
> print(eval("'use strict'; try { Infinity = 1; 'no throw' } catch (e) { e.name }"))
< TypeError
> print(eval("'use strict'; try { undefined = 1; 'no throw' } catch (e) { e.name }"))
< TypeError
-

// They are non-configurable, so a non-strict delete just returns false. In strict code `delete` of an unqualified
// identifier is a SyntaxError (11.4.1), raised when the eval code is compiled, so the throw escapes the eval itself.
> print(delete NaN)
< false
> try { eval("'use strict'; delete NaN;"); print("no throw") } catch (e) { print(e.name) }
< SyntaxError
-
