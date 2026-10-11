// Format control characters follow ES5 7.1, not ES3 7.1, which removes them before lexing.
> var BOM = String.fromCharCode(0xFEFF), LRM = String.fromCharCode(0x200E), ZWJ = String.fromCharCode(0x200D);
-
> print(eval("'a" + BOM + "b'").length)
< 3
-
> print(eval("/a" + ZWJ + "b/").source.length)
< 3
-
> var x = 1; try { eval("x" + LRM + "+1") } catch (e) { print(e.name) }
< SyntaxError
-
> try { eval("var a" + ZWJ + "b") } catch (e) { print(e.name) }
< SyntaxError
-
