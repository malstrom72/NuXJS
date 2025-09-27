> function captureWith(target) {
> 	var foo = "lexical";
> 	with (target) {
> 		return function() { return foo; };
> 	}
> }
> var fallbackTarget = { foo: "outer" };
> var readWith = captureWith(fallbackTarget);
> print(readWith());
< outer
> fallbackTarget.foo = "shadowed";
> print(readWith());
< shadowed
