// CLI:
> function O() { }; O.prototype = 1234;
> x = new O()
> x instanceof O
< !!!! TypeError: Non-object prototype in instanceof check
< !!!! location: <anonymous>:3:15
< !!!! stack: TypeError: Non-object prototype in instanceof check
<     at <anonymous>:3:15
-
