function makeAccumulator() {
	var base = 0;
	function configure(step) {
		var offset = step;
		function hit() {
			base += offset;
			base += offset;
			base += offset;
			base += offset;
			return base;
		}
		return hit;
	}
	return configure;
}

var configure = makeAccumulator();
var incOne = configure(1);
var incTwo = configure(2);
var result = 0;

for (var i = 0; i < 500000; ++i) {
	result = incOne() + incTwo();
}

print(result);
