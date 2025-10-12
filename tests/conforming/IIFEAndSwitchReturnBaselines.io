> print((function() { return 123 })())
< 123
-
> print((function() { return 123+123 })())
< 246
-
> print((function() { if (false) return 123+123 })())
< undefined
-
> print((function() { out: { break out; if (false) return 123+123 } })())
< undefined
-
> print((function() { switch (3) { case 3: return 3 } })())
< 3
-
> print((function(a) { switch (a) { case 3: return 3 } })(3))
< 3
-
> print((function(a) { switch (a) { case 3: return 3+8 } })(3))
< 11
-
> print((function(a) { switch (a) { case 3: switch (a) { case 3: return 3+8 } } })(3))
< 11
-
