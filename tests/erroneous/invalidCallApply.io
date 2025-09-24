// CLI:
> function f() { } 
> call=f.call
> call()
< !!!! TypeError: apply / call used on non-function
< !!!! location: <eval>:1:30
< !!!! stack: TypeError: apply / call used on non-function
<     at call (<eval>:1:30)
<     at <anonymous>:3:7
-
> apply=f.apply
> apply()
< !!!! TypeError: apply / call used on non-function
< !!!! location: <eval>:1:143
< !!!! stack: TypeError: apply / call used on non-function
<     at apply (<eval>:1:143)
<     at <anonymous>:2:8
-
