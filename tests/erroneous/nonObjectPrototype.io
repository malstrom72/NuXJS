> function O() { }; O.prototype = 1234;
> x = new O()
> x instanceof O
! !!!! TypeError: Non-object prototype in instanceof check
-
