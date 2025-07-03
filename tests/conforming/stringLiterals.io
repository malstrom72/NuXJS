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
