// ES3 7.8.3 and 9.3.1 give the ExponentPart an unbounded integer MV, and 8.5 rounds the result to the nearest
// Number, replacing 2^1024 with Infinity. An exponent past a few hundred must therefore give Infinity or zero,
// never a value wrapped mod 2^32. Found by the libFuzzer campaign on 2026-10-05.
> print(String(1e2147483648))
< Infinity
-
> print(String(10e2147483647))
< Infinity
-
> print(String(1e4294967296))
< Infinity
-
> print(String(1e4294967297))
< Infinity
-
> print(String(1e-4294967297))
< 0
-
> print(String(1e99999999999))
< Infinity
-
> print(String(1e-2147483648))
< 0
-
> print(String(1e4294967396))
< Infinity
-
> print(String(1e8589934592))
< Infinity
-
// 9.3.1: the same MV rules apply to ToNumber on a string, so the string path needs its own cases.
> print(String(+"1e2147483648"))
< Infinity
-
> print(String(+"1e4294967296"))
< Infinity
-
> print(String(+"1e-4294967297"))
< 0
-
> print(String(Number("1e99999999999")))
< Infinity
-
> print(String(parseFloat("1e4294967296")))
< Infinity
-
// ES3 9.5 ToInt32 step 4 takes the modulo of the SIGNED value, yielding a positive int32bit, and step 5 maps
// anything from 2^31 upward to int32bit - 2^32. 6442450944 is 2^32 + 2^31, so these land exactly on 2^31.
> print(String((-6442450944)|0))
< -2147483648
-
> print(String((6442450944)|0))
< -2147483648
-
> print(String(-6442450944 >>> 0))
< 2147483648
-
> print(String((4294967296)|0))
< 0
-
> print(String((2147483648)|0))
< -2147483648
-
> print(String((-2147483648)|0))
< -2147483648
-
> print(String((1e21)|0))
< -559939584
-
