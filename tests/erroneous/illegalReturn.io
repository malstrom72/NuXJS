// CLI:
> (function f() { eval("return 1") })()
< !!!! SyntaxError: Illegal return
< !!!! location: <anonymous>:1:18
< !!!! stack: SyntaxError: Illegal return
<     at f (<anonymous>:1:18)
<     at <anonymous>:1:38
-
> return 1
< !!!! Line: 1
< !!!! SyntaxError: Illegal return
< !!!! location: <anonymous>
< !!!! stack: SyntaxError: Illegal return
-
