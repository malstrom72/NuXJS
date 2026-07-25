> print(1)
< 1
-
> print(1.0)
< 1
-
> print(+1.00001)
< 1.00001
-
> print(-1.0)
< -1
-
> print(-(-1.0))
< 1
-
> print(0.00000)
< 0
-
> print(0.00001)
< 0.00001
-
> print(+1.0001)
< 1.0001
-
> print(-0.00001)
< -0.00001
-
> print(0e+3)
< 0
-
> print(0E+3)
< 0
-
> print(0.)
< 0
-
> print(0.0)
< 0
-
> print(.0)
< 0
-
> print(1.0e+3)
< 1000
-
> print(1.0e+03)
< 1000
-
> print(1.0e+00003)
< 1000
-
> print(1.0e-3)
< 0.001
-
> print(1.0e-0003)
< 0.001
-
> print(1.0e+100)
< 1e+100
-
> print(1.0e-100)
< 1e-100
-
> print(1.0E+100)
< 1e+100
-
> print(+.001)
< 0.001
-
> print(+1234.)
< 1234
-
> print(+0x3e5)
< 997
-
> print(+0x0)
< 0
-
> print(+0X0)
< 0
-
> print(+0X234)
< 564
-
// 7.8.3: DecimalIntegerLiteral is `0` or NonZeroDigit DecimalDigits, and "the SourceCharacter immediately following a
// NumericLiteral must not be a DecimalDigit". An OctalIntegerLiteral (010) is an Annex B extension that is not part
// of the grammar proper, so leading-zero forms are rejected rather than read as octal (or as decimal).
> function shouldFail(s) { try { eval(s); print(s + " should have failed, but didn't"); } catch (e) { print(s + " failed"); } }
-
> shouldFail('010')
< 010 failed
-
> shouldFail('08')
< 08 failed
-
> shouldFail('00')
< 00 failed
-
> shouldFail('0123')
< 0123 failed
-
// A lone 0, and a leading zero that is part of a legal decimal or hex form, are of course still fine.
> print(0); print(0.5); print(0e3); print(0x10)
< 0
< 0.5
< 0
< 16
-
