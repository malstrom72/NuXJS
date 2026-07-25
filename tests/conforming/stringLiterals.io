> function listCharCodes(s) { var a = [ ]; for (var i = 0; i < s.length; ++i) a.push(s.charCodeAt(i)); print(a.join()); }
> listCharCodes("abcdefgh");
< 97,98,99,100,101,102,103,104
-
> listCharCodes("\a\b\c\d\e\f\g\h\i\j\k\l\m\n\o\p\q\r\s\t\v\w\y\z");
< 97,8,99,100,101,12,103,104,105,106,107,108,109,10,111,112,113,13,115,9,11,119,121,122
-
> listCharCodes("\u1234\u5678\x23\x45\0\\\'\"")
< 4660,22136,35,69,0,92,39,34
-
> function shouldFail(s) { try { eval(s); print(s + " should have failed, but didn't"); } catch (e) { print(s + " failed"); } }
-
> shouldFail('"')
< " failed
-
> shouldFail("'")
< ' failed
-
> shouldFail('"\\u"')
< "\u" failed
-
> shouldFail('"\\u1"')
< "\u1" failed
-
> shouldFail('"\\u12"')
< "\u12" failed
-
> shouldFail('"\\u123"')
< "\u123" failed
-
> shouldFail('"\\x"')
< "\x" failed
-
> shouldFail('"\\x1"')
< "\x1" failed
-
> shouldFail('"abcd\nefghi"')
< "abcd
< efghi" failed
-
// 7.8.4: EscapeCharacter is SingleEscapeCharacter, DecimalDigit, x or u, and NonEscapeCharacter is "SourceCharacter
// but not EscapeCharacter". Digits are therefore excluded from NonEscapeCharacter exactly as x and u are, so \1 to \9
// match no production at all: an OctalEscapeSequence is an Annex B extension that is not part of the grammar proper.
> shouldFail('"\\1"')
< "\1" failed
-
> shouldFail('"\\7"')
< "\7" failed
-
> shouldFail('"\\8"')
< "\8" failed
-
> shouldFail('"\\9"')
< "\9" failed
-
> shouldFail('"\\47"')
< "\47" failed
-
// EscapeSequence :: 0 [lookahead not DecimalDigit], so \0 is the <NUL> escape only when no digit follows it.
> listCharCodes("\0");
< 0
-
> listCharCodes("\0x");
< 0,120
-
> shouldFail('"\\00"')
< "\00" failed
-
> shouldFail('"\\01"')
< "\01" failed
-
// Escapes are a string-literal concept; a regular expression literal is lexed separately, so a \1 backreference
// inside one is unaffected by the rule above.
> print(/(abc)\1/.test("abcabc")); print(/(abc)\1/.test("abcdef"));
< true
< false
-
