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
> +00X123
! !!!! Line: 1
! !!!! SyntaxError: Syntax error
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
