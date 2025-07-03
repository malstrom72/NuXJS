> \u0066\u0075\u006c\u0073\u006d\u0075\u0072\u0066\u0065\u006e='fiskpinne'
> print(\u0066\u0075\u006c\u0073\u006d\u0075\u0072\u0066\u0065\u006e)
> print(fulsmurfen)
> print(ful\u0073\u006d\u0075\u0072\u0066\u0065n)
< fiskpinne
< fiskpinne
< fiskpinne
-
> \u0066\u0075\u006c\u0073\u006d\u0030\u0072\u0066\u0033\u006e=\u0066\u0075\u006c\u0073\u006d\u0075\u0072\u0066\u0065\u006e
> print(fulsm0rf3n)
< fiskpinne
-
> \u0030\u0072\u0066\u0033\u006e=\u0066\u0075\u006c\u0073\u006d\u0075\u0072\u0066\u0065\u006e='notok'
! !!!! Line: 1
! !!!! SyntaxError: Illegal Unicode in identifier
-
> fulsmurfe\u2115=fulsmurfen
> print(fulsmurfe\u2115)
< fiskpinne
-
> print(eval('fulsmurfe\u2115'))
< fiskpinne
-
> fulsmurfe\u2116=fulsmurfen
! !!!! Line: 1
! !!!! SyntaxError: Illegal Unicode in identifier
-
> print(eval('fulsmurfe\u2116'))
! !!!! SyntaxError: Syntax error
-
> fulsmurfen=fulsmurfen\u211
! !!!! Line: 1
! !!!! SyntaxError: Syntax error
-
> fulsmurfen=fulsmurfen\x2115
! !!!! Line: 1
! !!!! SyntaxError: Syntax error
-
> fulsmurfen=fulsmurfen\u
! !!!! Line: 1
! !!!! SyntaxError: Syntax error
-
> fulsmurfen=fulsmurfen\u21x5
! !!!! Line: 1
! !!!! SyntaxError: Invalid escape sequence
-
> var p=33;
> print(void\u0070);
! !!!! ReferenceError: voidp is not defined
-
> void\u21x3;
! !!!! Line: 1
! !!!! SyntaxError: Invalid escape sequence
-
> /asdf/\u0067
! !!!! SyntaxError: Invalid regular expression flags
-
> print(eval('/asdf/\u0067') instanceof RegExp)
< true
-
> eval('/asdf/\u2115')
! !!!! SyntaxError: Invalid regular expression flags
-
> /asdf/\u2115
! !!!! SyntaxError: Invalid regular expression flags
-
> /asdf/123
! !!!! SyntaxError: Invalid regular expression flags
-
> var voi\u0064 = 3
! !!!! Line: 1
! !!!! SyntaxError: Illegal use of keyword
-
> voi\u0064:{}
! !!!! Line: 1
! !!!! SyntaxError: Illegal use of keyword
-
> so\u0066\u0066potatis: { while (true) { break soffpotatis; print("no"); }; print("not here either"); }; print("here");
< here
-
> asdf={qwer:123}; print(123 in\u0061sdf)
! !!!! Line: 1
! !!!! SyntaxError: Expected ',' or ')'
