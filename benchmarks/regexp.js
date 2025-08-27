var lotsOfStrings = [ ];

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

	this.nextInt32 = function() {
		next();
		return py >>> 0;
	};

	this.nextFloat = function() {
		next();
		return (py >>> 0) * 2.3283064365386962890625e-10 +
				(((px & 0xFFFFF800) >>> 0) * 5.42101086242752217003726400434970855712890625e-20);
	};

	this.nextInt = function(max) {
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

	this.getState = function() { return [ px, py ]; }
	this.setState = function(state) { px = state[0]; py = state[1]; }
	this.clone = function() { return new XorshiftPRNG2x32(px, py); };
}

var prng = new XorshiftPRNG2x32();
var strings = [ ];
for (var j = 0; j < 10000; ++j) {
	var s = '';
	if (prng.nextInt(127) === 0) {
		s = new StringBuilder();
		for (i = prng.nextInt(1024); i >= 0; --i) {
			s.append(String.fromCharCode(32 + prng.nextInt(127 - 32)));
		}
		s = s.toString();
		s += s;
		s += s;
		s += s;
		s += 'submatchthis';
		s += s;
		s += s;
	} else {
		for (i = prng.nextInt(23); i >= 0; --i) {
			s += String.fromCharCode(32 + prng.nextInt(127 - 32));
		}
	}
	strings[j] = s;
}
print("built 10000 strings")

function reTest(re) {
	var n = 0;
	for (var i = 0; i < strings.length; ++i) {
		n += (strings[i].match(re) !== null);
	}
	print(re + ": " + n);
}

reTest(/submatchthis/)
reTest(/^((?=\S*?[A-Z])(?=\S*?[a-z])(?=\S*?[0-9]).{6,})\S$/) // password validation from regexp101.com by christian klemp
reTest(/^(?=.*\d)(?=.*[a-z])(?=.*[A-Z])(?=.*[#$%\/()=?*+-])(?=(?:([\w\d])\1?(?!\1\1)))(?!(?=.*(palabra1|palabra2|palabraN))).{8,20}$/)
