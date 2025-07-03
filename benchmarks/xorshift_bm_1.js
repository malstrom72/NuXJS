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
for (var j = 0; j < 100; ++j) {
	for (var i = 0; i < 10000; ++i) {
		prng.nextInt(12345678);
	}
	print(prng.nextInt(12345678));
}
