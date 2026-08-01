// ES5.1 15.4.4.16-20: every, some, forEach, map and filter. Each is generic over array-likes, calls back with
// (value, index, object) plus an optional thisArg, reads length once before the first call, and visits only
// indices that are actually present. Verified against V8.
// Basic results, and the vacuous cases: every is "for all" so an empty array is true, some is "exists" so false.
> print([1,2,3].map(function (x) { return x * 2; }).join(","))
< 2,4,6
> print([1,2,3,4].filter(function (x) { return x % 2 === 0; }).join(","))
< 2,4
> var v = []; [1,2].forEach(function (x, i, o) { v.push(i + ":" + x + "/" + o.length); }); print(v.join(" "))
< 0:1/2 1:2/2
> print([].every(function () { return false; }) + " " + [].some(function () { return true; }))
< true false
> print([,,].every(function () { return false; }) + " " + [,,].some(function () { return true; }))
< true false
-
// every and some short-circuit, and forEach always returns undefined.
> var n = 0; print([1,2,3].every(function (x) { ++n; return x < 2; }) + " " + n)
< false 2
> var n = 0; print([1,2,3].some(function (x) { ++n; return x > 1; }) + " " + n)
< true 2
> print([1].forEach(function () { return 9; }))
< undefined
-
// Holes are skipped rather than passed as undefined. map keeps the source's length and leaves holes as holes
// (15.4.4.19 step 6 creates the result with new Array(len)); filter packs its result densely instead.
> var a = [0,,2]; var seen = ""; a.forEach(function (x, i) { seen += i; }); print(seen)
< 02
> var a = [0,,2]; var r = a.map(function (x) { return x + 10; }); print(r.length + " " + (1 in r) + " " + r[0] + " " + r[2])
< 3 false 10 12
> var a = [0,,2]; var r = a.filter(function () { return true; }); print(r.length + " " + r.join(","))
< 2 0,2
-
// Generic over array-likes: length is ToUint32'd and membership decides what is visited.
> var o = {0:"a", 2:"c", length:3}; var v = []; [].forEach.call(o, function (x, i) { v.push(i + ":" + x); }); print(v.join(" "))
< 0:a 2:c
> var r = [].map.call("abc", function (c) { return c.toUpperCase(); }); print(r.join(""))
< ABC
> var n = 0; [].forEach.call({0:1, 1:2, length:"1"}, function () { ++n; }); print(n)
< 1
-
// thisArg is used as the callback's this; when omitted the callback sees undefined, which a non-strict callback
// resolves to the global object.
> var r; [1].forEach(function () { r = this.tag; }, {tag:"T"}); print(r)
< T
> var r; [1].forEach(function () { r = (this === undefined ? "undefined" : typeof this); }); print(r)
< object
> var r; [1].forEach(function () { r = typeof this; }, 5); print(r)
< object
-
// 10.6 / 9.9: a null or undefined this reaches ToObject and throws, and a non-callable callback is a TypeError
// even when the array is empty, because the check precedes the iteration.
> try { [].forEach.call(null, function () {}); } catch (e) { print(e.name) }
< TypeError
> try { [].map.call(undefined, function () {}); } catch (e) { print(e.name) }
< TypeError
> try { [].forEach(); } catch (e) { print(e.name) }
< TypeError
> try { [1].some(42); } catch (e) { print(e.name) }
< TypeError
-
// The visited range is fixed before the first callback: appended elements are not seen, deleted ones are skipped,
// and a changed element is passed as its value at visit time. filter selects on the value it read, not a later one.
> var a = [1,2], v = ""; a.forEach(function (x) { v += x; a.push(9); }); print(v + " len=" + a.length)
< 12 len=4
> var a = [1,2,3], v = ""; a.forEach(function (x, i) { v += x; if (i === 0) delete a[2]; }); print(v)
< 12
> var a = [1,2], v = ""; a.forEach(function (x, i) { v += x; if (i === 0) a[1] = 99; }); print(v)
< 199
> var a = [1,2]; var r = a.filter(function (x, i) { if (i === 0) a[0] = 77; return true; }); print(r.join(","))
< 1,2
-
// 15.4.4.x: each method's length is 1 and each is a non-enumerable, writable, configurable non-constructor.
> print([].forEach.length + " " + [].map.length + " " + [].filter.length + " " + [].every.length + " " + [].some.length)
< 1 1 1 1 1
> var d = Object.getOwnPropertyDescriptor(Array.prototype, "map"); print(d.writable + " " + d.enumerable + " " + d.configurable)
< true false true
> var n = 0; for (var k in [1]) ++n; print(n)
< 1
> try { new Array.prototype.forEach(function () {}); } catch (e) { print(e.name) }
< TypeError
-
