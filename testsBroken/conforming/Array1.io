> a=[1,2,3,4]
-
> z=0;for( i in a) z+=(1<<i); print(z)
< 15
-
> delete a[2]
-
> z=0;for( i in a) z+=(1<<i); print(z)
< 11
-
> a[2]=5
-
> z=0;for( i in a) z+=(1<<i); print(z)
< 15
-
> a[' 1 ']='y'
-
> z=0;for( i in a) z+=(1<<i); print(z)
< 17
-
