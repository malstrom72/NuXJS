> print(true?3:false?7:9)
< 3
-
> print((true?3:false)?7:9)
< 7
-
> print(true?3:(false?7:9))
< 3
-
> print(true?3:false?true?2:5:9)
< 3
-
> print(false?3:false?true?2:5:9)
< 9
-
> print(false?3:true?true?2:5:9)
< 2
-
> print((false?9:3,6))
< 6
-
> print((true?9:3,6))
< 6
-
> a = [false?9:3,6]; print(a[0]); print(a[1]);
< 3
< 6
-
> a = [true?9:3,6]; print(a[0]); print(a[1]);
< 9
< 6
-
> f = function(a, b) { print(a); print(b); }; f(false?9:3,6);
< 3
< 6
-
> f(true?9:3,6);
< 9
< 6
-
> false?a=3:a=6; print(a)
< 6
-
> false?a=3:a=6,true?b=9:b=12; print(a); print(b)
< 6
< 9
-
> true?a=3:a=6,false?b=9:b=12; print(a); print(b)
< 3
< 12
-
> false?a=c=3:a=c=6,true?b=d=9:b=d=12; print(c); print(d)
< 6
< 9
-
> true?a=c=3:a=c=6,false?b=d=9:b=d=12; print(c); print(d)
< 3
< 12
-
