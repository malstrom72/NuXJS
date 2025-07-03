> b = a
! !!!! ReferenceError: a is not defined
-
> (null)[3]
! !!!! TypeError: Cannot convert undefined or null to object
-
> (null)[3]='x'
! !!!! TypeError: Cannot convert undefined or null to object
-
> (null)()
! !!!! TypeError: null is not a function
-
> (null).x()
! !!!! TypeError: Cannot convert undefined or null to object
-
> delete (null)[3]
! !!!! TypeError: Cannot convert undefined or null to object
-
> with (null) { }
! !!!! TypeError: Cannot convert undefined or null to object
-
> for (i in null) { }
! !!!! TypeError: Cannot convert undefined or null to object
-
