> __resetClosureStats();
> var stats = __closureStats();
> print(stats.fastPath === 0 && stats.slowFallbacks === 0);
< true
-
> function capture(value) { return function() { return value; }; }
> var read = capture(123);
> print(read());
< 123
> print(read());
< 123
> stats = __closureStats();
> print(stats.fastPath === 2);
< true
> print(stats.slowFallbacks === 0);
< true
-
> __resetClosureStats();
-
> function captureWith(target) { var foo = "lexical"; with (target) { return function() { return foo; }; } }
> var fallbackTarget = { foo: "outer" };
> var readWith = captureWith(fallbackTarget);
> print(readWith());
< outer
> fallbackTarget.foo = "shadowed";
> print(readWith());
< shadowed
> stats = __closureStats();
> print(stats.fastPath === 0);
< true
> print(stats.slowFallbacks === 2);
< true
-
