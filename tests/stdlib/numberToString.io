> print((1234).toString(16))
< 4d2
-
> print((-1234).toString(16))
< -4d2
-
> print((9.238472937428374e+22).toString(16))
< 13902fabc2a30a000000
-
> print((0).toString(16))
< 0
-
> print((1298371928).toString(36))
< lh0m6w
-
> print((505050).toString(2))
< 1111011010011011010
-
> print((293847.293847).toString())
< 293847.293847
-
> try { (423489).toString(1); print("wrong") } catch (x) { print("ok") }
< ok
-
> try { (423489).toString(37); print("wrong") } catch (x) { print("ok") }
< ok
-
> try { (NaN).toString(37); print("ok") } catch (x) { print("wrong") }
< ok
-
> print((1234.5678).toFixed(2))
< 1234.57
-
> print((1234.5678).toFixed(0))
< 1235
-
> print((1234.5678).toFixed(7))
< 1234.5678000
-
> print((1234.9999).toFixed(3))
< 1235.000
-
> print((1234.9999).toFixed())
< 1235
-
> print((-23849.293847).toFixed(4))
< -23849.2938
-
> print((-1e43).toFixed(4))
< -1e+43
-
> print((-99.99).toFixed(1))
< -100.0
-
> print((-99.99).toFixed(10))
< -99.9900000000
-
> print((0.00000000000555).toFixed(5))
< 0.00000
-
> print((0.00000000000555).toFixed(20))
< 0.00000000000555000000
-
> print((0.9999999999999999).toFixed(16))
< 0.9999999999999998
-
> print((NaN).toFixed(1))
< NaN
-
> print((-Infinity).toFixed(2))
< -Infinity
-
> print((1000000000000000128).toFixed())
< 1000000000000000100
-
> print((1e-20).toFixed(20))
< 0.00000000000000000001
-
> print((1e-21).toFixed(20))
< 0.00000000000000000000
-
> print((5e-21).toFixed(20))
< 0.00000000000000000001
-
> try { (423489).toFixed(-1); print("wrong") } catch (x) { print("ok") }
< ok
-
> try { (423489).toFixed(21); print("wrong") } catch (x) { print("ok") }
< ok
-
> try { (NaN).toFixed(21); print("wrong") } catch (x) { print("ok") }
< ok
-
> print((1).toExponential())
< 1e+0
-
> print((0).toExponential())
< 0e+0
-
> print((-1).toExponential())
< -1e+0
-
> print((0).toExponential(10))
< 0.0000000000e+0
-
> print((1234.1234).toExponential(10))
< 1.2341234000e+3
-
> print((1234.1234).toExponential(3))
< 1.234e+3
-
> print((12345.12345).toExponential())
< 1.234512345e+4
-
> print((0.0000001234567).toExponential())
< 1.234567e-7
-
> print((1e300).toExponential())
< 1e+300
-
> print((1e-300).toExponential())
< 1e-300
-
> print((0.5e-322).toExponential())
< 5e-323
-
> print((-100.100).toExponential())
< -1.001e+2
-
> print((-Infinity).toExponential())
< -Infinity
-
> print((NaN).toExponential())
< NaN
-
> print((1.0).toExponential(4))
< 1.0000e+0
-
> print((1.0).toExponential(4.5))
< 1.0000e+0
-
> print((1.0123458948).toExponential())
< 1.0123458948e+0
-
> print((1.0123458948).toExponential(0))
< 1e+0
-
> print((1.0123458948).toExponential(4))
< 1.0123e+0
-
> print((1.0123458948).toExponential(20))
< 1.01234589479999992300e+0
-
> print((1.999).toExponential(2))
< 2.00e+0
-
> print((0.5e-323).toExponential())
< 5e-324
-
> print((1.0e-323).toExponential(2))
< 1.00e-323
-
> print((1.5e-323).toExponential(4))
< 1.5000e-323
-
> print((Number.MIN_VALUE).toExponential(16))
< 5.0000000000000000e-324
-
> print((Number.MAX_VALUE).toExponential(16))
< 1.7976931348623158e+308
-
> try { (423489).toExponential(-1); print("wrong") } catch (x) { print("ok") }
< ok
-
> try { (423489).toExponential(21); print("wrong") } catch (x) { print("ok") }
< ok
-
> try { (NaN).toExponential(21); print("ok") } catch (x) { print("wrong") }
< ok
-
> print((1234.5678).toPrecision())
< 1234.5678
-
> print((1234.5678).toPrecision(3))
< 1.23e+3
-
> print((1234.5678).toPrecision(5))
< 1234.6
-
> print((1234.5678).toPrecision(7))
< 1234.568
-
> print((1234.5678).toPrecision(9))
< 1234.56780
-
> print((1234.5678).toPrecision(8))
< 1234.5678
-
> print((1234.5678).toPrecision(20))
< 1234.5678000000000338
-
> print((1234).toPrecision(10))
< 1234.000000
-
> print((12345).toPrecision(10))
< 12345.00000
-
> print((1234).toPrecision(1))
< 1e+3
-
> print((1.2345e7).toPrecision(5))
< 1.2345e+7
-
> print((1.2345e7).toPrecision(6))
< 1.23450e+7
-
> print((1.2345e7).toPrecision(7))
< 1.234500e+7
-
> print((1.2345e7).toPrecision(8))
< 12345000
-
> print((-1.2345e7).toPrecision(15))
< -12345000.0000000
-
> print((1.2345e19).toPrecision(19))
< 1.234499999999999940e+19
-
> print((1.2345e19).toPrecision(20))
< 12345000000000000000
-
> print((Infinity).toPrecision(21))
< Infinity
-
> print((-Infinity).toPrecision(21))
< -Infinity
-
> print((NaN).toPrecision(21))
< NaN
-
> print((Number.MAX_VALUE).toPrecision(21))
< 1.79769313486231570000e+308
-
> print((Number.MIN_VALUE).toPrecision(21))
< 5.00000000000000000000e-324
-
> try { (423489).toPrecision(0); print("wrong") } catch (x) { print("ok") }
< ok
-
> try { (423489).toPrecision(22); print("wrong") } catch (x) { print("ok") }
< ok
-
> try { (NaN).toPrecision(22); print("ok") } catch (x) { print("wrong") }
< ok
-
> print((9.999999999999998).toExponential(2))
< 1.00e+1
-
> print((9.999999999999998).toPrecision(2))
< 10
-
