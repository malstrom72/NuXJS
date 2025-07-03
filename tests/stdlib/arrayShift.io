> var a = [ 1, 2, 3, 4, 5, 6, 7 ];
> print(a.shift());
< 1
-
> print(a.toString());
< 2,3,4,5,6,7
-
> while (a.length > 0) print(a.shift());
< 2
< 3
< 4
< 5
< 6
< 7
-
> print(a.toString());
< 
-
> a = [ 1,,,3,,undefined,5 ];
> a.shift(); print(a.shift());
< undefined
-
> print(a.toString());
< ,3,,,5
-
> print(0 in a)
< false
-
> print((a.length - 1) in a)
< true
-
> print(a[a.length - 1])
< 5
-
> print((a.length - 2) in a)
< true
-
> print(a[a.length - 2])
< undefined
-
> while (a.length > 0) print(a.shift());
< undefined
< 3
< undefined
< undefined
< 5
-
> print(a.shift());
< undefined
-
> print(a.length);
< 0
-
> print(a.unshift("one", "two", "three", "four"));
> print(a.toString());
< 4
< one,two,three,four
-
> delete a[1]; delete a[3];
> print(a.toString());
< one,,three,
-
> print(a.unshift("minus2", "minus1", "zero"));
> print(a.toString());
< 7
< minus2,minus1,zero,one,,three,
-
> var o = { "0": "a", "1": "b", "2": "c", "3": "d", "length": 4.7 };
> print(Array.prototype.shift.call(o));
> print(o.length);
> print(o[0]);
> print(o[1]);
> print(o[2]);
< a
< 3
< b
< c
< d
-
> print(Array.prototype.unshift.call(o, "q", "w", "e"));
> print(o.length);
> print(o[0]);
> print(o[1]);
> print(o[2]);
> print(o[3]);
> print(o[4]);
> print(o[5]);
< 6
< 6
< q
< w
< e
< b
< c
< d
-
> var o = { shift: Array.prototype.shift };
> o.shift();
> print(o.length);
< 0
-
