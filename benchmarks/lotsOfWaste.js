var o = { };
var a = [ ];

(function test1(o, n, c) {
	for (var i = 0; i < n; ++i) o[i] = { "x": i, "y": i }
	for (var i = 0; i < n; ++i) { if ((i % c) != 0) delete o[i]; }
	for (var i = n; i < 2 * n; ++i) o[i] = { "x": i, "y": i }
	for (var i = n; i < 2 * n; ++i) { if ((i % c) != 0) delete o[i]; }
	var count = 0;
	for (var j in o) ++count;
	print(count);
})(o, 200000, 5);

(function test2(a, n) {
	for (var i = 0; i < n; ++i) a[i] = i;
	a.length >>= 2;
	for (var i = 0; i < n; ++i) a[i] = i;
	a.length >>= 1;
	print(a.length);
})(a, 1000000);

(function test3(a, n, n2, c) {
	for (var j = 0; j < n; ++j) {
		var o = { };
		for (var i = 0; i < n2; ++i) o[i] = i;
		for (var i = 0; i < n2; ++i) { if ((i % c) != 0) delete o[i]; }
		for (var i = n2; i < 2 * n2; ++i) o[i] = i;
		for (var i = n2; i < 2 * n2; ++i) { if ((i % c) != 0) delete o[i]; }
		a[j] = o;
	}	
	print(a.length);
})([ ], 40, 20000, 10);
