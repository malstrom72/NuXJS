// ES5.1 15.5.4.20: String.prototype.trim removes leading and trailing WhiteSpace (7.2) and LineTerminator (7.3).
> print("[" + "   hi \t\r\n  ".trim() + "]")
< [hi]
> print("clean".trim())
< clean
> print("".trim() === "")
< true
> print("mid dle".trim())
< mid dle
-
// The full ES5 WhiteSpace set, including NBSP, BOM, and the Zs category, is stripped.
> print("[" + "\t \u00A0\uFEFFx\u3000\u2003 ".trim() + "]")
< [x]
-
// trim is a non-enumerable, callable own method of String.prototype.
> print(typeof String.prototype.trim)
< function
> var found = false; for (var k in String.prototype) if (k === "trim") found = true; print(found)
< false
-
// Generic over the this value via ToString.
> print(String.prototype.trim.call(12345))
< 12345
-
