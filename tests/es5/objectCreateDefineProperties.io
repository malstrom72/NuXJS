> p = { t: 3 };
> o = Object.create(p, { x: { value: 1, enumerable: true }, y: { get: function(){ return this.x + this.t; }, enumerable: true } });
> print(o.x);
< 1
> print(o.y);
< 4
> print(Object.getPrototypeOf(o) === p);
< true
-
> o2 = {};
> Object.defineProperties(o2, { a: { value: 1, enumerable: true }, b: { value: 2 } });
> print(Object.keys(o2).join(','));
< a
> o2.a = 7;
> print(o2.a);
< 1
-
