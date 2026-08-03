// 7.8.4 LineContinuation, new in ES5.1: ES3 7.8.4 has no such production, so the es3 build still rejects all of
// this (tests/es3only/escapedLFNotAllowed.io). A `\` before a LineTerminatorSequence contributes the EMPTY
// character sequence, which is the part that surprises people: both characters vanish, so it is neither a `\n` nor
// a space. 7.3 makes CR LF a single sequence, so a continuation over a Windows line ending spans three characters
// and the LF must not survive on its own. Verified against V8.
> function show(l, v) { print(l + ": " + v) }
-
// The plain LF form. Two characters out, with nothing inserted between them.
> var lf = eval("\"x\\\ny\"");
> show("lf", lf + "/" + lf.length);
< lf: xy/2
-
// CR LF is one LineTerminatorSequence, not two, so this is still "xy" rather than "x\ny".
> var crlf = eval("\"x\\\r\ny\"");
> show("crlf", crlf + "/" + crlf.length);
< crlf: xy/2
-
// Everything after a CR LF continuation, which is where a length helper that stops on the LF instead of stepping
// over it under-counts the buffer that unescape then fills.
> var crlfLong = eval("\"x\\\r\nabcdefghijklmnopqrstuvwxyz\"");
> show("crlf long", crlfLong + "/" + crlfLong.length);
< crlf long: xabcdefghijklmnopqrstuvwxyz/27
-
// The case above only trips the debug assert: unescape writes into a Vector<Char, 64>, whose first 64 elements are
// inline, so a short under-count stays inside them and a release build survives it. Past 64 the write leaves the
// object and corrupts the stack, so the tail here is 200 characters and the miscount aborts a release build too.
> var CR = String.fromCharCode(13), BS = String.fromCharCode(92);
> function mkTail(n) { var t = ""; for (var i = 0; i < n; ++i) t += "Z"; return eval('"x' + BS + CR + "\n" + t + '"') }
> show("crlf past inline", mkTail(200).length);
< crlf past inline: 201
-
// A lone CR is a LineTerminatorSequence in its own right.
> var cr = eval("\"x\\\ry\"");
> show("cr", cr + "/" + cr.length);
< cr: xy/2
-
// 7.3 counts U+2028 and U+2029 as line terminators, so they continue a line too. They are built here rather than
// written literally because 7.8.4 forbids a raw one inside the enclosing literal as well; only ES2019 relaxed that.
> var LS = String.fromCharCode(0x2028), PS = String.fromCharCode(0x2029);
> show("ls", eval("\"x\\" + LS + "y\"").length);
< ls: 2
> show("ps", eval("\"x\\" + PS + "y\"").length);
< ps: 2
-
// Single-quoted literals take the same production.
> show("single", eval("'x\\\ny'"));
< single: xy
-
// The neighbouring productions must be untouched: `\n` INSERTS a line feed, which is the opposite thing, and a
// backslash before an ordinary character is a NonEscapeCharacter that drops only the backslash.
> show("escape n", eval("\"x\\ny\"").length + "/" + eval("\"x\\ny\"").charCodeAt(1));
< escape n: 3/10
> show("nonescape", eval("\"x\\ y\"").length);
< nonescape: 3
-
// A raw line terminator with no backslash is still an unterminated string, which this must not have relaxed.
> try { eval("\"x\ny\"") } catch (e) { print(e.name) }
< SyntaxError
-
// Several in a row, including one at the very end, collapse to nothing at all.
> var rep = eval("\"a\\\nb\\\r\nc\\\n\"");
> show("repeated", rep + "/" + rep.length);
< repeated: abc/3
-
// A continuation is not a token separator: it may split a literal but the halves still join into one string.
> show("joined", eval("\"abc\\\ndef\"").length);
< joined: 6
-
