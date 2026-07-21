// ===== Directive Prologue recognition (ES5.1 14.1) =====
// "use strict" (double quotes) enables strict mode.
> function f() { "use strict"; return this; }
> print(f() === undefined)
< true
-
// 'use strict' (single quotes) is equivalent.
> function f() { 'use strict'; return this; }
> print(f() === undefined)
< true
-
// A directive may have trailing whitespace before the semicolon.
> function f() { "use strict"  ; return this; }
> print(f() === undefined)
< true
-
// ...or a comment before the semicolon.
> function f() { "use strict" /*c*/; return this; }
> print(f() === undefined)
< true
-
// ...or be terminated by an automatic semicolon (a line terminator).
> function f() { "use strict"
>  return this; }
> print(f() === undefined)
< true
-
// The prologue may contain earlier non-use-strict directives.
> function f() { "other directive"; "use strict"; return this; }
> print(f() === undefined)
< true
-
// An x-escape is not allowed even though the value is "use strict".
> function f() { "use\x20strict"; return this; }
> print(f() === this)
< true
-
// A u-escape is not allowed either.
> function f() { "\u0075se strict"; return this; }
> print(f() === this)
< true
-
// Any escape (here a trailing tab) disqualifies the directive.
> function f() { "use strict\t"; return this; }
> print(f() === this)
< true
-
// A parenthesized string is not a StringLiteral directive.
> function f() { ("use strict"); return this; }
> print(f() === this)
< true
-
// Concatenation is a larger expression, not a lone StringLiteral.
> function f() { "use strict" + ""; return this; }
> print(f() === this)
< true
-
// A member access is not a lone StringLiteral.
> function f() { "use strict".length; return this; }
> print(f() === this)
< true
-
// A comma expression is not entirely a StringLiteral.
> function f() { "use strict", "x"; return this; }
> print(f() === this)
< true
-
// A comma expression ends the prologue; a later "use strict" is not a directive.
> function f() { "x", "y"; "use strict"; return this; }
> print(f() === this)
< true
-
// The prologue ends at the first non-string statement.
> function f() { var a; "use strict"; return this; }
> print(f() === this)
< true
-
// An empty statement ends the prologue.
> function f() { ; "use strict"; return this; }
> print(f() === this)
< true
-
// The directive is case-sensitive.
> function f() { "Use Strict"; return this; }
> print(f() === this)
< true
-
// The text must be exactly "use strict".
> function f() { "use  strict"; return this; }
> print(f() === this)
< true
-
// Trailing content in the string disqualifies it.
> function f() { "use strict "; return this; }
> print(f() === this)
< true
-
