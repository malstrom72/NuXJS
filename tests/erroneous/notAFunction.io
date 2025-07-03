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
! !!!! TypeError: abcd is not a function
-
> x = new eval()
! !!!! TypeError: abcd is not a function
-
> ({}).asdf()
! !!!! TypeError: asdf is not a function
-
> ({}) instanceof null
! !!!! TypeError: null is not a function
-
