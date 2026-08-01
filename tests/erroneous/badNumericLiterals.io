// The leading-zero cases (01, 00001, +00X123 and friends) live in the tests/es3only/ and tests/es5/
// badOctalLiterals.io twins instead, because es5 diagnoses 7.8.3 at the literal itself.
> +.
! !!!! Line: 1
! !!!! SyntaxError: Missing / invalid expression
-
> +e
! !!!! ReferenceError: e is not defined
-
> +e+
! !!!! Line: 1
! !!!! SyntaxError: Missing / invalid expression
-
> +e103
! !!!! ReferenceError: e103 is not defined
-
> +1e+
! !!!! Line: 1
! !!!! SyntaxError: Missing / invalid expression
-
> +1e
! !!!! Line: 1
! !!!! SyntaxError: Missing / invalid expression
-
> +1e +3
! !!!! Line: 1
! !!!! SyntaxError: Missing / invalid expression
-
> +1e+ 3
! !!!! Line: 1
! !!!! SyntaxError: Missing / invalid expression
-
> +1e+3.5
! !!!! Line: 1
! !!!! SyntaxError: Expected identifier
-
> +1e+0x3
! !!!! Line: 1
! !!!! SyntaxError: Missing / invalid expression
-
> print(--1.0)
! !!!! Line: 1
! !!!! ReferenceError: Illegal l-value
-
> 1false
! !!!! Line: 1
! !!!! SyntaxError: Syntax error
-
> 1in[]
! !!!! Line: 1
! !!!! SyntaxError: Syntax error
-
> 1.in[]
! !!!! Line: 1
! !!!! SyntaxError: Syntax error
-
> 0in[]
! !!!! Line: 1
! !!!! SyntaxError: Syntax error
-
> 1e0in[]
! !!!! Line: 1
! !!!! SyntaxError: Syntax error
-
