// ES3 11.2.1: ToString of the property key (step 6) happens after ToObject checks the base (step 5), so a
// throwing base means the key is never coerced and its toString side effect must not run. Contrast the
// *BracketLeftFirst tests, where the key *expression* (step 3) does run.
> key = { toString: function() { hit = 1; return "x"; } }
-
> hit = 0
-
> (null)[key] = 1
! !!!! TypeError: Cannot convert undefined or null to object
> print(hit)
< 0
-
