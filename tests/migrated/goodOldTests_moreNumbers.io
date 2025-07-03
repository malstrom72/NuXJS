> var x=3
> print(x+9*5 == 48)
> print(0 == 0)
> print(0.0 == 0)
> print(.0 == 0)
> print(0. == 0)
> print(0.e0 == 0)
> print(0.0e0 == 0)
> print(.0e0 == 0)
> print(.0E0 == 0)
> print(.0E+0 == 0)
> print(.0E-0 == 0)
> // print(1.0E-3 == 0.001) // FIX : accuracy problem
> print(1.0E+3 == 1000.0)
> print(0.000000000001 == 0.000000000001)
> print(x == 3)
> print(x == 3.0)
> print(x == 3.0e0)
> // print(x == 0.003e3) // FIX : accuracy problem
> print(!(x == 2.9))
> print(!(x != 3))
> print(!(x != 3.0))
> print(x != 3.1)
> print(!(x < 3))
> print(x < 3.1)
> print(x <= 3)
> print(x <= 3.1)
> print(!(x <= 2.9))
> print(!(x > 3))
> print(x > 2.9)
> print(x >= 3)
> print(!(x >= 3.1))
> print(x >= 2.9)
> print((x == 3 ? 'a' : 'b') == 'a')
> print((x == 3.1 ? 'a' : 'b') == 'b')
> print((x == 3.0 ? (x >= 3.0 ? 'a' : 'b') : 'c') == 'a')
> print((x != 3.0 ? (x >= 3.0 ? 'a' : 'b') : (x > 3.0 ? 'c' : 'd')) == 'd')
< true
< true
< true
< true
< true
< true
< true
< true
< true
< true
< true
< true
< true
< true
< true
< true
< true
< true
< true
< true
< true
< true
< true
< true
< true
< true
< true
< true
< true
< true
< true
< true
< true
< true
-
