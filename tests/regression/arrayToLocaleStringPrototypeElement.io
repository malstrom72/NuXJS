> var n = 0;
> var obj = {toLocaleString:function(){n++;return 'obj';}};
> Array.prototype[1] = obj;
> var x = [obj];
> x.length = 2;
> x.toLocaleString();
> print(n);
< 2
-
