> var obj = {}, v = 1;
> Object.defineProperty(obj, 'a', { get: function(){ return v; }, set: function(x){ v = x; }, enumerable: true, configurable: true });
> print(obj.a);
< 1
> try { Object.defineProperty({}, 'b', { value: 1, get: function(){} }); } catch (e) { print(e instanceof TypeError); }
< true
