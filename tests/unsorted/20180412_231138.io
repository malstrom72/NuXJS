// CLI:
> for (var i='x' in {},j=3) { }
-
> for (var i=('x' in {}),j=3) { }
< !!!! Line: 1
< !!!! SyntaxError: Expected ';'
< !!!! location: <anonymous>
< !!!! stack: SyntaxError: Expected ';'
-
> for (var i=('x' in {}),j=3;j<5;++j) { }
-
> for (var i,j=3; j<5; ++j) { }
-
> for (i in []) { }
-
> for (var i in []) { }
-
