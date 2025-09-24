// CLI:
> new isNaN()
< !!!! TypeError: isNaN is not a constructor
< !!!! location: <anonymous>:1:12
< !!!! stack: TypeError: isNaN is not a constructor
<     at <anonymous>:1:12
-
> isNaN.name='xyzzy'
-
> print(isNaN.name)
< xyzzy
-
> new isNaN()
< !!!! TypeError: isNaN is not a constructor
< !!!! location: <anonymous>:1:12
< !!!! stack: TypeError: isNaN is not a constructor
<     at <anonymous>:1:12
-
