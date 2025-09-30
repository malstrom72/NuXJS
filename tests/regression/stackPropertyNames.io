try {
	function namedThrower() {
		throw new Error("boom");
	}
	var holder = {};
	holder.method = function() {
		namedThrower();
	};
	holder.helper = function helperNamed() {
		holder.method();
	};
	holder.helper();
} catch (err) {
	var frames = err.stack.split("\n");
	print(frames[1].indexOf("at namedThrower (") >= 0);
	print(frames[2].indexOf("at method (") < 0);
	print(frames[3].indexOf("at helperNamed (") >= 0);
}
