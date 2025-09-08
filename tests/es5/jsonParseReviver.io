> var obj = JSON.parse('{"a":1,"b":2}', function(k, v){ return typeof v === 'number' ? v * 2 : v; });
> print(obj.a + obj.b);
< 6
-
> var obj2 = JSON.parse('{"keep":1,"remove":2}', function(k, v){ return k === 'remove' ? undefined : v; });
> print('remove' in obj2);
< false
> print(obj2.keep);
< 1
-
