> print([1,2,3].reduce(function(a,b){ return a + b; }));
< 6
-
> print([1,2,3].reduce(function(a,b){ return a + b; }, 1));
< 7
-
> print([1,2,3].reduceRight(function(a,b){ return a - b; }));
< 0
-
> print([1,2,3].reduceRight(function(a,b){ return a - b; }, 10));
< 4
-
> calls = 0; arr = [ , 1 ];
> arr.reduce(function(acc, v){ calls++; return acc; }, 0);
> print(calls);
< 1
-
> try { [].reduce(function(){}); } catch(e){ print(e instanceof TypeError); }
< true
-
> try { [].reduceRight(function(){}); } catch(e){ print(e instanceof TypeError); }
< true
-
