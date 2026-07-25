// ES5.1 B.1.1 / B.1.2: OctalIntegerLiteral and OctalEscapeSequence are Annex B extensions, and 7.8.3 / 7.8.4 state
// that a conforming implementation must NOT extend the syntax to include them when processing strict mode code.
// NuXJS implements the core grammar only (no Annex B), so octal is rejected in both modes; strict mode additionally
// guarantees it can never be accepted. These are compile-time errors, so they are probed through eval.

// Octal escape sequences are a SyntaxError in strict code.
> try { eval("'use strict'; var s = '\\47';"); print("no throw") } catch (e) { print(e.name) }
< SyntaxError
> try { eval("'use strict'; var s = '\\1';"); print("no throw") } catch (e) { print(e.name) }
< SyntaxError
-

// \0 followed by a decimal digit is an OctalEscapeSequence too, so it is rejected as well.
> try { eval("'use strict'; var s = '\\01';"); print("no throw") } catch (e) { print(e.name) }
< SyntaxError
-

// \8 and \9 are not escapes at all in the core grammar and are rejected the same way.
> try { eval("'use strict'; var s = '\\8';"); print("no throw") } catch (e) { print(e.name) }
< SyntaxError
-

// A lone \0 (NUL) is NOT an octal escape and stays legal in strict mode (7.8.4).
> print(eval("'use strict'; 'a\\0b'.length"))
< 3
> print(eval("'use strict'; 'a\\0b'.charCodeAt(1)"))
< 0
-

// The escape is rejected even when it appears in the directive prologue itself, before "use strict" is seen: the
// whole code unit is strict, so the violation is reported retroactively.
> try { eval("'\\47'; 'use strict'; 1;"); print("no throw") } catch (e) { print(e.name) }
< SyntaxError
-

// Strictness is inherited by a direct eval, so the caller's strictness alone is enough to reject the escape.
> function f() { "use strict"; try { eval("var s = '\\47';"); return "no throw" } catch (e) { return e.name } }
> print(f())
< SyntaxError
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
