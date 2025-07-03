> // FIX : infinity etc
-
> o = new (function(){});
> print(o.a+0) // NaN
> garlicNan=o.a+0
> cheeseNan=o.b+0
> print(garlicNan<cheeseNan) // NaN comparisons are always false
> print(garlicNan<=cheeseNan) // NaN comparisons are always false
> print(garlicNan==cheeseNan) // NaN comparisons are always false
> print(garlicNan===cheeseNan) // NaN comparisons are always false
> print(garlicNan>=cheeseNan) // NaN comparisons are always false
> print(garlicNan>cheeseNan) // NaN comparisons are always false
> print(garlicNan!=cheeseNan) // but this is true
> print(garlicNan!==cheeseNan) // but this is true
< NaN
< false
< false
< false
< false
< false
< false
< true
< true
-
