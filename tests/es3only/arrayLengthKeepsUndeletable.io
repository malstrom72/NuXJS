// Shrinking length deletes every element it can (ES3 15.4.5.1) but stays above a DontDelete one (15.4.5.2).
> var a = [0, 1, 2, 3]
> Object.defineProperty(a, 1, { value: 1, writable: true, enumerable: true, configurable: false })
> a.length = 0
> var keys = []; for (var k in a) keys.push(k)
> print(a.length + " " + keys + " " + a[0] + " " + a[1])
< 2 1 undefined 1
-
> var b = [0, 1, 2, 3, 4]
> Object.defineProperty(b, 3, { value: 3, writable: true, enumerable: true, configurable: false })
> b.length = 2
> print(b.length + " " + (2 in b) + " " + (3 in b) + " " + (4 in b) + " " + b.join())
< 4 false true false 0,1,,3
-
> var c = []
> c[1000] = 0
> Object.defineProperty(c, 500, { value: 5, writable: true, enumerable: true, configurable: false })
> c[700] = 7
> c.length = 1
> print(c.length + " " + (700 in c) + " " + (1000 in c) + " " + c[500])
< 501 false false 5
-
> var d = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14]
> var fixed = [12, 3, 7]; for (var j = 0; j < fixed.length; ++j) Object.defineProperty(d, fixed[j], { value: fixed[j], writable: true, enumerable: true, configurable: false })
> d.length = 0
> var keys = []; for (var k in d) keys.push(k); keys.sort(function (x, y) { return x - y })
> print(d.length + " " + keys)
< 13 3,7,12
-
