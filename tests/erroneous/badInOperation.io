// CLI:
> 5 in 5
< !!!! TypeError: Cannot use 'in' operator on 5
< !!!! location: <anonymous>:1:7
< !!!! stack: TypeError: Cannot use 'in' operator on 5
<     at <anonymous>:1:7
-
> 'x' in 'asdf'
< !!!! TypeError: Cannot use 'in' operator on asdf
< !!!! location: <anonymous>:1:14
< !!!! stack: TypeError: Cannot use 'in' operator on asdf
<     at <anonymous>:1:14
-
> 'z' in null
< !!!! TypeError: Cannot use 'in' operator on null
< !!!! location: <anonymous>:1:12
< !!!! stack: TypeError: Cannot use 'in' operator on null
<     at <anonymous>:1:12
-
> 'z' in String('asdf')
< !!!! TypeError: Cannot use 'in' operator on asdf
< !!!! location: <anonymous>:1:22
< !!!! stack: TypeError: Cannot use 'in' operator on asdf
<     at <anonymous>:1:22
-
> 'x' in new String('asdf')
-
