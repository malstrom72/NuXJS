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
// 15.5.4.20 step 2 is ToString(this), which is hint String: toString runs before valueOf.
> var t = { toString: function () { return "  ts  " }, valueOf: function () { return "  vo  " } };
> print("[" + String.prototype.trim.call(t) + "]")
< [ts]
-
// 15.5.4.20 step 1 is CheckObjectCoercible, so a null or undefined this is a TypeError rather than "null".
> try { String.prototype.trim.call(null) } catch (e) { print(e.name) }
< TypeError
> try { String.prototype.trim.call(undefined) } catch (e) { print(e.name) }
< TypeError
-
