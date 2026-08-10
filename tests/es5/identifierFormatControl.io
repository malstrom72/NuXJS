// 7.6 IdentifierPart in ES5.1 adds <ZWNJ> U+200C and <ZWJ> U+200D, so an identifier may carry them after its
// first character. They are category Cf, which the generated identifier bitmaps do not hold, so this is the one
// piece of the identifier grammar that is not table driven. ES3 7.1 takes the opposite approach and strips every
// Cf character from the source before lexing, everywhere including string literals; NuXJS has never done that
// (docs/notes/Todo.md), so the es3 build rejects all of this and byte identity is what pins it. ES5.1 7.1 keeps
// format-control characters inside literals, so the string cases below are the conformant answer, not a leftover.
// Characters are built rather than written literally so this file stays plain ASCII. Verified against V8.
> function show(l, v) { print(l + ": " + v) }
> function run(s) { try { return eval(s) } catch (e) { return e.name } }
> var ZWNJ = String.fromCharCode(0x200C), ZWJ = String.fromCharCode(0x200D), LRM = String.fromCharCode(0x200E);
-
// Both characters, in a declaration and in the reference that has to resolve to it.
> show("zwnj", run("var a" + ZWNJ + "b = 41; a" + ZWNJ + "b + 1"));
< zwnj: 42
> show("zwj", run("var a" + ZWJ + "b = 7; a" + ZWJ + "b"));
< zwj: 7
> show("both", run("var a" + ZWNJ + ZWJ + "b = 3; a" + ZWNJ + ZWJ + "b"));
< both: 3
> show("trailing", run("var ab" + ZWNJ + " = 8; ab" + ZWNJ));
< trailing: 8
-
// The character is part of the name, so it distinguishes two identifiers rather than being folded away.
> show("distinct", run("var ab = 1, a" + ZWNJ + "b = 2; ab + ':' + a" + ZWNJ + "b"));
< distinct: 1:2
-
// IdentifierStart is unchanged, so neither may open an identifier, and the property name after a `.` is an
// IdentifierName, which also begins with an IdentifierStart.
> show("start", run("var " + ZWNJ + "x = 1; 1"));
< start: SyntaxError
> show("dot start", run("var o = {}; o." + ZWNJ + "a = 1"));
< dot start: SyntaxError
-
// Only these two of the format-control characters. LRM stays rejected, which is what ES3 7.1 would have stripped.
> show("lrm", run("var a" + LRM + "b = 5; 1"));
< lrm: SyntaxError
-
// The \u escape form goes through the same test, and so must agree with the literal form on both productions.
> show("escaped part", run("var a\\u200Cb = 5; a\\u200Cb"));
< escaped part: 5
> show("escaped start", run("var \\u200Cx = 5; 1"));
< escaped start: SyntaxError
-
// Function names and parameters are the same production, and reach it through a different parser path.
> show("function", run("function f" + ZWNJ + "g(p" + ZWJ + "q) { return p" + ZWJ + "q } f" + ZWNJ + "g(6)"));
< function: 6
-
// A keyword is only a keyword when no IdentifierPart follows it, so widening the set makes `in<ZWNJ>o` one
// identifier and the expression a syntax error. Prefixing a keyword likewise names an ordinary variable.
> show("after keyword", run("var o = { a: 1 }; 'a' in" + ZWNJ + "o"));
< after keyword: SyntaxError
> show("keyword prefix", run("var i" + ZWNJ + "f = 5; i" + ZWNJ + "f"));
< keyword prefix: 5
-
// 7.8.5 RegularExpressionFlags is IdentifierPart too, so the character is consumed as a flag and then rejected by
// 15.10.4.1 as an unknown one, rather than left behind to end the expression.
> show("regexp flag", run("/x/" + ZWNJ));
< regexp flag: SyntaxError
-
// 7.1 leaves format-control characters alone inside a literal, so the character survives in the string and the
// identifier and the quoted property name still name the same property.
> show("in string", run("'a" + ZWNJ + "b'.length"));
< in string: 3
> show("as key", run("var o = { a" + ZWNJ + "b: 4 }; o['a" + ZWNJ + "b']"));
< as key: 4
> show("member", run("var o = {}; o.a" + ZWNJ + "b = 9; o['a" + ZWNJ + "b']"));
< member: 9
