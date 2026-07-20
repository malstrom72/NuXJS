> // All scenarios inside one eval'd source to keep accurate line/columns
> var SRC = '' +
> '// A: direct throw\n' +
> 'try { throw new Error("E_direct"); } catch (err) {\n' +
> 'print(err.stack);\n}' +
> '\n\n// B: named function\n' +
> 'function f_named() { throw new Error("E_named"); }\n' +
> 'try { f_named(); } catch (err) {\n' +
> 'print(err.stack);\n}' +
> '\n\n// C: IIFE (anonymous function)\n' +
> 'try { (function(){ throw new Error("E_iife"); })(); } catch (err) {\n' +
> 'print(err.stack);\n}' +
> '\n\n// D: named function expression\n' +
> 'var f_expr = function namedExpr() { throw new Error("E_namedExpr"); };\n' +
> 'try { f_expr(); } catch (err) {\n' +
> 'print(err.stack);\n}' +
> '\n\n// E: direct eval\n' +
> 'try { eval("throw new Error(\\\"E_eval\\\")"); } catch (err) {\n' +
> 'print(err.stack);\n}' +
> // H (TypeError from a non-callable method call) lives in tests/es3only and tests/es5,
> // because ES5 11.2.3 fetches the callee before the arguments, moving the reported column.
> '';
> eval(SRC);
> // throw to force this file to only work under -e option
> throw "done"
< Error: E_direct
<     at <eval>:2:34
<     at <anonymous>:23:10
< Error: E_named
<     at f_named (<eval>:7:48)
<     at <eval>:8:16
<     at <anonymous>:23:10
< Error: E_iife
<     at <eval>:13:45
<     at <eval>:13:51
<     at <anonymous>:23:10
< Error: E_namedExpr
<     at namedExpr (<eval>:18:67)
<     at <eval>:19:15
<     at <anonymous>:23:10
< Error: E_eval
<     at <eval>:1:26
<     at <eval>:24:42
<     at <anonymous>:23:10
! !!!! done
-
