// ES3 7.8.4 has no LineContinuation production at all, so a `\` before a line terminator is just a bad escape.
// ES5.1 added it, and there the same source is one string spanning two lines. Twin: tests/es5/stringLineContinuation.io.
> eval("\"x\\\ny\"")
! !!!! SyntaxError: \ continuation is not supported
-
