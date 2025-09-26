> __resetClosureStats();
> function makeEvalReader() {
>	var marker = "outer";
>	var reader = function() { return marker; };
>	eval("marker = 'eval';");
>	__resetClosureStats();
>	return reader;
> }
> var evalReader = makeEvalReader();
> print(evalReader());
< eval
> var stats = __closureStats();
> print(stats.fastPath === 0);
< true
> print(stats.slowFallbacks === 1);
< true
