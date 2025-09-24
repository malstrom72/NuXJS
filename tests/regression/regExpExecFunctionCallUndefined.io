// CLI:
> var r = /[a-z]n/.exec(function(){}())
> print(r[0])
< un
-
> print(r.index)
< 0
-
> print(r.input)
< undefined
-
