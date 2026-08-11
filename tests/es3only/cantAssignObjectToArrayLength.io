// The es3 build keeps Array#length side-effect free by bypassing user-defined valueOf hooks, so assigning an object
// trips the RangeError guard instead of consulting valueOf. ES3 15.4.5.1 does ask for ToUint32 here, which would run
// the hook, so this is a deviation rather than a choice the spec leaves open. It stands because the es3 store opcode
// SET_PROPERTY_OP has neither the setter machinery nor the trailing POP_OP that the es5 one carries, and the object
// model may not run script on its own. The es5 build does conform; the twin is tests/es5/arrayLengthCoercion.io.
> var invokeLengthValueOf = false;
> var a = [];
> var first = { valueOf: function() { invokeLengthValueOf = true; return 23; } };
> a.length = first
! !!!! RangeError: Invalid array length
-
> print(invokeLengthValueOf)
< false
-
> var invokeBracketValueOf = false;
> var second = { valueOf: function() { invokeBracketValueOf = true; return 47; } };
> var key = 'length';
> a[key] = second
! !!!! RangeError: Invalid array length
-
> print(invokeBracketValueOf)
< false
-
> print(a.length)
< 0
-
