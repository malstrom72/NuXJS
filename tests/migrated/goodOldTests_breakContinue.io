> { var i = 0; while (++i < 5) { print("before " + i); if (i > 2) continue; print("after " + i) } }
> { var i = 0; while (++i < 5) { print("before " + i); if (i > 2) break; print("after " + i) } }
> { var i = 0; a : while (++i < 5) { print("before " + i); if (i > 2) continue a; print("after " + i) } }
> { var i = 0; a : while (++i < 5) { print("before " + i); if (i > 2) break a; print("after " + i) } }
> { var i = 0; a : b:while (++i < 5) { print("before " + i); if (i > 2) continue a; print("after " + i) } }
> { var i = 0; a : b:while (++i < 5) { print("before " + i); if (i > 2) continue b; print("after " + i) } }
> { var i = 0; a : { b:while (++i < 5) { print("before " + i); if (i > 2) break a; print("after " + i) } } }
> { var i = 0; a : { b:while (++i < 5) { print("before " + i); if (i > 2) break b; print("after " + i) } } }
> { x = 0; var i = 0; a: while (i < 5) { ++i; j=0; b:while(j++ < 3) { print("iter " + i + "," + j); if (++x < 3) continue b; } } }
> { x = 0; var i = 0; a: while (i < 5) { ++i; j=0; b:while(j++ < 3) { print("iter " + i + "," + j); if (++x < 3) continue a; } } }
> { x = 0; var i = 0; a: while (i < 5) { ++i; j=0; b:while(j++ < 3) { print("iter " + i + "," + j); if (++x > 4) break b; } } }
> { x = 0; var i = 0; a: while (i < 5) { ++i; j=0; b:while(j++ < 3) { print("iter " + i + "," + j); if (++x > 4) break a; } } }
> { x = 0; b: do { y = 0; a: do { print('before ' + y + ',' + x); if (y > 2) continue b; print('after ' + y + ',' + x);  } while (++y < 5); } while (++x < 5) }
> { x = 0; b: do { y = 0; a: do { print('before ' + y + ',' + x); if (y > 2) continue a; print('after ' + y + ',' + x);  } while (++y < 5); } while (++x < 5) }
< before 1
< after 1
< before 2
< after 2
< before 3
< before 4
< before 1
< after 1
< before 2
< after 2
< before 3
< before 1
< after 1
< before 2
< after 2
< before 3
< before 4
< before 1
< after 1
< before 2
< after 2
< before 3
< before 1
< after 1
< before 2
< after 2
< before 3
< before 4
< before 1
< after 1
< before 2
< after 2
< before 3
< before 4
< before 1
< after 1
< before 2
< after 2
< before 3
< before 1
< after 1
< before 2
< after 2
< before 3
< iter 1,1
< iter 1,2
< iter 1,3
< iter 2,1
< iter 2,2
< iter 2,3
< iter 3,1
< iter 3,2
< iter 3,3
< iter 4,1
< iter 4,2
< iter 4,3
< iter 5,1
< iter 5,2
< iter 5,3
< iter 1,1
< iter 2,1
< iter 3,1
< iter 3,2
< iter 3,3
< iter 4,1
< iter 4,2
< iter 4,3
< iter 5,1
< iter 5,2
< iter 5,3
< iter 1,1
< iter 1,2
< iter 1,3
< iter 2,1
< iter 2,2
< iter 3,1
< iter 4,1
< iter 5,1
< iter 1,1
< iter 1,2
< iter 1,3
< iter 2,1
< iter 2,2
< before 0,0
< after 0,0
< before 1,0
< after 1,0
< before 2,0
< after 2,0
< before 3,0
< before 0,1
< after 0,1
< before 1,1
< after 1,1
< before 2,1
< after 2,1
< before 3,1
< before 0,2
< after 0,2
< before 1,2
< after 1,2
< before 2,2
< after 2,2
< before 3,2
< before 0,3
< after 0,3
< before 1,3
< after 1,3
< before 2,3
< after 2,3
< before 3,3
< before 0,4
< after 0,4
< before 1,4
< after 1,4
< before 2,4
< after 2,4
< before 3,4
< before 0,0
< after 0,0
< before 1,0
< after 1,0
< before 2,0
< after 2,0
< before 3,0
< before 4,0
< before 0,1
< after 0,1
< before 1,1
< after 1,1
< before 2,1
< after 2,1
< before 3,1
< before 4,1
< before 0,2
< after 0,2
< before 1,2
< after 1,2
< before 2,2
< after 2,2
< before 3,2
< before 4,2
< before 0,3
< after 0,3
< before 1,3
< after 1,3
< before 2,3
< after 2,3
< before 3,3
< before 4,3
< before 0,4
< after 0,4
< before 1,4
< after 1,4
< before 2,4
< after 2,4
< before 3,4
< before 4,4
-
> f = function() { z: print("hej"); z: for (var i = 0; i < 10; ++i) { b: while (true) r: for (var j = 0; j < 10; ++j) { if (j >= 5) break b; print(j) }; print("thonk") } }
> f()
< hej
< 0
< 1
< 2
< 3
< 4
< thonk
< 0
< 1
< 2
< 3
< 4
< thonk
< 0
< 1
< 2
< 3
< 4
< thonk
< 0
< 1
< 2
< 3
< 4
< thonk
< 0
< 1
< 2
< 3
< 4
< thonk
< 0
< 1
< 2
< 3
< 4
< thonk
< 0
< 1
< 2
< 3
< 4
< thonk
< 0
< 1
< 2
< 3
< 4
< thonk
< 0
< 1
< 2
< 3
< 4
< thonk
< 0
< 1
< 2
< 3
< 4
< thonk
-
> { a: { for (var x = 1; x < 10; ++x) for (var y = 1; y < 3; ++y) { print(x); if (x == 5) break a }; print("not here") } }
< 1
< 1
< 2
< 2
< 3
< 3
< 4
< 4
< 5
-
> { x = 0; a: for (var i = 0; i < 10; ++i) { if (++x < 8) continue a; print("iter " + i) } }
< iter 7
< iter 8
< iter 9
-
> 
-
