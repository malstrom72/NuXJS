// ES5.1 15.4.4.21-22: reduce and reduceRight. Unlike the iteration methods these take four callback arguments
// (accumulator, value, index, object) and no thisArg, so the callback is called as a function. Verified against V8.
> print([1,2,3].reduce(function (a, b) { return a + b; }))
< 6
> print([1,2,3].reduce(function (a, b) { return a + b; }, 10))
< 16
> print(["a","b","c"].reduceRight(function (a, b) { return a + b; }))
< cba
> print([1,2,3].reduceRight(function (a, b) { return a + "-" + b; }, "S"))
< S-3-2-1
-
// The callback receives four arguments, and its this is undefined (the global object for a non-strict callback).
> print([9].reduce(function (a, b, i, o) { return [a, b, i, o.length].join("/"); }, "S"))
< S/9/0/1
> var r; [1,2].reduce(function () { r = (this === undefined ? "undefined" : typeof this); return 0; }, 0); print(r)
< object
-
// With no initialValue the first present element seeds the accumulator, so the callback runs one time fewer.
> var n = 0; [1,2,3].reduce(function (a, b) { ++n; return a + b; }); print(n)
< 2
> var n = 0; [1,2,3].reduce(function (a, b) { ++n; return a + b; }, 0); print(n)
< 3
-
// "Present" means the index exists, so holes neither seed nor get visited.
> print([0,,2].reduce(function (a, b) { return a + "|" + b; }))
< 0|2
> print([,,3].reduce(function (a, b) { return a + "|" + b; }))
< 3
> print([1,,3].reduceRight(function (a, b) { return a + "|" + b; }))
< 3|1
-
// It is a TypeError when there is no initialValue and no present element, whether the array is empty or all holes.
> try { [].reduce(function () {}); } catch (e) { print(e.name) }
< TypeError
> try { [,,].reduce(function () {}); } catch (e) { print(e.name) }
< TypeError
> try { [].reduceRight(function () {}); } catch (e) { print(e.name) }
< TypeError
> print([].reduce(function () {}, 7) + " " + [].reduceRight(function () {}, 8))
< 7 8
-
// "initialValue is present" means it was supplied, not that it is defined, so an explicit undefined still seeds.
> var r = [1].reduce(function (a, b) { return String(a) + "," + b; }, undefined); print(r)
< undefined,1
-
// Steps 1 and 4: ToObject on the this value, then IsCallable, both before any iteration.
> try { [].reduce.call(null, function () {}); } catch (e) { print(e.name) }
< TypeError
> try { [1,2].reduce(42); } catch (e) { print(e.name) }
< TypeError
> try { [1,2].reduceRight(); } catch (e) { print(e.name) }
< TypeError
-
// Generic over array-likes, and length is read once up front.
> print([].reduce.call({0:1, 1:2, 2:3, length:3}, function (a, b) { return a + b; }))
< 6
> var a = [1,2]; var r = a.reduce(function (x, y) { a.push(9); return x + y; }); print(r + " len=" + a.length)
< 3 len=3
-
// Both have length 1 and the standard built-in attributes.
> print([].reduce.length + " " + [].reduceRight.length)
< 1 1
> var d = Object.getOwnPropertyDescriptor(Array.prototype, "reduce"); print(d.writable + " " + d.enumerable + " " + d.configurable)
< true false true
-
