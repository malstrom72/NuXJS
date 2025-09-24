// CLI:
> Object.prototype[1] = -1;
> Object.prototype.length = 2;
> Object.prototype.shift = Array.prototype.shift;
> var x = {0:0,1:1};
> print(x.shift());
< 0
-
> print(x[0]);
< 1
-
> print(x[1]);
< -1
-
> print(x.length);
< 1
-
