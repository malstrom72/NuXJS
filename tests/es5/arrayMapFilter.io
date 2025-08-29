> res = [1,2,3].map(function(v){ return v*2; });
> print(res.join(','));
< 2,4,6
-
> ctx = { add: 1 };
> res = [1,2].map(function(v){ return v + this.add; }, ctx);
> print(res[1]);
< 3
-
> src = [ , 5 ];
> res = src.map(function(v){ return v; });
> print(0 in res);
< false
-
> filtered = [1,2,3,4].filter(function(v){ return v % 2 === 0; });
> print(filtered.join(','));
< 2,4
-
> ctx = { max:2 };
> filtered = [1,2,3].filter(function(v){ return v > this.max; }, ctx);
> print(filtered[0]);
< 3
-
> src = [ ,1,2 ];
> filtered = src.filter(function(v){ return true; });
> print(filtered.length);
< 2
-
