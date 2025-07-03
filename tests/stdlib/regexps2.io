> function myescape(s) {
> 	var o = '', b = 0, c;
> 	for (var i = 0; i < s.length; ++i) {
> 		if ((c = s[i]) < ' ' || c > '\x7E') {
> 			o += s.substring(b, i) + ("\\u" + ("0000" + c.charCodeAt(0).toString(16)).slice(-4));
> 			b = i + 1;
> 		}
> 	}
> 	return o + (b > 0 ? s.substring(b, i) : s);
> }
-
> function testRE(re, s) {
> 	var m = re.exec(s);
> 	var r = '';
> 	if (!m) {
> 		r = 'null';
> 	} else {
> 		r = '{ ';
> 		for (var i = 0; i < m.length; ++i) {
> 			r += (i > 0 ? ', ' : '') + myescape('' + m[i]);
> 		}
> 		r += ' } @ ' + m.index + (m.global ? ' (next: ' + re.lastIndex + ')' : '');
> 	}
> 	print(myescape(re.toString()) + " on " + myescape(s) + ": " + r);
> }
-
> var t = RegExp("abcdef", "g");
> testRE(t, "abcdef");
> testRE(t, "abc");
> testRE(t, "abcdeabcdefabcde");
< /abcdef/g on abcdef: { abcdef } @ 0
< /abcdef/g on abc: null
< /abcdef/g on abcdeabcdefabcde: { abcdef } @ 5
-
> t = RegExp("\\n\\rab\\nc\\x15\\u1234\u0055\\cA\\0\"");
> testRE(t, "\n\rab\nc\x15\u1234\u0055\x01\0\"");
> testRE(t, "\\n\\rab\\nc\\x15\\u1234\\u0055\\x01\\0\\\"");
< /\n\rab\nc\x15\u1234U\cA\0"/ on \u000a\u000dab\u000ac\u0015\u1234U\u0001\u0000": { \u000a\u000dab\u000ac\u0015\u1234U\u0001\u0000" } @ 0
< /\n\rab\nc\x15\u1234U\cA\0"/ on \n\rab\nc\x15\u1234\u0055\x01\0\": null
-
> t = RegExp("\\\\");
> testRE(t, "\\");
< /\\/ on \: { \ } @ 0
-
> t = RegExp("\\(");
> testRE(t, "(");
< /\(/ on (: { ( } @ 0
-
> t = RegExp("^abcdef");
> testRE(t, "abcdef");
> testRE(t, "abcdeabcdefabcde");
< /^abcdef/ on abcdef: { abcdef } @ 0
< /^abcdef/ on abcdeabcdefabcde: null
-
> t = RegExp(".*$");
> testRE(t, "abc\ndef");
> testRE(t, "abc\u2029def");
> testRE(t, "abc");
< /.*$/ on abc\u000adef: { def } @ 4
< /.*$/ on abc\u2029def: { def } @ 4
< /.*$/ on abc: { abc } @ 0
-
> t = RegExp("^def");
> testRE(t, "abc\ndef");
< /^def/ on abc\u000adef: null
-
> t = RegExp("^def", "m");
> testRE(t, "abc\ndef");
< /^def/m on abc\u000adef: { def } @ 4
-
> t = RegExp("abc$", "");
> testRE(t, "abc\ndef");
< /abc$/ on abc\u000adef: null
-
> t = RegExp("abc$", "m");
> testRE(t, "abc\ndef");
< /abc$/m on abc\u000adef: { abc } @ 0
-
> t = RegExp("^(a|bc|def)$");
> testRE(t, "");
> testRE(t, "a");
> testRE(t, "bc");
> testRE(t, "def");
> testRE(t, "bcdef");
< /^(a|bc|def)$/ on : null
< /^(a|bc|def)$/ on a: { a, a } @ 0
< /^(a|bc|def)$/ on bc: { bc, bc } @ 0
< /^(a|bc|def)$/ on def: { def, def } @ 0
< /^(a|bc|def)$/ on bcdef: null
-
> t = RegExp("^(|a|bc|def)$");
> testRE(t, "");
> testRE(t, "def");
> testRE(t, "bcdef");
< /^(|a|bc|def)$/ on : { ,  } @ 0
< /^(|a|bc|def)$/ on def: { def, def } @ 0
< /^(|a|bc|def)$/ on bcdef: null
-
> t = RegExp("\\w\\w\\w");
> testRE(t, "");
> testRE(t, "123");
> testRE(t, "12a");
> testRE(t, "12#");
< /\w\w\w/ on : null
< /\w\w\w/ on 123: { 123 } @ 0
< /\w\w\w/ on 12a: { 12a } @ 0
< /\w\w\w/ on 12#: null
-
> t = RegExp("\\W\\W\\W");
> testRE(t, "12#");
> testRE(t, "#%)");
< /\W\W\W/ on 12#: null
< /\W\W\W/ on #%): { #%) } @ 0
-
> t = RegExp("\\w\\w\\w\\W\\s\\s\\s\\S\\S\\S\\d\\d\\d\\d\\D\\D\\D\\D");
> testRE(t, "q9_!\n \u2028lm_9124qwer");
< /\w\w\w\W\s\s\s\S\S\S\d\d\d\d\D\D\D\D/ on q9_!\u000a \u2028lm_9124qwer: { q9_!\u000a \u2028lm_9124qwer } @ 0
-
> t = RegExp("(z)(((?:a)+)?((?:b)+)?(c))*");
> testRE(t, "");
> testRE(t, "zaacbbbcac");
< /(z)(((?:a)+)?((?:b)+)?(c))*/ on : null
< /(z)(((?:a)+)?((?:b)+)?(c))*/ on zaacbbbcac: { zaacbbbcac, z, ac, a, undefined, c } @ 0
-
> t = RegExp("s(a)??(a)?$");
> testRE(t, "");
> testRE(t, "s");
> testRE(t, "sa");
> testRE(t, "saa");
> testRE(t, "saaa");
< /s(a)??(a)?$/ on : null
< /s(a)??(a)?$/ on s: { s, undefined, undefined } @ 0
< /s(a)??(a)?$/ on sa: { sa, undefined, a } @ 0
< /s(a)??(a)?$/ on saa: { saa, a, a } @ 0
< /s(a)??(a)?$/ on saaa: null
-
> t = RegExp("^(a){0}$");
> testRE(t, "");
> testRE(t, "a");
> testRE(t, "aa");
< /^(a){0}$/ on : { , undefined } @ 0
< /^(a){0}$/ on a: null
< /^(a){0}$/ on aa: null
-
> t = RegExp("^(a){1}$");
> testRE(t, "");
> testRE(t, "a");
> testRE(t, "aa");
< /^(a){1}$/ on : null
< /^(a){1}$/ on a: { a, a } @ 0
< /^(a){1}$/ on aa: null
-
> t = RegExp("(a){3}");
> testRE(t, "a");
> testRE(t, "aa");
> testRE(t, "aaa");
> testRE(t, "aaaa");
< /(a){3}/ on a: null
< /(a){3}/ on aa: null
< /(a){3}/ on aaa: { aaa, a } @ 0
< /(a){3}/ on aaaa: { aaa, a } @ 0
-
> t = RegExp("(a){3,}");
> testRE(t, "aa");
> testRE(t, "aaa");
> testRE(t, "aaaa");
< /(a){3,}/ on aa: null
< /(a){3,}/ on aaa: { aaa, a } @ 0
< /(a){3,}/ on aaaa: { aaaa, a } @ 0
-
> t = RegExp("(a){13,23}$");
> testRE(t, "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa");
< /(a){13,23}$/ on aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa: { aaaaaaaaaaaaaaaaaaaaaaa, a } @ 31
-
> t = RegExp("(a){1,1}?$");
> testRE(t, "a");
> testRE(t, "aa");
< /(a){1,1}?$/ on a: { a, a } @ 0
< /(a){1,1}?$/ on aa: { a, a } @ 1
-
> t = RegExp("^(a|bc|def){3,5}$");
> testRE(t, "abcdef");
> testRE(t, "defbca");
> testRE(t, "aaaaa");
> testRE(t, "abcdefabcdef");
< /^(a|bc|def){3,5}$/ on abcdef: { abcdef, def } @ 0
< /^(a|bc|def){3,5}$/ on defbca: { defbca, a } @ 0
< /^(a|bc|def){3,5}$/ on aaaaa: { aaaaa, a } @ 0
< /^(a|bc|def){3,5}$/ on abcdefabcdef: null
-
> t = RegExp("(abc)\\1");
> testRE(t, "abc");
> testRE(t, "abcabc");
> testRE(t, "qwertyabcabc");
< /(abc)\1/ on abc: null
< /(abc)\1/ on abcabc: { abcabc, abc } @ 0
< /(abc)\1/ on qwertyabcabc: { abcabc, abc } @ 6
-
> t = RegExp("^qwerty(abc|def)\\1$");
> testRE(t, "qwertyabcabc");
> testRE(t, "qwertydefdef");
> testRE(t, "qwertyabcdef");
> testRE(t, "qwertydefabc");
< /^qwerty(abc|def)\1$/ on qwertyabcabc: { qwertyabcabc, abc } @ 0
< /^qwerty(abc|def)\1$/ on qwertydefdef: { qwertydefdef, def } @ 0
< /^qwerty(abc|def)\1$/ on qwertyabcdef: null
< /^qwerty(abc|def)\1$/ on qwertydefabc: null
-
> t = RegExp("^qwerty(abc|defg)\\1?$");
> testRE(t, "qwertyabc");
> testRE(t, "qwertydefgdefg");
> testRE(t, "qwertyabcabcabc");
< /^qwerty(abc|defg)\1?$/ on qwertyabc: { qwertyabc, abc } @ 0
< /^qwerty(abc|defg)\1?$/ on qwertydefgdefg: { qwertydefgdefg, defg } @ 0
< /^qwerty(abc|defg)\1?$/ on qwertyabcabcabc: null
-
> t = RegExp("^qwerty(abc|defg)\\1*$");
> testRE(t, "qwertyabc");
> testRE(t, "qwertydefgdefg");
> testRE(t, "qwertyabcabcabc");
< /^qwerty(abc|defg)\1*$/ on qwertyabc: { qwertyabc, abc } @ 0
< /^qwerty(abc|defg)\1*$/ on qwertydefgdefg: { qwertydefgdefg, defg } @ 0
< /^qwerty(abc|defg)\1*$/ on qwertyabcabcabc: { qwertyabcabcabc, abc } @ 0
-
> t = RegExp("^qwerty(abc|defg)\\1+$");
> testRE(t, "qwertyabc");
> testRE(t, "qwertydefgdefg");
> testRE(t, "qwertyabcabcabc");
< /^qwerty(abc|defg)\1+$/ on qwertyabc: null
< /^qwerty(abc|defg)\1+$/ on qwertydefgdefg: { qwertydefgdefg, defg } @ 0
< /^qwerty(abc|defg)\1+$/ on qwertyabcabcabc: { qwertyabcabcabc, abc } @ 0
-
> t = RegExp("^qwerty(abc|defg)\\1+?$");
> testRE(t, "qwertyabc");
> testRE(t, "qwertydefgdefg");
> testRE(t, "qwertyabcabcabcabcabc");
< /^qwerty(abc|defg)\1+?$/ on qwertyabc: null
< /^qwerty(abc|defg)\1+?$/ on qwertydefgdefg: { qwertydefgdefg, defg } @ 0
< /^qwerty(abc|defg)\1+?$/ on qwertyabcabcabcabcabc: { qwertyabcabcabcabcabc, abc } @ 0
-
> t = RegExp("^qwerty(abc|defg|)\\1*abc$");
> testRE(t, "qwertydefg");
> testRE(t, "qwertydefgdefg");
> testRE(t, "qwertyabc");
< /^qwerty(abc|defg|)\1*abc$/ on qwertydefg: null
< /^qwerty(abc|defg|)\1*abc$/ on qwertydefgdefg: null
< /^qwerty(abc|defg|)\1*abc$/ on qwertyabc: { qwertyabc,  } @ 0
-
> t = RegExp("^(ab|def|ghij)?\\1{0}$");
> testRE(t, "");
> testRE(t, "ghij");
> testRE(t, "ababababab");
> testRE(t, "abababababab");
< /^(ab|def|ghij)?\1{0}$/ on : { , undefined } @ 0
< /^(ab|def|ghij)?\1{0}$/ on ghij: { ghij, ghij } @ 0
< /^(ab|def|ghij)?\1{0}$/ on ababababab: null
< /^(ab|def|ghij)?\1{0}$/ on abababababab: null
-
> t = RegExp("^(ab|def|ghij)?\\1{1}$");
> testRE(t, "");
> testRE(t, "def");
> testRE(t, "defdef");
> testRE(t, "ababababab");
> testRE(t, "abababababab");
< /^(ab|def|ghij)?\1{1}$/ on : { , undefined } @ 0
< /^(ab|def|ghij)?\1{1}$/ on def: null
< /^(ab|def|ghij)?\1{1}$/ on defdef: { defdef, def } @ 0
< /^(ab|def|ghij)?\1{1}$/ on ababababab: null
< /^(ab|def|ghij)?\1{1}$/ on abababababab: null
-
> t = RegExp("^(ab|def|ghij)?\\1{5}$");
> testRE(t, "");
> testRE(t, "ababababab");
> testRE(t, "abababababab");
< /^(ab|def|ghij)?\1{5}$/ on : { , undefined } @ 0
< /^(ab|def|ghij)?\1{5}$/ on ababababab: null
< /^(ab|def|ghij)?\1{5}$/ on abababababab: { abababababab, ab } @ 0
-
> t = RegExp("^(ab|def|ghij)?(\\1){5}$");
> testRE(t, "");
> testRE(t, "ababababab");
> testRE(t, "abababababab");
> testRE(t, "defdefdefdefdefdef");
> testRE(t, "ghijghijghijghijghijghij");
< /^(ab|def|ghij)?(\1){5}$/ on : { , undefined,  } @ 0
< /^(ab|def|ghij)?(\1){5}$/ on ababababab: null
< /^(ab|def|ghij)?(\1){5}$/ on abababababab: { abababababab, ab, ab } @ 0
< /^(ab|def|ghij)?(\1){5}$/ on defdefdefdefdefdef: { defdefdefdefdefdef, def, def } @ 0
< /^(ab|def|ghij)?(\1){5}$/ on ghijghijghijghijghijghij: { ghijghijghijghijghijghij, ghij, ghij } @ 0
-
> 
-
> t = RegExp("^(ab)(abc)(\\1|\\2){5}abc$");
> testRE(t, "abcd");
> testRE(t, "ababcabababcabcabcabc");
< /^(ab)(abc)(\1|\2){5}abc$/ on abcd: null
< /^(ab)(abc)(\1|\2){5}abc$/ on ababcabababcabcabcabc: { ababcabababcabcabcabc, ab, abc, abc } @ 0
-
> t = RegExp("^(ab|ab..)?(\\1){5}$");
> testRE(t, "");
> testRE(t, "abababababab");
> testRE(t, "abababababababababababab");
> testRE(t, "abcdabcdabcdabcdabcdabcd");
< /^(ab|ab..)?(\1){5}$/ on : { , undefined,  } @ 0
< /^(ab|ab..)?(\1){5}$/ on abababababab: { abababababab, ab, ab } @ 0
< /^(ab|ab..)?(\1){5}$/ on abababababababababababab: { abababababababababababab, abab, abab } @ 0
< /^(ab|ab..)?(\1){5}$/ on abcdabcdabcdabcdabcdabcd: { abcdabcdabcdabcdabcdabcd, abcd, abcd } @ 0
-
> t = RegExp("^(a|ab)(bc|c)(\\1\\2){5}$");
> testRE(t, "abcabcabcabcabcabc");
< /^(a|ab)(bc|c)(\1\2){5}$/ on abcabcabcabcabcabc: { abcabcabcabcabcabc, a, bc, abc } @ 0
-
> t = RegExp("((?:a)*)(\\1){3}$");
> testRE(t, "");
> testRE(t, "xxxxa");
> testRE(t, "xxxxaaaa");
> testRE(t, "xxxxaaaaaa");
> testRE(t, "xxxxaaaaaaaa");
< /((?:a)*)(\1){3}$/ on : { , ,  } @ 0
< /((?:a)*)(\1){3}$/ on xxxxa: { , ,  } @ 5
< /((?:a)*)(\1){3}$/ on xxxxaaaa: { aaaa, a, a } @ 4
< /((?:a)*)(\1){3}$/ on xxxxaaaaaa: { aaaa, a, a } @ 6
< /((?:a)*)(\1){3}$/ on xxxxaaaaaaaa: { aaaaaaaa, aa, aa } @ 4
-
> t = RegExp("((?:a)*)(\\1){3,}$");
> testRE(t, "");
> testRE(t, "xxxxaaaa");
> testRE(t, "xxxxaaaaaaaaaaaaa");
< /((?:a)*)(\1){3,}$/ on : { , ,  } @ 0
< /((?:a)*)(\1){3,}$/ on xxxxaaaa: { aaaa, a, a } @ 4
< /((?:a)*)(\1){3,}$/ on xxxxaaaaaaaaaaaaa: { aaaaaaaaaaaaa, a, a } @ 4
-
> t = RegExp("(a)(b)(c)(d)(e)(f)(g)(h)(i)(j)(k)(l)\\1\\2\\3\\4\\5\\6\\7\\8\\9\\10\\11\\12");
> testRE(t, "abcdefghijklabcdefghijkl");
< /(a)(b)(c)(d)(e)(f)(g)(h)(i)(j)(k)(l)\1\2\3\4\5\6\7\8\9\10\11\12/ on abcdefghijklabcdefghijkl: { abcdefghijklabcdefghijkl, a, b, c, d, e, f, g, h, i, j, k, l } @ 0
-
> t = RegExp("^(?=abc)abcdef$");
> testRE(t, 'def');
> testRE(t, 'abcabcdef');
> testRE(t, 'abcdef');
< /^(?=abc)abcdef$/ on def: null
< /^(?=abc)abcdef$/ on abcabcdef: null
< /^(?=abc)abcdef$/ on abcdef: { abcdef } @ 0
-
> t = RegExp("^(?=abc|ab)abcdef$");
> testRE(t, 'abcdef');
> testRE(t, 'abcdefabc');
> testRE(t, 'abcdefab');
< /^(?=abc|ab)abcdef$/ on abcdef: { abcdef } @ 0
< /^(?=abc|ab)abcdef$/ on abcdefabc: null
< /^(?=abc|ab)abcdef$/ on abcdefab: null
-
> t = RegExp("^(?=nope|ab)abcdef$");
> testRE(t, 'abcdef');
> testRE(t, 'abcdefabc');
> testRE(t, 'abcdefab');
< /^(?=nope|ab)abcdef$/ on abcdef: { abcdef } @ 0
< /^(?=nope|ab)abcdef$/ on abcdefabc: null
< /^(?=nope|ab)abcdef$/ on abcdefab: null
-
> t = RegExp("^(?=(abc|ab))abcdef\\1$");
> testRE(t, 'abcdefabc');
> testRE(t, 'abcdefab');
> t = RegExp("^(?=(ab|abc))abcdef\\1$");
> testRE(t, 'abcdefabc');
> testRE(t, 'abcdefab');
< /^(?=(abc|ab))abcdef\1$/ on abcdefabc: { abcdefabc, abc } @ 0
< /^(?=(abc|ab))abcdef\1$/ on abcdefab: null
< /^(?=(ab|abc))abcdef\1$/ on abcdefabc: null
< /^(?=(ab|abc))abcdef\1$/ on abcdefab: { abcdefab, ab } @ 0
-
> t = RegExp("(?=((?:a)+))(?:a)*b\\1");
> testRE(t, "baaabac");
< /(?=((?:a)+))(?:a)*b\1/ on baaabac: { aba, a } @ 3
-
> t = RegExp("^(?!abc)(.)+$");
> testRE(t, "abc");
> testRE(t, "ab");
> testRE(t, "abcd");
< /^(?!abc)(.)+$/ on abc: null
< /^(?!abc)(.)+$/ on ab: { ab, b } @ 0
< /^(?!abc)(.)+$/ on abcd: null
-
> t = RegExp("^(?!(abc))(.)+$");
> testRE(t, "abab");
< /^(?!(abc))(.)+$/ on abab: { abab, undefined, b } @ 0
-
> t = RegExp("^(?:a)+aa$");
> testRE(t, "aaaaabc");
< /^(?:a)+aa$/ on aaaaabc: null
-
> t = RegExp("^a*$");
> testRE(t, "");
> testRE(t, "a");
> testRE(t, "aaaaa");
< /^a*$/ on : {  } @ 0
< /^a*$/ on a: { a } @ 0
< /^a*$/ on aaaaa: { aaaaa } @ 0
-
> t = RegExp("^aaa*aa$");
> testRE(t, "aaaaaaaaa");
< /^aaa*aa$/ on aaaaaaaaa: { aaaaaaaaa } @ 0
-
> t = RegExp("^(aa)(a*)(aa)$");
> testRE(t, "");
> testRE(t, "aa");
> testRE(t, "aaaa");
> testRE(t, "aaaaaaaaa");
< /^(aa)(a*)(aa)$/ on : null
< /^(aa)(a*)(aa)$/ on aa: null
< /^(aa)(a*)(aa)$/ on aaaa: { aaaa, aa, , aa } @ 0
< /^(aa)(a*)(aa)$/ on aaaaaaaaa: { aaaaaaaaa, aa, aaaaa, aa } @ 0
-
> t = RegExp("^(.*)\\1$");
> testRE(t, "");
> testRE(t, "aa");
> testRE(t, "aaaa");
> testRE(t, "qweqwe");
> testRE(t, "qweqweqwe");
> testRE(t, "qwertyqwertyqwertyqwerty");
< /^(.*)\1$/ on : { ,  } @ 0
< /^(.*)\1$/ on aa: { aa, a } @ 0
< /^(.*)\1$/ on aaaa: { aaaa, aa } @ 0
< /^(.*)\1$/ on qweqwe: { qweqwe, qwe } @ 0
< /^(.*)\1$/ on qweqweqwe: null
< /^(.*)\1$/ on qwertyqwertyqwertyqwerty: { qwertyqwertyqwertyqwerty, qwertyqwerty } @ 0
-
> t = RegExp("^start(x+)end$");
> testRE(t, "startend");
> testRE(t, "startxend");
> testRE(t, "startxxxxxend");
> testRE(t, "startxxxxxen");
< /^start(x+)end$/ on startend: null
< /^start(x+)end$/ on startxend: { startxend, x } @ 0
< /^start(x+)end$/ on startxxxxxend: { startxxxxxend, xxxxx } @ 0
< /^start(x+)end$/ on startxxxxxen: null
-
> t = RegExp("^start(x?)end$");
> testRE(t, "startend");
> testRE(t, "startxend");
> testRE(t, "startxxxxxend");
> testRE(t, "startxxxxxen");
< /^start(x?)end$/ on startend: { startend,  } @ 0
< /^start(x?)end$/ on startxend: { startxend, x } @ 0
< /^start(x?)end$/ on startxxxxxend: null
< /^start(x?)end$/ on startxxxxxen: null
-
> t = RegExp("^start(x{3,5})end$");
> testRE(t, "startend");
> testRE(t, "startxend");
> testRE(t, "startxxend");
> testRE(t, "startxxxend");
> testRE(t, "startxxxxxend");
> testRE(t, "startxxxxxxend");
> testRE(t, "startxxxxxen");
< /^start(x{3,5})end$/ on startend: null
< /^start(x{3,5})end$/ on startxend: null
< /^start(x{3,5})end$/ on startxxend: null
< /^start(x{3,5})end$/ on startxxxend: { startxxxend, xxx } @ 0
< /^start(x{3,5})end$/ on startxxxxxend: { startxxxxxend, xxxxx } @ 0
< /^start(x{3,5})end$/ on startxxxxxxend: null
< /^start(x{3,5})end$/ on startxxxxxen: null
-
> t = RegExp("^startx{3,5}?end$");
> testRE(t, "startend");
> testRE(t, "startxend");
> testRE(t, "startxxend");
> testRE(t, "startxxxend");
> testRE(t, "startxxxxxend");
> testRE(t, "startxxxxxxend");
> testRE(t, "startxxxxxen");
< /^startx{3,5}?end$/ on startend: null
< /^startx{3,5}?end$/ on startxend: null
< /^startx{3,5}?end$/ on startxxend: null
< /^startx{3,5}?end$/ on startxxxend: { startxxxend } @ 0
< /^startx{3,5}?end$/ on startxxxxxend: { startxxxxxend } @ 0
< /^startx{3,5}?end$/ on startxxxxxxend: null
< /^startx{3,5}?end$/ on startxxxxxen: null
-
> t = RegExp("^start(x{3,5})(x*)end$");
> testRE(t, "startxxxxxxxxxxend");
< /^start(x{3,5})(x*)end$/ on startxxxxxxxxxxend: { startxxxxxxxxxxend, xxxxx, xxxxx } @ 0
-
> t = RegExp("^start(x{3,5}?)(x*)end$");
> testRE(t, "startxxxxxxxxxxend");
< /^start(x{3,5}?)(x*)end$/ on startxxxxxxxxxxend: { startxxxxxxxxxxend, xxx, xxxxxxx } @ 0
-
> t = RegExp("(?=(a+))a*b\\1");
> testRE(t, "baaabac");
< /(?=(a+))a*b\1/ on baaabac: { aba, a } @ 3
-
> t = RegExp("(a+)*q");
> testRE(t, "aaq");
< /(a+)*q/ on aaq: { aaq, aa } @ 0
-
> t = RegExp("^(?:(a)b|(ab))(?:\\2)+$");
> testRE(t, "ababab");
< /^(?:(a)b|(ab))(?:\2)+$/ on ababab: { ababab, undefined, ab } @ 0
-
> t = RegExp("(a*)b(\\1)+");
> testRE(t, "baaaac");
< /(a*)b(\1)+/ on baaaac: { b, ,  } @ 0
-
> t = RegExp("^[]$"); testRE(t, ""); testRE(t, "x"); testRE(t, "xy");
< /^[]$/ on : null
< /^[]$/ on x: null
< /^[]$/ on xy: null
-
> t = RegExp("^[^]$"); testRE(t, ""); testRE(t, "x"); testRE(t, "xy");
< /^[^]$/ on : null
< /^[^]$/ on x: { x } @ 0
< /^[^]$/ on xy: null
-
> t = RegExp("^[a]$"); testRE(t, "x");
< /^[a]$/ on x: null
-
> t = RegExp("^[x]$"); testRE(t, "x");
< /^[x]$/ on x: { x } @ 0
-
> t = RegExp("^[\\\\]$"); testRE(t, "\\");
< /^[\\]$/ on \: { \ } @ 0
-
> t = RegExp("^[\\]]$"); testRE(t, "]");
< /^[\]]$/ on ]: { ] } @ 0
-
> t = RegExp("^[a-z]$"); testRE(t, "x"); testRE(t, "X");
< /^[a-z]$/ on x: { x } @ 0
< /^[a-z]$/ on X: null
-
> t = RegExp("^[^a-z]$"); testRE(t, "x"); testRE(t, "X");
< /^[^a-z]$/ on x: null
< /^[^a-z]$/ on X: { X } @ 0
-
> t = RegExp("^[a-chioggf-z]$"); testRE(t, "x"); testRE(t, "X");
< /^[a-chioggf-z]$/ on x: { x } @ 0
< /^[a-chioggf-z]$/ on X: null
-
> t = RegExp("^[\\[-\\]]$"); testRE(t, "\\"); testRE(t, "["); testRE(t, "]"); testRE(t, "Z"); testRE(t, "^");
< /^[\[-\]]$/ on \: { \ } @ 0
< /^[\[-\]]$/ on [: { [ } @ 0
< /^[\[-\]]$/ on ]: { ] } @ 0
< /^[\[-\]]$/ on Z: null
< /^[\[-\]]$/ on ^: null
-
> t = RegExp("^[\\n]$"); testRE(t, "\\n"); testRE(t, "X");
< /^[\n]$/ on \n: null
< /^[\n]$/ on X: null
-
> t = RegExp("^[\\cA]$"); testRE(t, "\u0001"); testRE(t, "X");
< /^[\cA]$/ on \u0001: { \u0001 } @ 0
< /^[\cA]$/ on X: null
-
> t = RegExp("^[\u1234]$"); testRE(t, "\u1234"); testRE(t, "X");
< /^[\u1234]$/ on \u1234: { \u1234 } @ 0
< /^[\u1234]$/ on X: null
-
> t = RegExp("^[\0-\uFFFF]$"); testRE(t, "\u1234"); testRE(t, "X");
< /^[\u0000-\uffff]$/ on \u1234: { \u1234 } @ 0
< /^[\u0000-\uffff]$/ on X: { X } @ 0
-
> t = RegExp("^[\\b]$"); testRE(t, "\b"); testRE(t, "X");
< /^[\b]$/ on \u0008: { \u0008 } @ 0
< /^[\b]$/ on X: null
-
> t = RegExp("^[\\w]$"); testRE(t, "z"); testRE(t, "X"); testRE(t, "1"); testRE(t, "!"); testRE(t, "\n"); testRE(t, " ");
< /^[\w]$/ on z: { z } @ 0
< /^[\w]$/ on X: { X } @ 0
< /^[\w]$/ on 1: { 1 } @ 0
< /^[\w]$/ on !: null
< /^[\w]$/ on \u000a: null
< /^[\w]$/ on  : null
-
> t = RegExp("^[\\W]$"); testRE(t, "z"); testRE(t, "X"); testRE(t, "1"); testRE(t, "!"); testRE(t, "\n"); testRE(t, " ");
< /^[\W]$/ on z: null
< /^[\W]$/ on X: null
< /^[\W]$/ on 1: null
< /^[\W]$/ on !: { ! } @ 0
< /^[\W]$/ on \u000a: { \u000a } @ 0
< /^[\W]$/ on  : {   } @ 0
-
> t = RegExp("^[\\s]$"); testRE(t, "z"); testRE(t, "X"); testRE(t, "1"); testRE(t, "!"); testRE(t, "\n"); testRE(t, " ");
< /^[\s]$/ on z: null
< /^[\s]$/ on X: null
< /^[\s]$/ on 1: null
< /^[\s]$/ on !: null
< /^[\s]$/ on \u000a: { \u000a } @ 0
< /^[\s]$/ on  : {   } @ 0
-
> t = RegExp("^[\\S]$"); testRE(t, "z"); testRE(t, "X"); testRE(t, "1"); testRE(t, "!"); testRE(t, "\n"); testRE(t, " ");
< /^[\S]$/ on z: { z } @ 0
< /^[\S]$/ on X: { X } @ 0
< /^[\S]$/ on 1: { 1 } @ 0
< /^[\S]$/ on !: { ! } @ 0
< /^[\S]$/ on \u000a: null
< /^[\S]$/ on  : null
-
> t = RegExp("^[\\d]$"); testRE(t, "z"); testRE(t, "X"); testRE(t, "1"); testRE(t, "!"); testRE(t, "\n"); testRE(t, " ");
< /^[\d]$/ on z: null
< /^[\d]$/ on X: null
< /^[\d]$/ on 1: { 1 } @ 0
< /^[\d]$/ on !: null
< /^[\d]$/ on \u000a: null
< /^[\d]$/ on  : null
-
> t = RegExp("^[\\D]$"); testRE(t, "z"); testRE(t, "X"); testRE(t, "1"); testRE(t, "!"); testRE(t, "\n"); testRE(t, " ");
< /^[\D]$/ on z: { z } @ 0
< /^[\D]$/ on X: { X } @ 0
< /^[\D]$/ on 1: null
< /^[\D]$/ on !: { ! } @ 0
< /^[\D]$/ on \u000a: { \u000a } @ 0
< /^[\D]$/ on  : {   } @ 0
-
> t = RegExp("^.\\b..$"); testRE(t, "zxc"); testRE(t, " xc"); testRE(t, "xc "); testRE(t, "x  "); testRE(t, "   "); testRE(t, "  x");
< /^.\b..$/ on zxc: null
< /^.\b..$/ on  xc: {  xc } @ 0
< /^.\b..$/ on xc : null
< /^.\b..$/ on x  : { x   } @ 0
< /^.\b..$/ on    : null
< /^.\b..$/ on   x: null
-
> t = RegExp("^.\\B..$"); testRE(t, "zxc"); testRE(t, " xc"); testRE(t, "xc "); testRE(t, "x  "); testRE(t, "   "); testRE(t, "  x");
< /^.\B..$/ on zxc: { zxc } @ 0
< /^.\B..$/ on  xc: null
< /^.\B..$/ on xc : { xc  } @ 0
< /^.\B..$/ on x  : null
< /^.\B..$/ on    : {     } @ 0
< /^.\B..$/ on   x: {   x } @ 0
-
> t = RegExp("^\\B$"); testRE(t, ""); testRE(t, "x");
< /^\B$/ on : {  } @ 0
< /^\B$/ on x: null
-
> t = RegExp("^(\\b)*$"); testRE(t, ""); testRE(t, "xc");
< /^(\b)*$/ on : { , undefined } @ 0
< /^(\b)*$/ on xc: null
-
> /*
> 	Here, I'm interpreting the ES specs differently from the browser engines that I've tried, but similar to (at least
> 	older versions of) PCRE. The first capture will be empty because the empty string is the last successful match to
> 	(a*), after which we are not progressing on the input so we break out of the two '*' loops. I believe my
> 	interpretation is correct, but I am not 100%. See 15.10.2.5 in the ES spec.
> */
> t = RegExp("(a*)*q");
> testRE(t, "aaq");
< /(a*)*q/ on aaq: { aaq,  } @ 0
-
> t = RegExp("((?:a)*)*q");
> testRE(t, "aaq");
< /((?:a)*)*q/ on aaq: { aaq,  } @ 0
-
> t = RegExp("(a*|b*)*q");
> testRE(t, "aaq");
> testRE(t, "bbq");
< /(a*|b*)*q/ on aaq: { aaq,  } @ 0
< /(a*|b*)*q/ on bbq: { bbq,  } @ 0
-
> t = RegExp("(a*)+q");
> testRE(t, "aaq");
< /(a*)+q/ on aaq: { aaq,  } @ 0
-
> t = RegExp("^(\\B)*$");
> testRE(t, "");
> testRE(t, "xc");
< /^(\B)*$/ on : { ,  } @ 0
< /^(\B)*$/ on xc: null
-
> t = RegExp("abcdABCD", "i");
> testRE(t, "AbcDabCd");
< /abcdABCD/i on AbcDabCd: { AbcDabCd } @ 0
-
> t = RegExp("\\x66\\x46\\n", "i");
> testRE(t, "Ff\n");
< /\x66\x46\n/i on Ff\u000a: { Ff\u000a } @ 0
-
> t = RegExp("[a\x66]", "i");
> testRE(t, "AF\n");
> testRE(t, "af\n");
< /[af]/i on AF\u000a: { A } @ 0
< /[af]/i on af\u000a: { a } @ 0
-
> t = RegExp("[a-z]", "i");
> testRE(t, "g");
> testRE(t, "\u0131");
> testRE(t, "\u017F");
< /[a-z]/i on g: { g } @ 0
< /[a-z]/i on \u0131: null
< /[a-z]/i on \u017f: null
-
> t = RegExp("[A-Z]", "i");
> testRE(t, "g");
> testRE(t, "\u0131");
> testRE(t, "\u017F");
< /[A-Z]/i on g: { g } @ 0
< /[A-Z]/i on \u0131: null
< /[A-Z]/i on \u017f: null
-
> t = RegExp("^(?:([E-F])|.)(?:([E-F])|.)(?:([E-F])|.)(?:([E-F])|.)(?:([E-F])|.)(?:([E-F])|.)(?:([E-F])|.)(?:([E-F])|.)(?:([E-F])|.)$", "i");
> testRE(t, "DEFGdefg_");
< /^(?:([E-F])|.)(?:([E-F])|.)(?:([E-F])|.)(?:([E-F])|.)(?:([E-F])|.)(?:([E-F])|.)(?:([E-F])|.)(?:([E-F])|.)(?:([E-F])|.)$/i on DEFGdefg_: { DEFGdefg_, undefined, E, F, undefined, undefined, e, f, undefined, undefined } @ 0
-
> t = RegExp("^(?:([E-f])|.)(?:([E-f])|.)(?:([E-f])|.)(?:([E-f])|.)(?:([E-f])|.)(?:([E-f])|.)(?:([E-f])|.)(?:([E-f])|.)(?:([E-f])|.)$", "i");
> testRE(t, "DEFGdefg_");
< /^(?:([E-f])|.)(?:([E-f])|.)(?:([E-f])|.)(?:([E-f])|.)(?:([E-f])|.)(?:([E-f])|.)(?:([E-f])|.)(?:([E-f])|.)(?:([E-f])|.)$/i on DEFGdefg_: { DEFGdefg_, D, E, F, G, d, e, f, g, _ } @ 0
-
> t = RegExp("^(?:([e-f])|.)(?:([e-f])|.)(?:([e-f])|.)(?:([e-f])|.)(?:([e-f])|.)(?:([e-f])|.)(?:([e-f])|.)(?:([e-f])|.)(?:([e-f])|.)$", "i");
> testRE(t, "DEFGdefg_");
< /^(?:([e-f])|.)(?:([e-f])|.)(?:([e-f])|.)(?:([e-f])|.)(?:([e-f])|.)(?:([e-f])|.)(?:([e-f])|.)(?:([e-f])|.)(?:([e-f])|.)$/i on DEFGdefg_: { DEFGdefg_, undefined, E, F, undefined, undefined, e, f, undefined, undefined } @ 0
-
> t = RegExp("^(?:([G-d])|.)(?:([G-d])|.)(?:([G-d])|.)(?:([G-d])|.)(?:([G-d])|.)(?:([G-d])|.)(?:([G-d])|.)(?:([G-d])|.)(?:([G-d])|.)$", "i");
> testRE(t, "DEFGdefg_");
< /^(?:([G-d])|.)(?:([G-d])|.)(?:([G-d])|.)(?:([G-d])|.)(?:([G-d])|.)(?:([G-d])|.)(?:([G-d])|.)(?:([G-d])|.)(?:([G-d])|.)$/i on DEFGdefg_: { DEFGdefg_, D, undefined, undefined, G, d, undefined, undefined, g, _ } @ 0
-
> t = RegExp("a|ab");
> testRE(t, "abc");
< /a|ab/ on abc: { a } @ 0
-
> t = RegExp("a[a-z]{2,4}");
> testRE(t, "abcdefghi");
< /a[a-z]{2,4}/ on abcdefghi: { abcde } @ 0
-
> t = RegExp("(a*)b\\1+");
> testRE(t, "baaaac");
< /(a*)b\1+/ on baaaac: { b,  } @ 0
-
> t = RegExp("(.*?)a(?!(a+)b\\2c)\\2(.*)");
> testRE(t, "baaabaac");
< /(.*?)a(?!(a+)b\2c)\2(.*)/ on baaabaac: { baaabaac, ba, undefined, abaac } @ 0
-
> t = RegExp("(?:(a)|(a))(?!(?:\\2)+)\\2\\2\\2$");
> testRE(t, "aaaa");
< /(?:(a)|(a))(?!(?:\2)+)\2\2\2$/ on aaaa: null
-
> t = RegExp("(\\1(a)){2}$");
> testRE(t, "aa");
< /(\1(a)){2}$/ on aa: { aa, a, a } @ 0
-
> t = RegExp("(z)((a+)?(b+)?(c))*");
> testRE(t, "zaacbbbcac");
< /(z)((a+)?(b+)?(c))*/ on zaacbbbcac: { zaacbbbcac, z, ac, a, undefined, c } @ 0
-
> t = RegExp("(z)(?:(a+)?(b+)?(c))*");
> testRE(t, "zaacbbbcac");
< /(z)(?:(a+)?(b+)?(c))*/ on zaacbbbcac: { zaacbbbcac, z, a, undefined, c } @ 0
-
> t = RegExp("^\\1(?!(a)bc)bc$");
> testRE(t, "abc");
< /^\1(?!(a)bc)bc$/ on abc: null
-
> t = RegExp("\\");
! !!!! SyntaxError: Invalid escape in regular expression
-
> t = RegExp("\\q");
! !!!! SyntaxError: Invalid escape in regular expression
-
> t = RegExp("\\1");
! !!!! SyntaxError: Invalid back reference in regular expression
-
> t = RegExp("\\2(a)\\1");
! !!!! SyntaxError: Invalid back reference in regular expression
-
> t = RegExp("^(?=ab)*abcdef$");
! !!!! SyntaxError: Invalid regular expression
-
> t = RegExp("(?%)");
! !!!! SyntaxError: Unterminated group in regular expression
-
> t = RegExp("(");
! !!!! SyntaxError: Invalid regular expression
-
> t = RegExp("x{5,3}");
! !!!! SyntaxError: Min greater than max in regular expression quantifier
-
> t = RegExp("[");
! !!!! SyntaxError: Invalid character class syntax in regular expression
-
> t = RegExp("[^");
! !!!! SyntaxError: Invalid character class syntax in regular expression
-
> t = RegExp("[\\p]");
! !!!! SyntaxError: Invalid character class syntax in regular expression
-
> t = RegExp("[\\3]");
! !!!! SyntaxError: Invalid character class syntax in regular expression
-
> t = RegExp("[\\01]");
! !!!! SyntaxError: Invalid character class syntax in regular expression
-
> t = RegExp("[\\w-1]");
! !!!! SyntaxError: Invalid character class syntax in regular expression
-
> t = RegExp("[1-\\w]");
! !!!! SyntaxError: Invalid character class syntax in regular expression
-
> t = RegExp("[\\S-\\w]");
! !!!! SyntaxError: Invalid character class syntax in regular expression
-
> t = RegExp("[\\B]");
! !!!! SyntaxError: Invalid character class syntax in regular expression
-
> t = RegExp("[b-a]");
! !!!! SyntaxError: Invalid character class syntax in regular expression
-
