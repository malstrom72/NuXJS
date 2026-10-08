# Number Conversion

How NuXJS converts between decimal text and doubles in both directions: ToNumber applied to strings and numeric
literals (9.3.1 and 7.8.3), and ToString applied to numbers (9.8.1). The code is the conversion section of
`src/NuXJS.cpp`, from `Words` through `shortestDigits`, used by `parseDouble` and `doubleToString`. The design is
ported from Numbstrict, whose `docs/RealConversion.md` carries the full number theory; this document holds what NuXJS
needs to maintain its own copy.

## What the specification requires

Parsing must give "the Number value for" the mathematical value (8.5): the nearest double, and on an exact tie the one
with the even significand. Above 20 significant digits 9.3.1 permits either of two answers, the value with every digit
after the 20th replaced by 0, or that value incremented at the 20th digit. NuXJS always takes the first, so it never
reads more than 20 digits.

Printing must give the fewest digits that read back as the value, and among those the one closest to it (9.8.1). When
the value lies exactly halfway between the two closest candidates, the last digit "is not necessarily uniquely
determined", and a non-normative NOTE recommends the even one. NuXJS follows the NOTE, as V8 does, so the two print
identical text.

## The one approximation

`Words<N>` is an unsigned integer of N 32-bit words, least significant word first, with only the operations the
conversions need: multiply-add by a small factor, add, subtract, compare, shift, bit length and a full product.

`PowerOfFiveTable` holds 5^q for q in -343..343 as a 128-bit significand P in [2^127, 2^128) and a binary exponent e,
with 5^q = (P + f) * 2^e and 0 <= f < 1. Negative q hold 1 / 5^-q the same way. P is truncated and never rounded, so
the true power is never below it, and every decision below relies on that. The table is built once at static
initialization: positive powers by repeated multiplication by five, keeping the top 128 bits, and reciprocals as
floor(2^(L + 127) / 5^k) by long division, with L the bit length of 5^k. Entries up to 5^55 are exact.

For a decimal significand w below 10^20, which fits in 67 bits, the product x = w * P is formed exactly, and the exact
scaled value lies in [x, x + w). Relative to x that interval is narrower than 2^-127.

## Why that interval is enough

Two facts from number theory, established in Numbstrict's analysis by a continued-fraction search over every decimal
exponent and every binade:

1. A decimal of at most 20 significant digits is never within 2^-125.39, relatively, of a binary64 rounding midpoint
   unless it lies exactly on one. The closest case is `82628059879762389505e54`.
2. A decimal of at most 18 significant digits is never within 2^-124 of a double unless it equals it.

So the interval [x, x + w) lies wholly below every midpoint, wholly above it, or holds exactly one, and in that last
case the input is an exact tie. Each decision is therefore exact although the table is not.

## The decision primitive

`splitAtBit(x, delta, position, half)` takes an exact value known to lie in [x, x + delta), with delta below
2^(position - 1). It returns the integer part above bit `position`, and in `half` whether the rest lies below (-1),
exactly on (0) or above (1) one half. If the interval reaches the next integer, the value is that integer, since
nothing of that length can lie so close to an integer without being one; the integer part is then one higher and
`half` is -1. Both directions are built on this one function.

## Parsing

`parseDouble` keeps the existing front end (signs, `Infinity`, the grammar, the decimal exponent of the leading digit)
and reads at most 20 significant digits exactly into a `Words<3>`. A leading exponent below -324 gives 0, and one above
308 gives infinity, before any of the following.

`convertDecimal(w, q)` forms x = w * P(q), places the result's least significant bit at
position = max(bitLength(x) - 53, -1074 - scale) with scale = q + e(q), and rounds the mantissa that `splitAtBit`
returns: up when the rest is above half, and on an exact half up only if the mantissa is odd, which is round half to
even. The result is put together with `ldexp(mantissa, position + scale)` rather than from its bits, so no layout of a
double is assumed, and a mantissa that carries to 2^53, a subnormal result and a magnitude past the largest finite
double all come out right by themselves.

## Printing

`decompose` takes the value apart with `frexp` into an exact 53-bit mantissa and a binary exponent. `scaledFloor`
gives floor(v * 10^j) and its half comparison from the same product and `splitAtBit`.

`shortestDigits` estimates the decimal exponent k of the leading digit as floor(e * 1233 / 4096) from the binary
exponent, which is off by at most one, and corrects it from the first digit. It then binary searches the digit count n
from 1 to 17, since "some n-digit decimal reads back as v" is monotone in n. Each probe forms the truncation
F = floor(v * 10^(n-1-k)) and checks F and F + 1 by converting them back with `convertDecimal`; the smallest n with a
survivor wins. When both survive, the closer one is taken, and on an exact half the even one. Two details:

- The largest finite double never takes the upper candidate, so its text stays below the overflow threshold for
  parsers that read anything above it as infinity.
- A carry, F + 1 = 10^n, can only survive at n = 1, and is normalized afterwards from 10 to 1 with the exponent raised
  by one.

`doubleToString` lays the digits out as 9.8.1 requires: decimal notation for leading exponents from -6 to 20,
exponential notation outside that, and no trailing `.0`.

## The floating-point environment

Everything above is integer arithmetic until the final `ldexp`, so the rounding mode does not change a single result;
that was measured identical under all four modes. Flush-to-zero and denormals-are-zero still act on that `ldexp`, so a
subnormal result becomes 0 there. `NuXJS Documentation.md` states what the engine as a whole expects of the
environment.

## Testing a change to this code

`tests/conforming/decimalConversion.io` pins a sample of hard inputs as exact `mantissa * 2^exponent` identities, the
range edges, the 9.8.1 layout thresholds and both directions of the tie rule. A change here needs more than that, and
two traps make a passing check worthless:

- **Random inputs do not discriminate.** Random decimals almost never land near a rounding midpoint: 200,000 random
  decimals of 1 to 20 digits pass on the old double-double parser too, and so do exact midpoints truncated to 20
  digits, which still leaves them 2^-63 away. Only inputs constructed within about 2^-125 of a midpoint, such as those
  from Numbstrict's residue-class generator, tell a correct conversion from a nearly correct one. Validate any new
  check against a known broken build before trusting it.
- **Never let the engine under test compute an expected value.** An expectation built as `mantissa * 2^exponent` is
  exact and safe even on a broken build, but its printed form goes through the formatter under test. Compare values,
  not strings, against an oracle in exact arithmetic, never against another engine.

The measurements behind the rewrite, and the defects it fixed, are in `docs/notes/Todo.md`.
