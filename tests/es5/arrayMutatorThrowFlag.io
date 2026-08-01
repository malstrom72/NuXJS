// ES5.1 15.4.4.6-13. Every [[Put]] and [[Delete]] these seven make carries Throw = true, so a refused store is a
// TypeError instead of the silence the ES3 editions of the same algorithms left behind. Twin holding the ES3
// answers: tests/es3only/arrayMutatorNoThrowFlag.io. The whole matrix below was verified against V8.
> var ops = { push: function (a) { a.push(9) }, pop: function (a) { a.pop() }, shift: function (a) { a.shift() }
>		, unshift: function (a) { a.unshift(9) }, reverse: function (a) { a.reverse() }, sort: function (a) { a.sort() }
>		, splice: function (a) { a.splice(0, 1) }, "splice+": function (a) { a.splice(0, 0, 9) } };
> var names = [ "push", "pop", "shift", "unshift", "reverse", "sort", "splice", "splice+" ];
> function probe(make) {
>	var r = [];
>	for (var i = 0; i < names.length; ++i) {
>		var n = names[i];
>		try { ops[n](make()); r.push(n + ":ok") } catch (e) { r.push(n + ":" + e.name) }
>	}
>	return r.join(" ");
> }
-
// Frozen refuses everything: every element is non-writable and so is length.
> print(probe(function () { return Object.freeze([1, 2, 3]) }))
< push:TypeError pop:TypeError shift:TypeError unshift:TypeError reverse:TypeError sort:TypeError splice:TypeError splice+:TypeError
// Sealed only clears configurable, so reordering in place is still allowed; deleting or growing is not.
> print(probe(function () { return Object.seal([1, 2, 3]) }))
< push:TypeError pop:TypeError shift:TypeError unshift:TypeError reverse:ok sort:ok splice:TypeError splice+:TypeError
// Non-extensible still allows the shrinking half of the family, because nothing new is ever created.
> print(probe(function () { return Object.preventExtensions([1, 2, 3]) }))
< push:TypeError pop:ok shift:ok unshift:TypeError reverse:ok sort:ok splice:ok splice+:TypeError
// One read-only element is enough, but only for the methods that actually write over that index.
> print(probe(function () { var a = [1, 2, 3]; Object.defineProperty(a, "1", { writable: false }); return a }))
< push:ok pop:ok shift:TypeError unshift:TypeError reverse:ok sort:TypeError splice:TypeError splice+:TypeError
// A read-only length stops every method that reports one, even where no element had to move.
> print(probe(function () { var a = [1, 2, 3]; Object.defineProperty(a, "length", { writable: false }); return a }))
< push:TypeError pop:TypeError shift:TypeError unshift:TypeError reverse:ok sort:ok splice:TypeError splice+:TypeError
// A non-configurable but still writable element refuses nothing: none of these has to delete that index.
> print(probe(function () { var a = [1, 2, 3]; Object.defineProperty(a, "1", { configurable: false }); return a }))
< push:ok pop:ok shift:ok unshift:ok reverse:ok sort:ok splice:ok splice+:ok
// The flag is not an Array thing, and holes do not exempt anything either.
> print(probe(function () { var o = { length: 3, 0: 1, 1: 2, 2: 3 }; Object.freeze(o); return o }))
< push:TypeError pop:TypeError shift:TypeError unshift:TypeError reverse:TypeError sort:TypeError splice:TypeError splice+:TypeError
> print(probe(function () { return Object.freeze([1, , 3]) }))
< push:TypeError pop:TypeError shift:TypeError unshift:TypeError reverse:TypeError sort:TypeError splice:TypeError splice+:TypeError
-
// pop and shift store length even when there is nothing to remove (15.4.4.6 step 4.a, 15.4.4.9 step 4.a).
> var a = []; Object.defineProperty(a, "length", { writable: false }); try { a.pop(); print("no throw") } catch (e) { print(e.name) } try { a.shift(); print("no throw") } catch (e) { print(e.name) }
< TypeError
< TypeError
-
// The algorithms themselves are unchanged from ES3: holes stay holes, array-likes work, return values match.
> var a = [1, , 3]; print(a.splice(0, 2).length + " " + a.length); var b = [1, , 3]; b.reverse(); print(b.join(",") + " " + (1 in b)); var c = [1, , 3]; print(c.shift() + " " + (0 in c) + " " + c.length)
< 2 1
< 3,,1 false
< 1 false 2
> var o = { length: 3, 0: "a", 2: "c" }; print(Array.prototype.unshift.call(o, "z") + " " + o[0] + o[1] + " " + (2 in o) + " " + o[3])
< 4 za false c
// 15.4.4.12 step 7 taken literally would make a.splice(i) delete nothing; ES2015 rewrote it to len - start, which
// is what every engine and stdlib.js do. With no arguments at all nothing is deleted.
> print([1, 2].splice().length + " " + [1, 2, 3].splice(1).join(",") + " " + [1, 2, 3].splice(1, undefined).length)
< 0 2,3 0
// 15.4.4.11 SortCompare: undefined ranks after everything, and a hole after even that.
> var a = [, 3, , 1]; a.sort(); print(a.join(",") + " " + a.length + " " + (2 in a)); print([undefined, 3, 1].sort().join(","))
< 1,3,, 4 false
< 1,3,
-
// 15.4.4.x fixes each length, and like every built-in they are writable, non-enumerable, configurable and not
// constructors. splice takes two formal parameters, which is why its length is 2.
> var r = []; for (var i = 0; i < names.length - 1; ++i) { var d = Object.getOwnPropertyDescriptor(Array.prototype, names[i]); r.push(names[i] + ":" + Array.prototype[names[i]].length + (d.writable && !d.enumerable && d.configurable ? "" : "!ATTRS")) } print(r.join(" "))
< push:1 pop:0 shift:0 unshift:1 reverse:0 sort:1 splice:2
> var r = []; for (var i = 0; i < names.length - 1; ++i) { try { new Array.prototype[names[i]](); r.push(names[i] + ":constructable") } catch (e) { r.push(names[i] + ":" + e.name) } } print(r.join(" "))
< push:TypeError pop:TypeError shift:TypeError unshift:TypeError reverse:TypeError sort:TypeError splice:TypeError
// Step 1 of each is ToObject(this), which throws for null and undefined (9.9). Being strict is what keeps that
// reachable: 10.4.3 would otherwise have replaced the receiver with the global object.
> var r = []; for (var i = 0; i < names.length - 1; ++i) { try { Array.prototype[names[i]].call(null); r.push(names[i] + ":ok") } catch (e) { r.push(names[i] + ":" + e.name) } } print(r.join(" "))
< push:TypeError pop:TypeError shift:TypeError unshift:TypeError reverse:TypeError sort:TypeError splice:TypeError
-
