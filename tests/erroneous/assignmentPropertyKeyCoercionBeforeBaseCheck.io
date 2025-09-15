> var key = { toString: function() { hit = 1; return "x"; } }
-
> hit = 0
-
> (null)[key] = 1
! !!!! TypeError: Cannot convert undefined or null to object
> hit
0
-

