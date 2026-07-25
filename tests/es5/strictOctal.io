// ES5.1 7.8.3 / 7.8.4 make it normative that "a conforming implementation, when processing strict mode code, may not
// extend the syntax of NumericLiteral to include OctalIntegerLiteral / of EscapeSequence to include
// OctalEscapeSequence as described in B.1.1 / B.1.2".
//
// NuXJS never extends the grammar with Annex B octal in the first place, so it satisfies this a fortiori: octal is a
// SyntaxError in BOTH modes, enforced by the shared lexer (see tests/conforming/stringLiterals.io and
// tests/conforming/numericLiterals.io, which cover the non-strict half). These cases guard that the normative strict
// requirement specifically keeps holding — notably if Annex B octal were ever added for web compatibility, strict
// code would still have to reject it. They are compile-time errors, so they are probed through eval.
// Octal escape sequences are a SyntaxError in strict code.
> try { eval("'use strict'; var s = '\\47';"); print("no throw") } catch (e) { print(e.name) }
< SyntaxError
> try { eval("'use strict'; var s = '\\1';"); print("no throw") } catch (e) { print(e.name) }
< SyntaxError
-
// \0 followed by a decimal digit would be an OctalEscapeSequence, so it is rejected as well.
> try { eval("'use strict'; var s = '\\01';"); print("no throw") } catch (e) { print(e.name) }
< SyntaxError
-
// \8 and \9 are not escapes at all (DecimalDigit is excluded from NonEscapeCharacter) and are rejected the same way.
> try { eval("'use strict'; var s = '\\8';"); print("no throw") } catch (e) { print(e.name) }
< SyntaxError
-
// A lone \0 (NUL) is NOT an octal escape and stays legal in strict mode (7.8.4).
> print(eval("'use strict'; 'a\\0b'.length"))
< 3
> print(eval("'use strict'; 'a\\0b'.charCodeAt(1)"))
< 0
-
// Octal integer literals are a SyntaxError in strict code.
> try { eval("'use strict'; var n = 010;"); print("no throw") } catch (e) { print(e.name) }
< SyntaxError
> try { eval("'use strict'; var n = 08;"); print("no throw") } catch (e) { print(e.name) }
< SyntaxError
-
// A plain 0, and decimals that merely start with a digit, are of course still fine.
> print(eval("'use strict'; 0")); print(eval("'use strict'; 10")); print(eval("'use strict'; 0.5"))
< 0
< 10
< 0.5
-
