> print(Math.abs(-3))
< 3
-
> print(Math.abs(0))
< 0
-
> print(Math.abs(123415))
< 123415
-
> print(Math.acos(0.3).toPrecision(15))
< 1.26610367277950
-
> print(Math.acos(Math.cos(1.0)).toPrecision(15))
< 1.00000000000000
-
> print(Math.asin(-0.5).toPrecision(15))
< -0.523598775598299
-
> print(Math.atan(0.3).toPrecision(15))
< 0.291456794477867
-
> print(Math.atan(-0.3).toPrecision(15))
< -0.291456794477867
-
> print(Math.ceil(0.3))
< 1
-
> print(Math.ceil(-0.3))
< 0
-
> print(Math.ceil(-1234.0))
< -1234
-
> print(Math.cos(Math.PI))
< -1
-
> print(Math.cos(0.5).toPrecision(15))
< 0.877582561890373
-
> print(Math.exp(1.0).toPrecision(15))
< 2.71828182845905
-
> print(Math.exp(-1.0).toPrecision(15))
< 0.367879441171442
-
> print(Math.exp(-0.5).toPrecision(15))
< 0.606530659712633
-
> print(Math.exp("0.5").toPrecision(15))
< 1.64872127070013
-
> print(Math.exp(new Number(0.5)).toPrecision(15))
< 1.64872127070013
-
> print(Math.floor(0.1))
< 0
-
> print(Math.floor(0.0))
< 0
-
> print(Math.floor(-0.3))
< -1
-
> print(Math.log(100).toPrecision(15))
< 4.60517018598809
-
> print(Math.log(-10))
< NaN
-
> print(Math.round(0.4))
< 0
-
> print(Math.round(0.5))
< 1
-
> print(Math.round(1.0))
< 1
-
> print(Math.round(-0.5))
< 0
-
> print(1.0 / Math.round(-0.6))
< -1
-
> print(1.0 / Math.round(-0.4))
< -Infinity
-
> print(1.0 / Math.round(-0.0))
< -Infinity
-
> print(1.0 / Math.round(0.0))
< Infinity
-
> print(Math.round(-0.49))
< 0
-
> print(Math.round(-0.51))
< -1
-
> print(Math.sin(1.0).toPrecision(15))
< 0.841470984807897
-
> print(Math.sin(-1.0).toPrecision(15))
< -0.841470984807897
-
> print(Math.sin(Math.PI).toFixed(15))
< 0.000000000000000
-
> print(Math.sqrt(0.3).toPrecision(15))
< 0.547722557505166
-
> print(Math.sqrt(-0.3))
< NaN
-
> print(Math.sqrt(0))
< 0
-
> print(Math.tan(0.5).toPrecision(14))
< 0.54630248984379
-
> print(Math.tan(0.9).toPrecision(15))
< 1.26015821755034
-
> print(Math.pow(2,8))
< 256
-
> print(Math.pow(3.5,9.3).toPrecision(15))
< 114771.170927641
-
> print(Math.pow(-2.2,0.3))
< NaN
-
> print(Math.pow(-2.2,3).toPrecision(15))
< -10.6480000000000
-
> print(Math.pow(5,-2))
< 0.04
-
> print(Math.atan2(Math.cos(0.3),Math.sin(0.3)).toPrecision(15))
< 1.27079632679490
-
> print(Math.atan2(Math.sin(0.3),Math.cos(0.3)).toPrecision(15))
< 0.300000000000000
-
> print(Math.max());
< -Infinity
-
> print(Math.max(1234));
< 1234
-
> print(Math.max(-505, 1234, 5678, 9090));
< 9090
-
> print(Math.max('12345', '2', 0.5, '-89999', '-9999'));
< 12345
-
> print(Math.max('12345', NaN, 0.5, '-89999', '-9999'));
< NaN
-
> print(Math.min());
< Infinity
-
> print(Math.min(1234));
< 1234
-
> print(Math.min(-505, 1234, 5678, 9090));
< -505
-
> print(Math.min('12345', '2', 0.5, '-89999', '-9999'));
< -89999
-
> print(Math.min('12345', NaN, 0.5, '-89999', '-9999'));
< NaN
-
