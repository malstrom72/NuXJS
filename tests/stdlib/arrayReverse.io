> var a = [ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 ];
> print(a.toString())
< 1,2,3,4,5,6,7,8,9,10
-
> a.reverse()
> print(a.toString())
< 10,9,8,7,6,5,4,3,2,1
-
> var a = [ 1, 2, 3, 4, 5, 6, 7, 8, 9 ];
> print(a.toString())
< 1,2,3,4,5,6,7,8,9
-
> a.reverse()
> print(a.toString())
< 9,8,7,6,5,4,3,2,1
-
> var a = [ ]
> a.reverse()
> print(a.toString())
< 
-
> var a = [ 1,,,3,,,,,,undefined,'end' ];
> print(a.toString())
< 1,,,3,,,,,,,end
-
> a.reverse()
> print(a.toString())
< end,,,,,,,3,,,1
-
> for (var i = 0; i < a.length; ++i) print(i + ': ' + (i in a) + ' ' + (typeof a[i]) + ' ' + a[i])
< 0: true string end
< 1: true undefined undefined
< 2: false undefined undefined
< 3: false undefined undefined
< 4: false undefined undefined
< 5: false undefined undefined
< 6: false undefined undefined
< 7: true number 3
< 8: false undefined undefined
< 9: false undefined undefined
< 10: true number 1
-
> print(a.reverse().toString())
< 1,,,3,,,,,,,end
-
> var o = { "0": "a", "1": "b", "2": "c", "3": "d", "length": 4.7 };
> Array.prototype.reverse.call(o);
> print(o[0]);
< d
-
> print(o[1]);
< c
-
> print(o[2]);
< b
-
> print(o[3]);
< a
-
> print(o.length);
< 4.7
-
