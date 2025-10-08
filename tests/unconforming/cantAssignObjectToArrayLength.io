// NuXJS keeps Array#length side-effect free by bypassing user-defined valueOf hooks.
// Assigning objects therefore triggers the RangeError guard instead of consulting valueOf.
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
