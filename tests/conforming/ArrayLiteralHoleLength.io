> a=[1,2,3,4];print(a[0]);print(a[3]);print(a[4]);print(a.length)
< 1
< 4
< undefined
< 4
-
> a=[1,2,3,,4];print(a[0]);print(a[3]);print(a[4]);print(a.length)
< 1
< undefined
< 4
< 5
-
> a=[1,2,3,,4,,];print(a[0]);print(a[3]);print(a[4]);print(a.length)
< 1
< undefined
< 4
< 6
-
> a=[,,1,2,3,,4,,];print(a[0]);print(a[3]);print(a[4]);print(a.length)
< undefined
< 2
< 3
< 8
-
> a=[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,,1,2,3,,4,,];print(a[0]);print(a[3]);print(a[4]);print(a[28]);print(a.length)
< 1
< 4
< 5
< 29
< 37
-
