for (var j = 0; j < 1000; ++j) {
	var s = '';
	for (var i = 0; i < 1000; ++i) {
		s += String.fromCharCode(i % 26 + 65);
	}
}
print(s);
