> print([1,2,3].some(function(v){ return v > 2; }));
< true
-
> print([1,2,3].some(function(v){ return v > 5; }));
< false
-
> print([1,2,3].every(function(v){ return v < 4; }));
< true
-
> print([1,2,3].every(function(v){ return v < 3; }));
< false
-
> ctx = { t:2 };
> print([1,2,3].some(function(v){ return v > this.t; }, ctx));
< true
-
> calls = 0; arr = [ , 1 ];
> arr.every(function(v,i){ calls++; return true; });
> print(calls);
< 1
-
