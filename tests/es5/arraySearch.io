// ES5.1 15.4.4.14-15: indexOf and lastIndexOf. They compare with the Strict Equality Comparison Algorithm (11.9.6),
// take no callback and no thisArg, and skip holes. Verified against V8.
> var q = [1,2,3,2,1]; print(q.indexOf(2) + " " + q.lastIndexOf(2) + " " + q.indexOf(9))
< 1 3 -1
> print([].indexOf(1) + " " + [].lastIndexOf(1))
< -1 -1
-
// Strict equality means no coercion, NaN is never found (NaN !== NaN), and -0 matches +0.
> print([1,2].indexOf("2") + " " + [NaN].indexOf(NaN) + " " + [NaN].lastIndexOf(NaN))
< -1 -1 -1
> print([0].indexOf(-0) + " " + [-0].indexOf(0))
< 0 0
> print([null].indexOf(undefined) + " " + [undefined].indexOf(null))
< -1 -1
-
// Holes are not visited, so searching for undefined does not find them.
> print([,,1].indexOf(undefined) + " " + [1,,].lastIndexOf(undefined))
< -1 -1
> print([,,1].indexOf(1) + " " + [1,,1].lastIndexOf(1))
< 2 2
-
// indexOf's fromIndex: a negative value is an offset from the end clamped to 0, and n >= len returns -1 at once.
> var q = [1,2,3,2,1]; print(q.indexOf(2, 2) + " " + q.indexOf(2, -2) + " " + q.indexOf(2, -99) + " " + q.indexOf(2, 99))
< 3 3 1 -1
> var q = [1,2,3,2,1]; print(q.indexOf(2, Infinity) + " " + q.indexOf(2, -Infinity) + " " + q.indexOf(2, NaN))
< -1 1 1
-
// lastIndexOf's fromIndex is not the mirror image: it defaults to len-1, a positive value clamps to len-1, and a
// negative one that lands below 0 ends the search immediately rather than scanning the whole array.
> var q = [1,2,3,2,1]; print(q.lastIndexOf(2, 2) + " " + q.lastIndexOf(2, -2) + " " + q.lastIndexOf(2, -99) + " " + q.lastIndexOf(2, 99))
< 1 3 -1 3
> var q = [1,2,3,2,1]; print(q.lastIndexOf(1, Infinity) + " " + q.lastIndexOf(1, -Infinity))
< 4 -1
-
// Step 4 returns -1 for an empty array before fromIndex is even read, so a throwing valueOf is never reached.
> print([].indexOf(1, {valueOf: function () { throw new Error("boom"); }}))
< -1
-
// Generic over array-likes and strings, with length taken through ToUint32.
> print([].indexOf.call({0:"a", 1:"b", length:2}, "b"))
< 1
> print([].indexOf.call("abc", "b") + " " + [].lastIndexOf.call("abca", "a"))
< 1 3
-
// Step 1 is ToObject on the this value, so null and undefined throw.
> try { [].indexOf.call(null, 1); } catch (e) { print(e.name) }
< TypeError
> try { [].lastIndexOf.call(undefined, 1); } catch (e) { print(e.name) }
< TypeError
-
// Both have length 1 and the standard built-in attributes.
> print([].indexOf.length + " " + [].lastIndexOf.length)
< 1 1
> var d = Object.getOwnPropertyDescriptor(Array.prototype, "indexOf"); print(d.writable + " " + d.enumerable + " " + d.configurable)
< true false true
-
