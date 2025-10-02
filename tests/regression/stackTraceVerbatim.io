> // All scenarios inside one eval'd source to keep accurate line/columns
> var SRC = '' +
> '// A: direct throw\n' +
> 'try { throw new Error("E_direct"); } catch (err) {\n' +
> 'print(err.stack);\nprint(err.fileName);\nprint(err.lineNumber);\nprint(err.columnNumber);\n}' +
> '\n\n// B: named function\n' +
> 'function f_named() { throw new Error("E_named"); }\n' +
> 'try { f_named(); } catch (err) {\n' +
> 'print(err.stack);\nprint(err.fileName);\nprint(err.lineNumber);\nprint(err.columnNumber);\n}' +
> '\n\n// C: IIFE (anonymous function)\n' +
> 'try { (function(){ throw new Error("E_iife"); })(); } catch (err) {\n' +
> 'print(err.stack);\nprint(err.fileName);\nprint(err.lineNumber);\nprint(err.columnNumber);\n}' +
> '\n\n// D: named function expression\n' +
> 'var f_expr = function namedExpr() { throw new Error("E_namedExpr"); };\n' +
> 'try { f_expr(); } catch (err) {\n' +
> 'print(err.stack);\nprint(err.fileName);\nprint(err.lineNumber);\nprint(err.columnNumber);\n}' +
> '\n\n// E: direct eval\n' +
> 'try { eval("throw new Error(\\\"E_eval\\\")"); } catch (err) {\n' +
> 'print(err.stack);\nprint(err.fileName);\nprint(err.lineNumber);\nprint(err.columnNumber);\n}' +
> '\n\n// H: TypeError (non-callable)\n' +
> 'try { ({}).notAFunction(); } catch (err) {\n' +
> 'print(err.stack);\nprint(err.fileName);\nprint(err.lineNumber);\nprint(err.columnNumber);\n}';
> eval(SRC);
< Error: E_direct
<     at <eval>:2:34
<     at <anonymous>:23:10
< <eval>
< 2
< 34
< Error: E_named
<     at f_named (<eval>:10:48)
<     at <eval>:11:16
<     at <anonymous>:23:10
< <eval>
< 10
< 48
< Error: E_iife
<     at <eval>:19:45
<     at <eval>:19:51
<     at <anonymous>:23:10
< <eval>
< 19
< 45
< Error: E_namedExpr
<     at namedExpr (<eval>:27:67)
<     at <eval>:28:15
<     at <anonymous>:23:10
< <eval>
< 27
< 67
< Error: E_eval
<     at <eval>:1:26
<     at <eval>:36:42
<     at <anonymous>:23:10
< <eval>
< 1
< 26
< TypeError: notAFunction is not a function
<     at <eval>:44:26
<     at <anonymous>:23:10
< <eval>
< 44
< 26
-
