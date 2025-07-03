> a = [ 1, 2, 3, 4 ];
> b=a.concat('a', 'b', 'c', 'd')
> print(b.toString())
> print(a.toString())
< 1,2,3,4,a,b,c,d
< 1,2,3,4
-
> b=b.concat([ 'x', 'y', 'z' ], [ 'qwerty', 'iop' ])
> print(b.toString())
< 1,2,3,4,a,b,c,d,x,y,z,qwerty,iop
-
> b=b.concat([ ,,,'hop',,, ])
> print(b.toString())
> print(typeof b[b.length - 1]);
> print((b.length - 1) in b);
< 1,2,3,4,a,b,c,d,x,y,z,qwerty,iop,,,,hop,,
< undefined
< false
-
> b=b.concat([ ,,,'hop2',,,undefined ])
> print(b.toString())
< 1,2,3,4,a,b,c,d,x,y,z,qwerty,iop,,,,hop,,,,,,hop2,,,
-
> print(typeof b[b.length - 1])
> print((b.length - 1) in b);
< undefined
< true
-
