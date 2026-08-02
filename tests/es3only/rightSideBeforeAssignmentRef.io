// ES3 only. 11.13.1 evaluates the LeftHandSideExpression at step 1, before the right-hand side, and gives that
// same Reference to PutValue at step 4, so a right-hand side that moves the binding must not retarget the write.
// The es3 engine resolves the name again instead, and that is left as it stands: see the es5 twin for the
// conformant expectations, and docs/notes/ECMAScript Compatibility Notes.md for why.
> var x = 0;
>   var innerX = (function() {
>     // If we were to conform strictly to ES spec, the left-hand side of th assigment is a reference to the outer x.
>     x = (eval("var x;"), 1);
>     return x;
>   })();
> print(typeof innerX);
> print(x);
// Strict ES conformance:
// < undefined
// < 1
< number
< 0
-
> function testFunction() {
>   var x = 0;
>   var scope = {x: 1};
>   with (scope) {
>     x = (delete scope.x, 2);
>   }
>   print(scope.x);
>   print(x);
> }
> testFunction();
< undefined
< 2
-
