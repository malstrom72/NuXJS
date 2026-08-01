// ES5.1 11.1.5 added the trailing comma to ObjectLiteral: `{ }`, `{ PropertyNameAndValueList }` and
// `{ PropertyNameAndValueList , }`. ES3 11.1.5 had only the first two. NuXJS has always accepted it, which is why
// this is shared rather than an es5 twin; see docs/notes/ECMAScript Compatibility Notes.md. The array counterpart
// is tests/conforming/ArrayLiteralHoleLength.io, since 11.1.4 allowed elision in ES3 already. Verified against V8.
> var o = { a: 1, }; print(o.a + " " + Object.prototype.toString.call(o))
< 1 [object Object]
> var o = { a: 1, b: 2, }; var k = []; for (var p in o) k.push(p); k.sort(); print(k.join(",") + " " + o.b)
< a,b 2
> print(typeof { a: 1, } + " " + typeof {} + " " + typeof { a: 1 })
< object object object
-
// Exactly one trailing comma, and only after at least one property: the grammar has no elision for objects.
> try { eval("({ a: 1,, })"); print("no throw") } catch (e) { print(e.name) }
< SyntaxError
> try { eval("({ , })"); print("no throw") } catch (e) { print(e.name) }
< SyntaxError
> try { eval("({ , a: 1 })"); print("no throw") } catch (e) { print(e.name) }
< SyntaxError
-
// It does not create a property, so the object is indistinguishable from the one without the comma.
> var a = { x: 1, }, b = { x: 1 }; var n = 0; for (var p in a) ++n; var m = 0; for (var p in b) ++m; print(n + " " + m)
< 1 1
-
