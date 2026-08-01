// ES3 15.4.4.6-13 have no Throw flag, so a refused store or delete is silent and the method runs to completion on
// whatever it managed to write. ES5.1 added Throw = true throughout; the twin holding those answers is
// tests/es5/arrayMutatorThrowFlag.io. freeze / seal / preventExtensions are ES5 reflection, so the refusal here is
// set up with the data-only Object.defineProperty shim that ES3 stdlib.js already provides.
> var ops = { push: function (a) { a.push(9) }, pop: function (a) { a.pop() }, shift: function (a) { a.shift() }
>		, unshift: function (a) { a.unshift(9) }, reverse: function (a) { a.reverse() }, sort: function (a) { a.sort() }
>		, splice: function (a) { a.splice(0, 1) }, "splice+": function (a) { a.splice(0, 0, 9) } };
> var names = [ "push", "pop", "shift", "unshift", "reverse", "sort", "splice", "splice+" ];
> function readOnlyMiddle() { var a = [1, 2, 3]; Object.defineProperty(a, "1", { value: 2, writable: false }); return a }
-
> var r = []; for (var i = 0; i < names.length; ++i) { var n = names[i]; try { ops[n](readOnlyMiddle()); r.push(n + ":ok") } catch (e) { r.push(n + ":" + e.name) } } print(r.join(" "))
< push:ok pop:ok shift:ok unshift:ok reverse:ok sort:ok splice:ok splice+:ok
// shift still reports a length of 2, but the element it could not move over index 1 is simply left behind.
> var a = readOnlyMiddle(); a.shift(); print(a.join(",") + " " + a.length)
< 2,2 2
// reverse leaves index 1 alone on an odd length, so this one comes out intact.
> var a = readOnlyMiddle(); a.reverse(); print(a.join(",") + " " + a.length)
< 3,2,1 3
-
// Step 1 is ToObject(this) in ES3 too, but a non-strict built-in never sees a null receiver: 10.1.7 substitutes the
// global object, so the call quietly operates on that instead of throwing.
> print(typeof Array.prototype.pop.call(null))
< undefined
-
