seed = 2463534242;
myrand = function() {
	var y = seed;
	y ^= y << 13;
	y ^= y >>> 17;
	y ^=  (y << 5);
	return (seed = y);
};
var memory = [ ];
for (var i = 0; i < 50; ++i) {
	for (var j = 0; j < 20000; ++j) memory[j] = myrand() >>> 0;
}
var f;
var z = -12345;
// startClock = clock();
for (var i = 0; i < 200; ++i) {
	f = 0;
	for (var j = 1; j < 20000; ++j) if (memory[j] < memory[f]) f = j
}
for (var j = 0; j < 20000; j += 2000) print(memory[j]);
print(f);
print(memory[f]);
