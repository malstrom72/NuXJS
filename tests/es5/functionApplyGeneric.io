// 15.3.4.3: apply takes ANY object as its argument list (step 3), reading length and indices generically - the
// Array-or-Arguments class test was ES3's rule and stays in the es3 build. Strict receivers pass unboxed (10.4.3).
> function count() { return arguments.length + ":" + arguments[0]; }
> print(count.apply(null, { length: 2, 0: "a", 1: "b" }))
< 2:a
> print(count.apply(null, Array))
< 1:undefined
> print(count.apply(null, { wrong: "type of object" }))
< 0:undefined
-
// Step 2: null or undefined argArray calls with no arguments at all.
> print(count.apply(null, null) + " | " + count.apply(null))
< 0:undefined | 0:undefined
-
// Step 3: a primitive argArray is still a TypeError.
> try { count.apply(null, 42); } catch (e) { print(e.name) }
< TypeError
> try { count.apply(null, "ab"); } catch (e) { print(e.name) }
< TypeError
-
// The strict receiver arrives verbatim even through the generic list (the 15.3.4.3-1-s shape).
> function strictThis() { "use strict"; return this === "" ? "primitive" : typeof this; }
> print(strictThis.apply("", Array))
< primitive
-
