> function makeEvalReader(value) {
> 	var marker = "outer";
> 	var reader = function() { return marker; };
> 	eval("marker = '" + value + "';");
> 	return reader;
> }
> var evalReader = makeEvalReader("eval");
> print(evalReader());
< eval
> var anotherReader = makeEvalReader("changed");
> print(anotherReader());
< changed
