// ES3 11.2.1: the key Expression is evaluated (step 3) before ToObject checks the base (step 5), so the key
// side effect happens even though the base then throws. 11.13.1 evaluates the whole LeftHandSideExpression
// (step 1) before the right-hand side (step 2), so the assigned value is never evaluated.
> hit = 0
-
> rhsHit = 0
-
> (undefined)[hit = 1] = (rhsHit = 1)
! !!!! TypeError: Cannot convert undefined or null to object
> print(hit)
< 1
> print(rhsHit)
< 0
-
