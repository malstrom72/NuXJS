// ES5.1 10.6, the [[GetOwnProperty]] / [[DefineOwnProperty]] / [[Delete]] an arguments object overrides, and the
// parameter map that sits behind them. Verified against V8 except for the two lines marked below. The general
// enumerability change is covered by the Arguments2.io / Arguments3.io twins; this file is about the algorithm.
// 10.6 (11)(b): every index is a writable, enumerable, configurable data property, mapped or not.
> (function (a, b) { var d = Object.getOwnPropertyDescriptor(arguments, "0"); print([d.value, d.writable, d.enumerable, d.configurable].join(" ")) })(1, 2)
< 1 true true true
// Index 1 here is past the formal parameter list, so 10.6 (11)(c) never mapped it, but the attributes are the same.
> (function (a) { var d = Object.getOwnPropertyDescriptor(arguments, "1"); print([d.value, d.writable, d.enumerable, d.configurable].join(" ")) })(1, 2)
< 2 true true true
// 10.6 (7) and (13): length and callee are writable and configurable, but not enumerable.
> (function (a) { var d = Object.getOwnPropertyDescriptor(arguments, "length"), c = Object.getOwnPropertyDescriptor(arguments, "callee"); print([d.value, d.writable, d.enumerable, d.configurable].join(" ") + " / " + [typeof c.value, c.writable, c.enumerable, c.configurable].join(" ")) })(1)
< 1 true false true / function true false true
> (function (a, b) { print(Object.getOwnPropertyNames(arguments).sort().join(",") + " | " + Object.keys(arguments).join(",") + " | " + JSON.stringify(arguments)) })(1, 2)
< 0,1,callee,length | 0,1 | {"0":1,"1":2}
-
// 10.6 step 5 (b)(i): a value in the descriptor is put on the map, so it reaches the formal parameter, and since
// nothing else in the descriptor restricts the property the mapping survives to carry a later write back.
> (function (a) { Object.defineProperty(arguments, "0", { value: 42 }); print(a); a = 5; print(arguments[0]) })(1)
< 42
< 5
> (function (a) { Object.defineProperty(arguments, "0", { value: 42, writable: true, enumerable: true, configurable: true }); a = 5; print(arguments[0]) })(1)
< 5
> (function (a) { Object.defineProperty(arguments, "0", {}); a = 5; print(arguments[0]) })(1)
< 5
-
// Step 5 (b)(ii): a cleared [[Writable]] deletes the map entry, but only after (b)(i) has put the value through.
> (function (a) { Object.defineProperty(arguments, "0", { writable: false }); a = 5; print(a + " " + arguments[0]) })(1)
< 5 1
> (function (a) { Object.defineProperty(arguments, "0", { value: 3, writable: false }); print(a + " " + arguments[0]); a = 5; print(a + " " + arguments[0]) })(1)
< 3 3
< 5 3
> (function (a) { Object.defineProperty(arguments, "0", { writable: false }); arguments[0] = 9; print(arguments[0]) })(1)
< 1
-
// Step 5 (a): an accessor deletes the map entry too, and the getter answers from then on.
> (function (a) { Object.defineProperty(arguments, "0", { get: function () { return 7 } }); a = 5; print(a + " " + arguments[0]) })(1)
< 5 7
> (function (a) { Object.defineProperty(arguments, "0", { get: function () { return 7 } }); var d = Object.getOwnPropertyDescriptor(arguments, "0"); print([typeof d.get, typeof d.set, d.enumerable, d.configurable].join(" ")) })(1)
< function undefined true true
-
// Attributes alone change nothing in the map, so the parameter stays linked while the index leaves for-in.
> (function (a, b) { Object.defineProperty(arguments, "0", { enumerable: false }); a = 5; print(arguments[0]); var k = []; for (var i in arguments) k.push(i); print(k.join(",") + " | " + Object.keys(arguments).join(",")) })(1, 2)
< 5
< 1 | 1
// DIFFERENCE: V8 drops such an index from getOwnPropertyNames while hasOwnProperty and getOwnPropertyDescriptor
// still report it, which is a V8 bug rather than a spec divergence; 15.2.3.4 asks for every own property.
> (function (a, b) { Object.defineProperty(arguments, "0", { enumerable: false }); print(Object.getOwnPropertyNames(arguments).sort().join(",") + " " + arguments.hasOwnProperty("0") + " " + arguments.propertyIsEnumerable("0")) })(1, 2)
< 0,1,callee,length true false
// Turning it back on again is allowed while the index is still configurable.
> (function (a) { Object.defineProperty(arguments, "0", { enumerable: false }); Object.defineProperty(arguments, "0", { enumerable: true }); a = 4; var k = []; for (var i in arguments) k.push(i); print(k.join(",") + " " + arguments[0]) })(1)
< 0 4
-
// A cleared [[Configurable]] also leaves the map alone, but 8.12.7 then refuses the delete and 8.12.9 (7) and (9)
// refuse to widen it or to turn it into an accessor. A value change is still fine, since it stays writable.
> (function (a) { Object.defineProperty(arguments, "0", { configurable: false }); print(delete arguments[0]); arguments[0] = 8; print(arguments[0] + " " + a) })(1)
< false
< 8 8
> (function (a) { Object.defineProperty(arguments, "0", { enumerable: false, configurable: false }); try { Object.defineProperty(arguments, "0", { enumerable: true }); print("no throw") } catch (e) { print(e.name) } })(1)
< TypeError
> (function (a) { Object.defineProperty(arguments, "0", { configurable: false }); try { Object.defineProperty(arguments, "0", { configurable: true }); print("no throw") } catch (e) { print(e.name) } })(1)
< TypeError
> (function (a) { Object.defineProperty(arguments, "0", { configurable: false }); try { Object.defineProperty(arguments, "0", { get: function () { return 0 } }); print("no throw") } catch (e) { print(e.name) } a = 3; print(arguments[0]) })(1)
< TypeError
< 3
> (function (a) { Object.defineProperty(arguments, "0", { configurable: false }); Object.defineProperty(arguments, "0", { value: 6 }); print(arguments[0] + " " + a) })(1)
< 6 6
-
// seal and freeze reach the indices now that getOwnPropertyNames lists them. seal only clears configurable, so the
// mapping lives on; freeze clears writable as well, which is what severs it.
> (function (a, b) { Object.seal(arguments); a = 7; print(Object.isSealed(arguments) + " " + Object.isFrozen(arguments) + " " + arguments[0] + " " + (delete arguments[0])) })(1, 2)
< true false 7 false
> (function (a, b) { Object.freeze(arguments); arguments[0] = 9; a = 7; print(Object.isFrozen(arguments) + " " + arguments[0] + " " + a) })(1, 2)
< true 1 7
> (function (a) { Object.preventExtensions(arguments); try { Object.defineProperty(arguments, "5", { value: 1 }); print("no throw") } catch (e) { print(e.name) } print(Object.isExtensible(arguments) + " " + (5 in arguments)) })(1)
< TypeError
< false false
-
// A deleted index is gone from every view of the object, and stays gone.
> (function (a, b) { delete arguments[0]; print(Object.getOwnPropertyNames(arguments).sort().join(",") + " " + (0 in arguments) + " " + (delete arguments[0])) })(1, 2)
< 1,callee,length false true
> (function (a) { delete arguments[0]; Object.defineProperty(arguments, "0", { value: 4 }); print(a + " " + arguments[0]) })(1)
< 1 4
-
// A strict arguments object has no map at all (10.6 (12)), so a define only ever touches its own copy, but the
// indices carry the same attributes.
> (function (a) { "use strict"; Object.defineProperty(arguments, "0", { value: 3 }); a = 9; print(arguments[0] + " " + a) })(1)
< 3 9
> (function (a, b) { "use strict"; var d = Object.getOwnPropertyDescriptor(arguments, "0"); print([d.value, d.writable, d.enumerable, d.configurable].join(" ") + " | " + Object.keys(arguments).join(",")) })(1, 2)
< 1 true true true | 0,1
// DIFFERENCE: ES5.1 10.6 (14) gives a strict arguments object both a caller and a callee poison pill; ES2017
// dropped caller, so V8 lists only callee. See docs/specs/ES5.1 vs modern divergences.md.
> (function (a) { "use strict"; print(Object.getOwnPropertyNames(arguments).sort().join(",")) })(1)
< 0,callee,caller,length
-
// An arguments object that outlives its frame keeps whatever was defined on it.
> var e = (function (a, b) { Object.defineProperty(arguments, "0", { enumerable: false }); Object.defineProperty(arguments, "1", { writable: false }); return arguments })(1, 2); print(e[0] + "," + e[1] + " " + Object.getOwnPropertyNames(e).sort().join(",")); e[1] = 9; print(e[1] + " " + e.propertyIsEnumerable("0"))
< 1,2 0,1,callee,length
< 2 false
-
