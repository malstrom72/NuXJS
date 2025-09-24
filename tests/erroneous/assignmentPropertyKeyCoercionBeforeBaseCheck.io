// CLI:
> var key = { toString: function() { hit = 1; return "x"; } }
-
> hit = 0
-
> (null)[key] = 1
< !!!! TypeError: Cannot convert undefined or null to object
< !!!! location: <anonymous>:1:8
< !!!! stack: TypeError: Cannot convert undefined or null to object
<     at <anonymous>:1:8
> hit
0
-
