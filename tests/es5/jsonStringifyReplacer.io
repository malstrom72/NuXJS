> var obj = { a: 1, b: 2 };
> print(JSON.stringify(obj, ['b', 'a'], 2));
< {
<   "b": 2,
<   "a": 1
< }
-
> var s = JSON.stringify(obj, function(k, v){ return typeof v === 'number' ? v * 2 : v; });
> print(JSON.parse(s).a + JSON.parse(s).b);
< 6
-
