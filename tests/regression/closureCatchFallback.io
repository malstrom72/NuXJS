> __resetClosureStats();
> function makeCatchReader(value) {
>	var captured = "outer";
>	try {
>		throw value;
>	} catch (e) {
>		captured = e;
>	}
>	__resetClosureStats();
>	return function() { return captured; };
> }
> var catchReader = makeCatchReader("caught");
> print(catchReader());
< caught
> var stats = __closureStats();
> print(stats.fastPath === 0);
< true
> print(stats.slowFallbacks === 1);
< true
