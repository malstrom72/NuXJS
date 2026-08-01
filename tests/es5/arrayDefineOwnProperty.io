// ES5.1 15.4.5.1 [[DefineOwnProperty]] for Array objects, and 15.4.5.2 length. Arrays keep a separate writable
// flag for length, and an element that needs real attributes moves out of the dense vector into the table.
// Verified against V8 except where ES2015 changed the rules; those are in docs/specs/ES5.1 vs modern divergences.md.
// 15.4.5.2: length starts { [[Writable]]: true, [[Enumerable]]: false, [[Configurable]]: false }.
> var d = Object.getOwnPropertyDescriptor([1,2], "length"); print(d.value + " " + d.writable + " " + d.enumerable + " " + d.configurable)
< 2 true false false
> print(Object.getOwnPropertyNames([1,2]).sort().join(","))
< 0,1,length
-
// Step 3: defining length with a value truncates or grows; a value that does not survive ToUint32 is a RangeError.
> var a = [1,2,3]; Object.defineProperty(a, "length", { value: 1 }); print(a.length + " [" + a.join(",") + "]")
< 1 [1]
> var a = [1]; Object.defineProperty(a, "length", { value: 3 }); print(a.length + " " + (1 in a))
< 3 false
> try { Object.defineProperty([], "length", { value: -1 }); print("no throw") } catch (e) { print(e.name) }
< RangeError
> try { Object.defineProperty([], "length", { value: 1.5 }); print("no throw") } catch (e) { print(e.name) }
< RangeError
-
// length is non-configurable and non-enumerable, so 8.12.9 refuses to change either, or to make it an accessor.
> try { Object.defineProperty([], "length", { enumerable: true }); print("no throw") } catch (e) { print(e.name) }
< TypeError
> try { Object.defineProperty([], "length", { configurable: true }); print("no throw") } catch (e) { print(e.name) }
< TypeError
> try { Object.defineProperty([], "length", { get: function () { return 0; } }); print("no throw") } catch (e) { print(e.name) }
< TypeError
-
// Step 3.9: writable can be cleared, and then nothing may grow or shrink the array again, nor turn it back on.
> var a = [1,2]; Object.defineProperty(a, "length", { writable: false }); var d = Object.getOwnPropertyDescriptor(a, "length"); print(d.writable + " " + d.value)
< false 2
> var a = [1,2]; Object.defineProperty(a, "length", { writable: false }); a.length = 5; print(a.length)
< 2
> var a = [1,2]; Object.defineProperty(a, "length", { writable: false }); a[5] = 9; print(a.length + " " + (5 in a))
< 2 false
> var a = [1,2]; Object.defineProperty(a, "length", { writable: false }); try { Object.defineProperty(a, "length", { writable: true }); print("no throw") } catch (e) { print(e.name) }
< TypeError
> var a = [1,2]; Object.defineProperty(a, "length", { writable: false }); try { Object.defineProperty(a, "2", { value: 3 }); print("no throw") } catch (e) { print(e.name) }
< TypeError
-
// Step 12: shrinking deletes from the top down and stops below the highest element that refuses to go, leaving
// length one past it and reporting failure.
> var a = [0,1,2,3]; Object.defineProperty(a, "2", { configurable: false }); a.length = 0; print(a.length + " [" + a.join(",") + "]")
< 3 [0,1,2]
> var a = [0,1,2,3]; Object.defineProperty(a, "2", { configurable: false }); try { Object.defineProperty(a, "length", { value: 0 }); print("no throw") } catch (e) { print(e.name) } print(a.length)
< TypeError
< 3
> var a = [0,1,2,3]; Object.defineProperty(a, "1", { configurable: false }); a.length = 3; print(a.length + " [" + a.join(",") + "]")
< 3 [0,1,2]
-
// Step 4: an index define keeps the array's length one past the highest index, and honours the attributes.
> var a = []; Object.defineProperty(a, "5", { value: 1 }); print(a.length + " " + a[5])
< 6 1
> var a = [1,2]; Object.defineProperty(a, "0", { writable: false }); a[0] = 9; print(a[0])
< 1
> var a = [1,2]; Object.defineProperty(a, "0", { enumerable: false }); var ks = []; for (var k in a) ks.push(k); print("[" + ks.join(",") + "] " + a[0])
< [1] 1
> var a = [1,2]; Object.defineProperty(a, "0", { value: 9, writable: false, enumerable: false, configurable: false }); var d = Object.getOwnPropertyDescriptor(a, "0"); print(d.value + " " + d.writable + " " + d.enumerable + " " + d.configurable)
< 9 false false false
-
// An element that only gets new attributes keeps the value it already had.
> var a = [7,8]; Object.defineProperty(a, "0", { writable: false }); print(a[0] + " " + a[1] + " " + a.length)
< 7 8 2
-
// An accessor works on an index, which the dense-vector model has to fall out of to represent.
> var a = []; Object.defineProperty(a, "0", { get: function () { return 42; } }); print(a[0] + " " + a.length)
< 42 1
> var a = [1,2,3]; Object.defineProperty(a, "1", { get: function () { return 99; } }); print(a.join(",") + " " + a.length)
< 1,99,3 3
-
// A non-configurable element cannot be redefined, but a configurable one can.
> var a = [1]; Object.defineProperty(a, "0", { configurable: false }); try { Object.defineProperty(a, "0", { configurable: true }); print("no throw") } catch (e) { print(e.name) }
< TypeError
> var a = [1]; Object.defineProperty(a, "0", { value: 2 }); print(a[0])
< 2
-
// 8.12.9 step 3: a non-extensible array refuses a new index but still allows an existing one to be redefined.
> var a = [1]; Object.preventExtensions(a); try { Object.defineProperty(a, "1", { value: 2 }); print("no throw") } catch (e) { print(e.name) } print(a.length)
< TypeError
< 1
> var a = [1]; Object.preventExtensions(a); Object.defineProperty(a, "0", { value: 7 }); print(a[0])
< 7
> var a = [1]; Object.preventExtensions(a); a[1] = 2; print(a.length + " " + (1 in a))
< 1 false
-
// freeze and seal now go through the real algorithm on arrays too.
> var a = [1,2]; Object.freeze(a); a[0] = 9; print(Object.isFrozen(a) + " " + a.join(",") + " " + Object.getOwnPropertyDescriptor(a, "length").writable)
< true 1,2 false
> var a = [1,2]; Object.seal(a); a[0] = 9; print(Object.isSealed(a) + " " + a.join(",") + " " + (delete a[0]))
< true 9,2 false
-
