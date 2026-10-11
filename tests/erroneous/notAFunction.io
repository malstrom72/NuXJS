> f()
! !!!! ReferenceError: f is not defined
-
> f={}
-
> f()
! !!!! TypeError: [object Object] is not a function
-
> eval='abcd'
-
> eval()
! !!!! TypeError: "abcd" is not a function
-
> x = new eval()
! !!!! TypeError: "abcd" is not a function
-
> ({}).asdf()
! !!!! TypeError: asdf is not a function
-
> ({}) instanceof null
! !!!! TypeError: null is not a function
-
> ("")()
! !!!! TypeError: "" is not a function
-
> ("line" + String.fromCharCode(10) + "break")()
! !!!! TypeError: "line\nbreak" is not a function
-
> ("0123456789012345678901234567890123456789 and the rest")()
! !!!! TypeError: "0123456789012345678901234567890123456789..." is not a function
-
> var o = { name: 42 }; o.name()
! !!!! TypeError: name is not a function
-
