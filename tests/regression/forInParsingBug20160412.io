> a=[1,2]; for (a[1 in a ? 1 : 0] = 23; false;) { }
> print(a[0])
> print(a[1])
< 1
< 23
> a=[1]; for (a[1 in a ? 1 : 0] = 23; false;) { }
> print(a[0])
< 23
-
> x=function(){return 0};for (i = x(1 in {}); i <5; ++i) print(i);
< 0
< 1
< 2
< 3
< 4
-
> a=[1,2,3];for (i = a[1 in a?1:0]; i <5; ++i) print(i);
< 2
< 3
< 4
-
> a=[1,2,3];for (i = (1 in a?1:0); i <5; ++i) print(i);
< 1
< 2
< 3
< 4
-
> a=[1,2,3];for (a[(1 in a?1:0)]=0,i=0; i <5; ++i) print(i);
< 0
< 1
< 2
< 3
< 4
-
> a=[1,2,3];for (i in a) print(i);
< 0
< 1
< 2
-
> a=[1,2,3];for (a[1 in a ? 1:0] in a) print(a[1]);
< 0
< 1
< 2
-
> a=[1,2,3];for (var i in a) print(i);
< 0
< 1
< 2
-
> a=[1,2,3];for (var i = a[1 in a?1:0]; i <5; ++i) print(i);
< 2
< 3
< 4
-
> a=[1,2,3];for (var j,i = a[1 in a?1:0]; i <5; ++i) print(i);
< 2
< 3
< 4
-
> x=function() { return { i: 0 } }; var o; for (new x('' in {}).i in [1,2,3]) print('x')
< x
< x
< x
-

