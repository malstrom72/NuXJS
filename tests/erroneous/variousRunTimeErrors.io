// CLI:
> b = a
< !!!! ReferenceError: a is not defined
< !!!! location: <anonymous>:1:6
< !!!! stack: ReferenceError: a is not defined
<     at <anonymous>:1:6
-
> (null)[3]
< !!!! TypeError: Cannot convert undefined or null to object
< !!!! location: <anonymous>:1:8
< !!!! stack: TypeError: Cannot convert undefined or null to object
<     at <anonymous>:1:8
-
> (null)[3]='x'
< !!!! TypeError: Cannot convert undefined or null to object
< !!!! location: <anonymous>:1:8
< !!!! stack: TypeError: Cannot convert undefined or null to object
<     at <anonymous>:1:8
-
> (null)()
< !!!! TypeError: null is not a function
< !!!! location: <anonymous>:1:9
< !!!! stack: TypeError: null is not a function
<     at <anonymous>:1:9
-
> (null).x()
< !!!! TypeError: Cannot convert undefined or null to object
< !!!! location: <anonymous>:1:8
< !!!! stack: TypeError: Cannot convert undefined or null to object
<     at <anonymous>:1:8
-
> delete (null)[3]
< !!!! TypeError: Cannot convert undefined or null to object
< !!!! location: <anonymous>:1:15
< !!!! stack: TypeError: Cannot convert undefined or null to object
<     at <anonymous>:1:15
-
> with (null) { }
< !!!! TypeError: Cannot convert undefined or null to object
< !!!! location: <anonymous>:1:12
< !!!! stack: TypeError: Cannot convert undefined or null to object
<     at <anonymous>:1:12
-
> for (i in null) { }
< !!!! TypeError: Cannot convert undefined or null to object
< !!!! location: <anonymous>:1:15
< !!!! stack: TypeError: Cannot convert undefined or null to object
<     at <anonymous>:1:15
-
