> s = ''; for ( a in "abcdefgh" ) s += a + ','; print(s);
> s = ''; for ( var a in "abcdefgh" ) s += a + ','; print(s);
> s = ''; for ( var a = 100 in "abcdefgh" ) s += a + ','; print(s);
> s = ''; for ( var a = 100 in "" ) ; print(a);
> a = { }; for (a.x in "abcd") print(a.x)
> a = { }; x = 0; for (a[x++] in "abcd") { }; print(x); for (var i = 0; i < x; ++i) print(a[i]);
> a = { }; f = function() { print("tick "); return 0 }; for (a[f()] in "abcd") { print (a[0]) }
< 0,1,2,3,4,5,6,7,
< 0,1,2,3,4,5,6,7,
< 0,1,2,3,4,5,6,7,
< 100
< 0
< 1
< 2
< 3
< 4
< 0
< 1
< 2
< 3
< tick 
< 0
< tick 
< 1
< tick 
< 2
< tick 
< 3
-
