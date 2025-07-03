> print(parseFloat(''))
< NaN
-
> print(parseFloat('    '))
< NaN
-
> print(parseFloat('    - '))
< NaN
-
> print(parseFloat('    + '))
< NaN
-
> print(parseFloat('    +e '))
< NaN
-
> print(parseFloat('    +e33 '))
< NaN
-
> print(parseFloat('    +0e '))
< 0
-
> print(parseFloat('    +0e+ '))
< 0
-
> print(parseFloat('    +1 e+33 '))
< 1
-
> print(parseFloat('    0x1234 '))
< 0
-
> print(parseFloat('    1234'))
< 1234
-
> print(parseFloat('    - 1234'))
< NaN
-
> print(parseFloat('    -1234.1234'))
< -1234.1234
-
> print(parseFloat('    -1234.1234e+3'))
< -1234123.4
-
> print(parseFloat('    -1234.1234e+3kokobello'))
< -1234123.4
-
> print(parseFloat('    +1234.1234e+3kokobello'))
< 1234123.4
-
> print(parseFloat({ toString: function() { return "  \n  \t 12345.66789" } }))
< 12345.66789
-
> print(parseFloat('+Infinity'))
< Infinity
-
> print(parseFloat('-Infinity'))
< -Infinity
-
> print(parseFloat('+Infinitymessimal'))
< Infinity
-
> print(parseFloat('-0'))
< 0
-
