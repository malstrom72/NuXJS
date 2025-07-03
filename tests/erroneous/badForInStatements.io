> for (i = 0 in {}; i < 5; ++i) ;
! !!!! Line: 1
! !!!! SyntaxError: Expected ')'
-
> for (var i = 0 in {}; i < 5; ++i) ;
! !!!! Line: 1
! !!!! SyntaxError: Expected ')'
-
> for (var i, j = 0 in {}; i < 5; ++i) ;
! !!!! Line: 1
! !!!! SyntaxError: Expected ';'
-
> for (var i, j = 0 * 3 in {}; i < 5; ++i) ;
! !!!! Line: 1
! !!!! SyntaxError: Expected ';'
-
> for (var i, j = 0 && 3 in {}; i < 5; ++i) ;
! !!!! Line: 1
! !!!! SyntaxError: Expected ';'
-
> for (var i, j = k = 3 in {}; i < 5; ++i) ;
! !!!! Line: 1
! !!!! SyntaxError: Expected ';'
-
> for (var i, j = k ? 1 : 3 in {}; i < 5; ++i) ;
! !!!! Line: 1
! !!!! SyntaxError: Expected ';'
-
