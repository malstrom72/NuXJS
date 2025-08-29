> ctx = { x: 2 };
> function f(a,b){ return this.x + a + b; }
> g = f.bind(ctx, 1);
> print(g(2));
< 5
-
> function h(a,b,c){}
> hb = h.bind(null, 1, 2);
> print(hb.length);
< 1
-
> function C(a){ this.y = a; }
> C.prototype.m = function(){ return this.y * 2; };
> B = C.bind(null, 10);
> o = new B();
> print(o.y);
< 10
>
> print(typeof o.m === 'function');
< true
> print(o instanceof C);
< true
-
> nb = Math.max.bind(null, 1);
> try { new nb(); } catch(e){ print(e instanceof TypeError); }
< true
-
