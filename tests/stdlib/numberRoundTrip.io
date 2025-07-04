> function ulp(x) {
>     var a = Math.abs(x);
>     if (a === 0) return Math.pow(2, -1074);
>     var e = Math.floor(Math.log(a) / Math.LN2);
>     if (e <= -1022) return Math.pow(2, -1074);
>     return Math.pow(2, e - 52);
> }
> function rt(x) { return Number(x.toString()) === x; }
> var exps = [ -1020, -500, -200, -100, -50, -20, -10, -1, 0, 1, 10, 20, 50, 100, 200, 500, 1020 ];
> var mult = [ 1, -1, 1.2345, -1.2345, 3.141592653589793, -3.141592653589793, 0.1, -0.1 ];
> var vals = [ 0, -0, Math.pow(2, -1074), -Math.pow(2, -1074) ];
> for (var i = 0; i < exps.length; ++i) {
>     var f = Math.pow(2, exps[i]);
>     for (var j = 0; j < mult.length; ++j) {
>         var v = f * mult[j];
>         if (isFinite(v)) vals[vals.length] = v;
>     }
> }
> var ok = true;
> for (var i = 0; i < vals.length && ok; ++i) {
>     var v = vals[i];
>     if (!rt(v)) ok = false;
>     var u = ulp(v);
>     if (isFinite(v + u) && !rt(v + u)) ok = false;
>     if (isFinite(v - u) && !rt(v - u)) ok = false;
> }
> print(ok ? 'roundtrip-ok' : 'roundtrip-fail');
< roundtrip-ok
