> function makeCatchReader(value) {
> 	try {
> 		throw value;
> 	} catch (e) {
> 		return function() { return e; };
> 	}
> }
> var catchReader = makeCatchReader("caught");
> print(catchReader());
< caught
> var anotherCatchReader = makeCatchReader("again");
> print(anotherCatchReader());
< again
