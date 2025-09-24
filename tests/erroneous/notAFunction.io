// CLI:
> f()
< !!!! ReferenceError: f is not defined
< !!!! location: <anonymous>:1:3
< !!!! stack: ReferenceError: f is not defined
<     at <anonymous>:1:3
-
> f={}
-
> f()
< !!!! TypeError: [object Object] is not a function
< !!!! location: <anonymous>:1:4
< !!!! stack: TypeError: [object Object] is not a function
<     at <anonymous>:1:4
-
> eval='abcd'
-
> eval()
< !!!! TypeError: abcd is not a function
< !!!! location: <anonymous>:1:7
< !!!! stack: TypeError: abcd is not a function
<     at <anonymous>:1:7
-
> x = new eval()
< !!!! TypeError: abcd is not a function
< !!!! location: <anonymous>:1:15
< !!!! stack: TypeError: abcd is not a function
<     at <anonymous>:1:15
-
> ({}).asdf()
< !!!! TypeError: asdf is not a function
< !!!! location: <anonymous>:1:12
< !!!! stack: TypeError: asdf is not a function
<     at <anonymous>:1:12
-
> ({}) instanceof null
< !!!! TypeError: null is not a function
< !!!! location: <anonymous>:1:21
< !!!! stack: TypeError: null is not a function
<     at <anonymous>:1:21
-
