> try {
> 	var holder = {};
> 	holder.method = function() {
> 		throw new Error("boom");
> 	};
> 	holder.method();
> } catch (err) {
> 	var frames = err.stack.split("\n");
> 	print(frames[1].indexOf("at method (") >= 0);
> }
< true
