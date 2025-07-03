> catch: while (false) { }
! !!!! Line: 1
! !!!! SyntaxError: Illegal use of keyword
-
> super: { while (false) { break super; } }
! !!!! Line: 1
! !!!! SyntaxError: Illegal use of keyword
-
> function super() { }
! !!!! Line: 1
! !!!! SyntaxError: Illegal use of keyword
-
> export: { while (false) { break export; } }
! !!!! Line: 1
! !!!! SyntaxError: Illegal use of keyword
-
> function function() { }
! !!!! Line: 1
! !!!! SyntaxError: Illegal use of keyword
-
> var while = 3;
! !!!! Line: 1
! !!!! SyntaxError: Illegal use of keyword
-
> function test(enum) { }
! !!!! Line: 1
! !!!! SyntaxError: Illegal use of keyword
-
> extends += 5
! !!!! Line: 1
! !!!! SyntaxError: Illegal use of keyword
-
> { while (true) { break debugger; } }
! !!!! Line: 1
! !!!! SyntaxError: Illegal use of keyword
-
> { while (false) { continue typeof; } }
! !!!! Line: 1
! !!!! SyntaxError: Illegal use of keyword
-
> print({ enum: "ok", class: "alsoOk" }.enum)
< ok
-
> ok   :  while ( false )  {  break    ok }
-
