> var o = { for:1, while:2, default:3 };
> print(o.for === 1 && o.while === 2 && o.default === 3);
< true
-
> var p = {};
> p.if = 4;
> p['function'] = 5;
> print(p.if === 4 && p['function'] === 5);
< true
-
