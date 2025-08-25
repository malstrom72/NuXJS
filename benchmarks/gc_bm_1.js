// Not finished, was going to do heavy graphs to test gc
var o = function() { }
var a = new o;
for (var i = 0; i < 10000; ++i) {
	a[i] = new o;
	for (var j = 0; j < 100; ++j) {
		a[i][j] = new o;
	}
}
var ok = (a[0][0] instanceof o) && (a[9999][99] instanceof o);
print(ok ? 1 : 0);
