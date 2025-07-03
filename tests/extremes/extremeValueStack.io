> function StringBuilder() { var i = 20, b = this.buffers = [ ]; do { b[--i] = ''; } while (i > 0); }
> StringBuilder.prototype.append = function append(s) {
> for (var i = 0, n = 256, b = this.buffers; (b[i] += s).length >= n && i < 20; n <<= 1, ++i) { s = b[i]; b[i] = ''; }
> }
> StringBuilder.prototype.toString = function toString() {
> var i, b, s = (b = this.buffers)[i = 19];
> do { s += b[--i]; } while (i > 0);
> return s;
> }
> function stackOverflowTest(n) {
> var f = function() {
> print(arguments.length - 2);
> print(arguments[0]);
> print(arguments[arguments.length - 1])
> };
> var s = new StringBuilder();
> for (var i = 0; i < n; ++i) s.append('0,');
> s = 'f("first",' + s + '"last");';
> eval(s);
> }
-
> stackOverflowTest(100)
< 100
< first
< last
-
> stackOverflowTest(1000)
< 1000
< first
< last
-
> stackOverflowTest(10000)
! !!!! RangeError: Stack overflow
-
> stackOverflowTest(100000)
! !!!! RangeError: Stack overflow
-
