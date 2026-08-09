// 7.2 WhiteSpace in ES5.1 is the ES3 list plus the BOM, which moved out of the 7.1 format-control set, plus the
// open-ended <USP> category-Zs catch-all. Four places have to agree on that set: the lexer, 9.3.1 ToNumber on a
// string, 15.1.2.2 parseInt and 15.5.4.20 trim. Only trim did. ES3 7.2 carries the same <USP> catch-all and does
// not implement it either, but that is a shared bug tracked in docs/notes/Todo.md; the es5 build is made
// conformant here under guards without moving the es3 binary. Characters are built rather than written literally
// so this file stays plain ASCII. Verified against V8.
> function show(l, v) { print(l + ": " + v) }
> function C(n) { return String.fromCharCode(n) }
> var B = C(0xFEFF), IDEO = C(0x3000), OGHAM = C(0x1680), NNBSP = C(0x202F), MMSP = C(0x205F), ENQ = C(0x2000), HAIR = C(0x200A);
-
// The lexer: these separate tokens anywhere in the source, not only as a leading file marker.
> show("separator", eval("var" + IDEO + "wsA = 41;" + B + "wsA + 1"));
< separator: 42
> show("leading", eval(B + "1 + 1"));
< leading: 2
-
// 9.3.1 ToNumber on a string skips StrWhiteSpace at both ends.
> show("number ideo", Number(IDEO + "12"));
< number ideo: 12
> show("number all", Number(B + OGHAM + NNBSP + ENQ + HAIR + "7" + IDEO));
< number all: 7
-
// A string of nothing but whitespace is the empty StrNumericLiteral, which 9.3.1 makes 0 rather than NaN.
> show("empty", Number(IDEO + B));
< empty: 0
-
// 15.1.2.2 parseInt and 15.1.2.3 parseFloat strip the same set before the digits.
> show("parseInt", parseInt(IDEO + "34"));
< parseInt: 34
> show("parseFloat", parseFloat(OGHAM + "5.5"));
< parseFloat: 5.5
-
// Stripping must not disturb what follows it: the radix and 0x rules still apply to the remainder.
> show("parseInt radix", parseInt(B + "  0x1F", 16));
< parseInt radix: 31
> show("parseInt neg", parseInt(IDEO + "-2A", 16));
< parseInt neg: -42
-
// 15.1.2.2 step 1 is ToString, not ToPrimitive, so an object with both must go through toString.
> var coerce = { valueOf: function () { return 99 }, toString: function () { return IDEO + "17" } };
> show("tostring", parseInt(coerce));
< tostring: 17
-
// 15.5.4.20 trim already had the full set and must still agree with the three above.
> show("trim", "[" + (IDEO + "x" + B).trim() + "]");
< trim: [x]
-
// <USP> is category Zs of the Unicode version the engine is built from, which is 3.0. U+200B ZERO WIDTH SPACE is
// Zs there and only became a format character in Unicode 4.0.1, so it counts here where modern engines reject it.
> show("zwsp number", Number(C(0x200B) + "1"));
< zwsp number: 1
> show("zwsp parseInt", parseInt(C(0x200B) + "1"));
< zwsp parseInt: 1
-
// Negative controls that hold in every Unicode version: U+205F was added in 3.2 so it is outside the 3.0 set, and
// U+200C ZERO WIDTH NON-JOINER is a format character throughout. Either turning white space widens the set wrongly.
> show("mmsp number", Number(MMSP + "1"));
< mmsp number: NaN
> show("zwnj number", Number(C(0x200C) + "1"));
< zwnj number: NaN
-
// The ES3 members of the set are unaffected.
> show("nbsp", Number(C(0xA0) + "3"));
< nbsp: 3
-
