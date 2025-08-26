> total = 0;
> [1, 2, 3].forEach(function(v){ total += v; });
> print(total);
< 6
-
> seen = [];
> arr = [ , 5 ];
> arr.forEach(function(v,i){ seen.push(i); });
> print(seen.length);
< 1
-
> print(seen[0]);
< 1
-
> ctx = { sum: 0 };
> [1,2].forEach(function(v){ this.sum += v; }, ctx);
> print(ctx.sum);
< 3
-
