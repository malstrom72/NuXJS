// CLI:
> for (i in null) ;
< !!!! TypeError: Cannot convert undefined or null to object
< !!!! location: <anonymous>:1:15
< !!!! stack: TypeError: Cannot convert undefined or null to object
<     at <anonymous>:1:15
-
> for (i in undefined) ;
< !!!! TypeError: Cannot convert undefined or null to object
< !!!! location: <anonymous>:1:20
< !!!! stack: TypeError: Cannot convert undefined or null to object
<     at <anonymous>:1:20
-
