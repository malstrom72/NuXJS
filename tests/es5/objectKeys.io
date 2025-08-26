> print(Object.keys({a:1,b:2}).sort().join(','));
< a,b
-
> function F(){}
> F.prototype.a = 1;
> var o = new F();
> o.b = 2;
> print(Object.keys(o).join(','));
< b
-
> var obj = {};
> Object.defineProperty(obj, 'x', { value:1, enumerable:false });
> obj.y = 2;
> print(Object.keys(obj).join(','));
< y
-
> print(Object.keys('hi').length);
< 2
-
> try { Object.keys(null); } catch(e){ print(e instanceof TypeError); }
< true
-
