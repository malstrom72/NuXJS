> print(+(''))
< 0
-
> print(+('    '))
< 0
-
> print(+('    - '))
< NaN
-
> print(+('    + '))
< NaN
-
> print(+('    +e '))
< NaN
-
> print(+('    +e33 '))
< NaN
-
> print(+('    +0e '))
< NaN
-
> print(+('    +0e+ '))
< NaN
-
> print(+('    +1 e+33 '))
< NaN
-
> print(+('    0x1234 '))
< 4660
-
> print(+('    0X1234 '))
< 4660
-
> print(+('    -0X1234 '))
< NaN
-
> print(+('    1234'))
< 1234
-
> print(+('    - 1234'))
< NaN
-
> print(+('    -1234.1234'))
< -1234.1234
-
> print(+('    -1234.1234e+3'))
< -1234123.4
-
> print(+('    -1234.1234e+3kokobello'))
< NaN
-
> print(+('    +1234.1234e+3kokobello'))
< NaN
-
> print(+({ toString: function() { return "  \n  \t 12345.66789" } }))
< 12345.66789
-
> print(+('+Infinity'))
< Infinity
-
> print(+('-Infinity'))
< -Infinity
-
> print(+('+Infinitymessimal'))
< NaN
-
> print(+('-0'))
< 0
-
