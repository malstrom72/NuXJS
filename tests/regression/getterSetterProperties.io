> obj = { _v: 1, get value() { return this._v; }, set value(v) { this._v = v; }, get double() { return this._v * 2; }, set double(v) { this._v = v / 2; } };
-
> print(obj.value);
< 1
-
> print(obj.double);
< 2
-
> obj.double = 50;
-
> print(obj.value);
< 25
-
> obj.value = 15;
-
> print(obj.double);
< 30
-
> print(obj._v);
< 15
-
