// ES3 11.2.1: the key Expression is evaluated (step 3) before ToObject checks the base (step 5). 11.4.4
// evaluates the LeftHandSideExpression first, so the throw happens after the key side effect.
> hit = 0
-
> ++(null)[hit = 1]
! !!!! TypeError: Cannot convert undefined or null to object
> print(hit)
< 1
-
