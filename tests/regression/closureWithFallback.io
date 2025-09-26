> __resetClosureStats();
> function makeWithReader(box) {
>	var captured = "outer";
>	var reader = function() { return captured; };
>	with (box) { captured = value; }
>	__resetClosureStats();
>	return reader;
> }
> var withReader = makeWithReader({ value: "with" });
> print(withReader());
< with
> var stats = __closureStats();
> print(stats.fastPath === 0);
< true
> print(stats.slowFallbacks === 1);
< true
