> var invokeLengthValueOf = false;
> var a = [];
> var first = { valueOf: function() { invokeLengthValueOf = true; return 23; } };
> a.length = first;
> print(invokeLengthValueOf)
< true
> print(a.length)
< 23
-
> var invokeBracketValueOf = false;
> var second = { valueOf: function() { invokeBracketValueOf = true; return 47; } };
> var key = "length";
> a[key] = second;
> print(invokeBracketValueOf)
< true
> print(a.length)
< 47
-
