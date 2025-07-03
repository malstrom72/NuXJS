function StringBuilder() {
	var i = 20, b = this.buffers = [ ]; do { b[--i] = ''; } while (i > 0);
}

StringBuilder.prototype.append = function append(s) {
	for (var i = 0, n = 256, b = this.buffers; (b[i] += s).length >= n && i < 20; n <<= 1, ++i) { s = b[i]; b[i] = ''; }
}

StringBuilder.prototype.toString = function toString() {
	var i, b, s = (b = this.buffers)[i = 19];
	do { s += b[--i]; } while (i > 0);
	return s;
}

for (var i = 0; i < 10; ++i) (function() {
	var builder = new StringBuilder;
	for (var i = 0; i < 100000; ++i) builder.append('x');
	var s = builder.toString();
	print(s.length);
})();
