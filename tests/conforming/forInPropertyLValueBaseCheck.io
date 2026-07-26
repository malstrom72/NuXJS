// ES3 12.6.4: `for ( LeftHandSideExpression in Expression )` accepts any LeftHandSideExpression, including a member
// expression such as `(5).x` or `obj[k]`. Step 5 skips to the end when there is no enumerable property, so the
// LeftHandSideExpression (step 6) is evaluated only once a property exists; step 7 then PutValues into it. Evaluating
// a member LHS runs 11.2.1: ToObject(base) (step 5), which throws for null/undefined and boxes a primitive otherwise.
// A regression once compiled the property store as an unchecked getObject(), so a primitive base was type-confused
// (a SIGSEGV in release, an assert in debug). These lock the ES3 behaviour down; verified against V8.
// A number, boolean or string base is boxed to a throwaway wrapper, so the loop completes and the write is a no-op.
> var hits = 0; for ((5).x in {a:1}) { hits++; } print(hits)
< 1
> for (true.y in {a:1}) { } print("bool-base-ok")
< bool-base-ok
> for ("abc".z in {a:1}) { } print("string-base-ok")
< string-base-ok
-
// The bracket form behaves identically (11.2.1 dot is defined as bracket with a string-literal key).
> for ((5)["x"] in {a:1}) { } print("num-bracket-ok")
< num-bracket-ok
-
// The wrapper is a temporary, so the assignment leaves no trace on the primitive (a String literal is not corrupted).
> for ("abc".zz in {k:1}) { } print("abc".zz)
< undefined
-
// A real object base does receive the assignment. A single-property source keeps this independent of enumeration
// order (12.6.4 leaves the order implementation-defined).
> var o = {}; for (o.prop in {only:1}) { } print(o.prop)
< only
> var arr = []; for (arr[0] in {only:1}) { } print(arr[0])
< only
-
// null / undefined base: ToObject throws, but only once a property is actually enumerated (step 5 skips first).
> for (null.x in {a:1}) { }
! !!!! TypeError: Cannot convert undefined or null to object
-
> for (undefined.x in {a:1}) { }
! !!!! TypeError: Cannot convert undefined or null to object
-
> for (null["x"] in {a:1}) { }
! !!!! TypeError: Cannot convert undefined or null to object
-
// With no enumerable property the LHS is never evaluated, so a null base does NOT throw (12.6.4 step 5).
> var n = 0; for (null.x in {}) { n++; } print("no-prop-no-throw:" + n)
< no-prop-no-throw:0
> for (undefined.x in {}) { } print("undef-empty-ok")
< undef-empty-ok
-
