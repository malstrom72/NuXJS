function $StringBuilder() {
	var i = 20,
		b = (this.buffers = []);
	do {
		b[--i] = "";
	} while (i > 0);
}
$StringBuilder.prototype.append = function append(s) {
	for (var i = 0, n = 256, b = this.buffers; (b[i] += s).length >= n && i < 20; n <<= 1, ++i) {
		s = b[i];
		b[i] = "";
	}
};
$StringBuilder.prototype.toString = function toString() {
	var i,
		b,
		s = (b = this.buffers)[(i = 19)];
	do {
		s += b[--i];
	} while (i > 0);
	return s;
};

var s = new $StringBuilder();
s.append("a");
var t = "";
for (i = 0; i < 512; ++i) t += "b";
s.append(t);
s.append("c");
print("" + s);

function XorshiftPRNG2x32(seed0, seed1) {
	if (seed0 == null) seed0 = 123456789;
	if (seed1 == null) seed1 = 362436069;

	var px = seed0;
	var py = seed1;

	function next() {
		var t = px ^ (px << 10);
		px = py;
		py = py ^ (py >>> 13) ^ t ^ (t >>> 10);
	}

	this.nextInt32 = function () {
		next();
		return py >>> 0;
	};

	this.nextFloat = function () {
		next();
		return (py >>> 0) * 2.3283064365386962890625e-10 + ((px & 0xfffff800) >>> 0) * 5.42101086242752217003726400434970855712890625e-20;
	};

	this.nextInt = function (max) {
		var mask = max;
		mask |= mask >>> 1;
		mask |= mask >>> 2;
		mask |= mask >>> 4;
		mask |= mask >>> 8;
		mask |= mask >>> 16;
		mask |= mask >>> 32;

		var v;
		do {
			next();
			v = (py >>> 0) & mask;
		} while (v > max);

		return v;
	};

	this.getState = function () {
		return [px, py];
	};
	this.setState = function (state) {
		px = state[0];
		py = state[1];
	};
	this.clone = function () {
		return new XorshiftPRNG2x32(px, py);
	};
}

var prng = new XorshiftPRNG2x32();
var strings = [];
var ok = true;
for (var j = 0; j < 100; ++j) {
	var s = "";
	var sb = new $StringBuilder();
	for (i = prng.nextInt(23) << prng.nextInt(13); i >= 0; --i) {
		var c = String.fromCharCode(65 + prng.nextInt(25));
		s += c;
		sb.append(c);
	}
	strings[j] = sb.toString();
	var same = s === strings[j];
	print("#" + j + " " + s.length + ": " + same);
	ok = ok && same;
}

for (var j = 0; j < 1000; ++j) {
	var s = "";
	var sb = new $StringBuilder();
	for (i = prng.nextInt(8); i >= 0; --i) {
		var c = strings[prng.nextInt(100)];
		s += c;
		sb.append(c);
	}
	var same = s === sb.toString();
	print("#" + j + " " + s.length + ": " + same);
	ok = ok && same;
}

if (!ok) {
	throw Error("ONE OR MORE FAILS");
} else {
	print("ALL OK");
}
