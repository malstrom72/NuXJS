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
// The double is exactly 0.99999999999999988897769753748434595763683319091796875, so the 17th fraction digit is 8
// and 15.7.4.5 step 10 rounds the 16th up. The old expectation here was the truncation the double-arithmetic
// implementation produced. Verified against V8.
> print((0.9999999999999999).toFixed(16))
< 0.9999999999999999
-
> print((NaN).toFixed(1))
< NaN
-
> print((-Infinity).toFixed(2))
< -Infinity
-
// 9.8.1 ToString gives the SHORTEST round-tripping form, "1000000000000000100", but 15.7.4.5 step 11 asks for the
// exact digits of n, and this double is exactly 1000000000000000128. Going through ToString is what lost them.
> print((1000000000000000128).toFixed())
< 1000000000000000128
-
> print((1e-20).toFixed(20))
< 0.00000000000000000001
-
> print((1e-21).toFixed(20))
< 0.00000000000000000000
-
// Looks like an exact tie that step 10 would round up, and is not: the double nearest 5e-21 is
// 4.99999999999999972576...e-21, so val * 10^20 is 0.49999... and rounds DOWN. This is the boundary of the
// "too small to matter" guard in toFixed, so it is the case that catches the guard being written as > instead of >=.
> print((5e-21).toFixed(20))
< 0.00000000000000000000
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
// The exact double is 1.01234589479999992356340499100..., so digit 21 is 3 and the 20th stands. The old
// expectations in this block were all produced by the double-arithmetic significand and are all wrong.
> print((1.0123458948).toExponential(20))
< 1.01234589479999992356e+0
-
> print((1.999).toExponential(2))
< 2.00e+0
-
> print((0.5e-323).toExponential())
< 5e-324
-
// Denormals are where the old code was furthest out: the double nearest 1e-323 is really 9.8813129168...e-324.
> print((1.0e-323).toExponential(2))
< 9.88e-324
-
> print((1.5e-323).toExponential(4))
< 1.4822e-323
-
> print((Number.MIN_VALUE).toExponential(16))
< 4.9406564584124654e-324
-
> print((Number.MAX_VALUE).toExponential(16))
< 1.7976931348623157e+308
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
// 1.2345e19 is exactly 12345000000000000000, so 19 significant digits are exact and none of them are 9s.
> print((1.2345e19).toPrecision(19))
< 1.234500000000000000e+19
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
< 1.79769313486231570815e+308
-
> print((Number.MIN_VALUE).toPrecision(21))
< 4.94065645841246544177e-324
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
// 15.7.4.5 step 10 rounds on the double's EXACT value, not on its shortest decimal form, and these are the cases
// that made the difference reach ordinary code rather than only huge integers: 0.35 is really 0.34999999999999997779
// so it rounds DOWN, and 1.45 is 1.44999999999999995559. Step 10 also says ties pick the LARGER n, which is
// round-half-up on the magnitude and not banker's rounding, so .5 .5 .5 go up and the sign is applied afterwards.
// All verified against V8.
> print((0.35).toFixed(1))
< 0.3
-
> print((1.45).toFixed(1))
< 1.4
-
> print((8.005).toFixed(2))
< 8.01
-
> print((0.5).toFixed(0) + " " + (1.5).toFixed(0) + " " + (2.5).toFixed(0))
< 1 2 3
-
> print((-0.5).toFixed(0) + " " + (-2.5).toFixed(0))
< -1 -3
-
> print((0.1).toFixed(20))
< 0.10000000000000000555
-
// 15.7.4.6 and 15.7.4.7 round on the exact expansion too, the same way 15.7.4.5 does, so the cases that caught
// toFixed catch these: 0.35 is 0.34999999999999997779 and 1.45 is 1.44999999999999995559. Verified against V8.
> print((0.35).toExponential(1) + " " + (1.45).toExponential(1))
< 3.5e-1 1.4e+0
-
> print((0.35).toPrecision(1) + " " + (1.45).toPrecision(2))
< 0.3 1.4
-
> print((0.1).toExponential(20))
< 1.00000000000000005551e-1
-
// The large-integer case, where 9.8.1 ToString cannot carry the low digits by definition.
> print((1000000000000000128).toExponential(20))
< 1.00000000000000012800e+18
-
> print((1000000000000000128).toPrecision(21))
< 1000000000000000128.00
-
// With fractionDigits absent 15.7.4.6 wants "f as small as possible", which is exactly ToString's digits, so the
// two must agree. They did not before: this answered 3.4999999999999996e-1 while String(0.35) was "0.35".
> print((0.35).toExponential() + " " + String(0.35))
< 3.5e-1 0.35
-
// 15.7.4.7 step 2 with precision undefined is ToString, so it must return the SAME string, not just the same value.
> print((1234.5678).toPrecision() === String(1234.5678))
< true
-
// Both return a String throughout, including for the non-finite receivers that skip the digit machinery.
> print(typeof (NaN).toExponential() + " " + typeof (1).toPrecision() + " " + typeof (Infinity).toPrecision(5))
< string string string
-
// Rounding that carries all the way up has to grow the exponent and drop the spare digit.
> print((9.995).toPrecision(3) + " " + (9.999999999999998).toExponential(2))
< 9.99 1.00e+1
-
// Nothing in stdlib.js may call a method off a user-reachable prototype, because user code can replace it. These
// formatters used to go through String.prototype.indexOf and Array.prototype.slice, which made toExponential()
// answer "1.234.5678e+8" and toFixed(1) answer "0.1" once those were hijacked.
> String.prototype[0] = "Z"; String.prototype[1] = "Z"; String.prototype[4] = "Z";
> String.prototype.indexOf = function () { return -1 };
> Array.prototype.slice = function () { return [] };
> String.prototype.charAt = function () { return "!" };
> Array.prototype.join = function () { return "!" };
> print((1234.5678).toExponential() + " " + (1234.5678).toPrecision() + " " + (1234.5678).toFixed(1));
< 1.2345678e+3 1234.5678 1234.6
-
