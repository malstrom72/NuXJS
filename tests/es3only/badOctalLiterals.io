// The leading-zero cases from tests/erroneous/badNumericLiterals.io, which report differently per edition:
// es5 diagnoses 7.8.3 at the literal, es3 lets it lex as two numbers and reports wherever the second one
// lands. Twin: tests/es5/badOctalLiterals.io.
> print(01)
! !!!! Line: 1
! !!!! SyntaxError: Expected ',' or ')'
-
> print(00001)
! !!!! Line: 1
! !!!! SyntaxError: Expected ',' or ')'
-
> print(00001.00000)
! !!!! Line: 1
! !!!! SyntaxError: Expected ',' or ')'
-
> print(00001.00001)
! !!!! Line: 1
! !!!! SyntaxError: Expected ',' or ')'
-
> print(+0001.0001)
! !!!! Line: 1
! !!!! SyntaxError: Expected ',' or ')'
-
> +00X123
! !!!! Line: 1
! !!!! SyntaxError: Syntax error
