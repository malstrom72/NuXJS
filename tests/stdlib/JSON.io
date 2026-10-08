> print(JSON.stringify("abcd"));
< "abcd"
-
> print(JSON.stringify("ab\ncd"));
< "ab\ncd"
-
> print(JSON.stringify("ab\bc\fd\n\r\t\u9999\"\u1234\\\/"));
< "ab\bc\fd\n\r\t\u9999\"\u1234\\/"
-
> print(JSON.stringify({}));
< {}
-
> print(JSON.stringify([]));
< []
-
> print(JSON.stringify({ x: 1, y: "asdf", z: false, a: [ 1,2,3,undefined,5 ], o: { zzz: null, aaa: undefined, "\u9483": "\n\r\u1234\\/ab" } }));
< {"a":[1,2,3,null,5],"o":{"zzz":null,"\u9483":"\n\r\u1234\\/ab"},"z":false,"x":1,"y":"asdf"}
-
> var o = { n: null }; first = o; for (var i = 0; i < 20; ++i) { o.n = { i: i, n: null }; o = o.n; } o.n = first.n.n.n.n.n;
-
> try { print(JSON.stringify(o)); } catch (x) { print(x) }
< TypeError: Cannot convert circular structure to JSON
-
> var o = { n: null }; first = o; for (var i = 0; i < 1000; ++i) { o.n = { i: i, n: null }; o = o.n; } o.n = first.n.n.n.n.n;
-
> try { print(JSON.stringify(o)); } catch (x) { print(x) }
< TypeError: Structure too deeply nested for JSON conversion
-
> var o = { }; o.n = o;
-
> try { print(JSON.stringify(o)); } catch (x) { print(x) }
< TypeError: Cannot convert circular structure to JSON
-
> var o = { toJSON: function(k) { return "smorfen " + k; } };
-
> print(JSON.stringify(o));
< "smorfen "
-
> var o = { "hellu": { a: "b", toJSON: function(k) { return "smorfen " + k; } } }
-
> print(JSON.stringify(o));
< {"hellu":"smorfen hellu"}
-
> print(JSON.stringify(o, function(k, v) { return this[k]; }));
< {"hellu":{"a":"b"}}
-
> var o = { "hellu": { a: "b", b: "c", d: [ 1, 2, 3, [ 4, 5 ] ] } }
-
> print(JSON.stringify(o, function(k, v) { return (k === 'a' ? "yeah" : v); }));
< {"hellu":{"d":[1,2,3,[4,5]],"b":"c","a":"yeah"}}
-
> try { print(JSON.stringify(o, function(k, v) { return this } )); } catch (x) { print(x) }
< TypeError: Cannot convert circular structure to JSON
-
> print(JSON.stringify(o, null, ' '));
< {
<  "hellu": {
<   "d": [
<    1,
<    2,
<    3,
<    [
<     4,
<     5
<    ]
<   ],
<   "b": "c",
<   "a": "b"
<  }
< }
-
> print(JSON.stringify(o, null, 129831));
< {
<           "hellu": {
<                     "d": [
<                               1,
<                               2,
<                               3,
<                               [
<                                         4,
<                                         5
<                               ]
<                     ],
<                     "b": "c",
<                     "a": "b"
<           }
< }
-
> print(JSON.stringify(o, null, new Number(4)));
< {
<     "hellu": {
<         "d": [
<             1,
<             2,
<             3,
<             [
<                 4,
<                 5
<             ]
<         ],
<         "b": "c",
<         "a": "b"
<     }
< }
-
> print(JSON.stringify(o, null, "\t\txx\t                      "));
< {
< 		xx	     "hellu": {
< 		xx	     		xx	     "d": [
< 		xx	     		xx	     		xx	     1,
< 		xx	     		xx	     		xx	     2,
< 		xx	     		xx	     		xx	     3,
< 		xx	     		xx	     		xx	     [
< 		xx	     		xx	     		xx	     		xx	     4,
< 		xx	     		xx	     		xx	     		xx	     5
< 		xx	     		xx	     		xx	     ]
< 		xx	     		xx	     ],
< 		xx	     		xx	     "b": "c",
< 		xx	     		xx	     "a": "b"
< 		xx	     }
< }
-
> print(JSON.stringify([], null, new String("\t\txx\t                      ")));
< []
-
> print(JSON.stringify([1], null, "\t\txx\t                      "));
< [
< 		xx	     1
< ]
-
> print(JSON.stringify(o, null, ""));
< {"hellu":{"d":[1,2,3,[4,5]],"b":"c","a":"b"}}
-
> print(JSON.stringify(new Number(234)));
< 234
-
> print(JSON.stringify(new String(234)));
< "234"
-
> print(JSON.stringify(new Boolean(234)));
< true
-
> print(JSON.stringify({a:"a",b:"b",3:"3"},["a","a",new Number(3)]));
< {"3":"3","a":"a"}
-
> print(JSON.stringify({a:"a",b:"b",3:"3",c:{a:"popo",d:"nada"}},["a","a",new Number(3)]));
< {"3":"3","a":"a"}
-
> print(JSON.stringify({a:"a",b:"b",3:"3",a:{a:"popo",d:"nada"}},["a","a",new Number(3)]));
< {"3":"3","a":{"a":"popo"}}
-
> print(JSON.parse("0"));
< 0
-
> print(JSON.parse("0.1"));
< 0.1
-
> print(JSON.parse("123"));
< 123
-
> print(JSON.parse("123.456"));
< 123.456
-
> print(JSON.parse("123.456e33"));
< 1.23456e+35
-
> print(JSON.parse("123.456e+33"));
< 1.23456e+35
-
> print(JSON.parse("-123.456e-33"));
< -1.23456e-31
-
> print(JSON.parse("  \t\r\n   123.456  \n\r\t   "));
< 123.456
-
> try { print(JSON.parse("")) } catch (x) { print(x) }
< SyntaxError: Error parsing JSON
-
> try { print(JSON.parse("    ")) } catch (x) { print(x) }
< SyntaxError: Error parsing JSON
-
> try { print(JSON.parse("x")) } catch (x) { print(x) }
< SyntaxError: Error parsing JSON
-
> try { print(JSON.parse("-")) } catch (x) { print(x) }
< SyntaxError: Error parsing JSON
-
> try { print(JSON.parse(".")) } catch (x) { print(x) }
< SyntaxError: Error parsing JSON
-
> try { print(JSON.parse("e-33")) } catch (x) { print(x) }
< SyntaxError: Error parsing JSON
-
> try { print(JSON.parse("0123")) } catch (x) { print(x) }
< SyntaxError: Error parsing JSON
-
> try { print(JSON.parse("0123")) } catch (x) { print(x) }
< SyntaxError: Error parsing JSON
-
> try { print(JSON.parse("-.e-33")) } catch (x) { print(x) }
< SyntaxError: Error parsing JSON
-
> try { print(JSON.parse("-.456e-33")) } catch (x) { print(x) }
< SyntaxError: Error parsing JSON
-
> try { print(JSON.parse("-23.e-33")) } catch (x) { print(x) }
< SyntaxError: Error parsing JSON
-
> try { print(JSON.parse("23+23")) } catch (x) { print(x) }
< SyntaxError: Error parsing JSON
-
> print(JSON.parse('""'));
< 
-
> print(JSON.parse('"abcd"'));
< abcd
-
> print(JSON.parse('"abcd\\n\\tefgh\\/\\\\\\\""'));
< abcd
< 	efgh/\"
-
> print(JSON.parse('"\\u0047 \\u004f \\u004C"'));
< G O L
-
> try { print(JSON.parse('"')) } catch (x) { print(x) }
< SyntaxError: Error parsing JSON
-
> try { print(JSON.parse('"\u0012"')) } catch (x) { print(x) }
< SyntaxError: Error parsing JSON
-
> try { print(JSON.parse('"\\u333g"')) } catch (x) { print(x) }
< SyntaxError: Error parsing JSON
-
> try { print(JSON.parse('"\\k"')) } catch (x) { print(x) }
< SyntaxError: Error parsing JSON
-
> print(JSON.stringify(JSON.parse('[]')));
< []
-
> print(JSON.stringify(JSON.parse('[ "bcd" ]')));
< ["bcd"]
-
> print(JSON.stringify(JSON.parse('[ "bcd"  , "fgh" ]')));
< ["bcd","fgh"]
-
> print(JSON.stringify(JSON.parse('[ "bcd", "fgh", [ 123.456e+11 ] ]')));
< ["bcd","fgh",[12345600000000]]
-
> print(JSON.stringify(JSON.parse('["bcd","fgh",[123.456e+11]]')));
< ["bcd","fgh",[12345600000000]]
-
> print(JSON.stringify(JSON.parse('["bcd","fgh",[123.456e+11], null, true, false]')));
< ["bcd","fgh",[12345600000000],null,true,false]
-
> try { print(JSON.stringify(JSON.parse('['))) } catch (x) { print(x) }
< SyntaxError: Error parsing JSON
-
> try { print(JSON.stringify(JSON.parse('[ "a":"b" ]'))) } catch (x) { print(x) }
< SyntaxError: Error parsing JSON
-
> try { print(JSON.stringify(JSON.parse('[ "a" "b" ]'))) } catch (x) { print(x) }
< SyntaxError: Error parsing JSON
-
> try { print(JSON.stringify(JSON.parse('[ "a","b", ]'))) } catch (x) { print(x) }
< SyntaxError: Error parsing JSON
-
> try { print(JSON.stringify(JSON.parse('[ "a",,"b" ]'))) } catch (x) { print(x) }
< SyntaxError: Error parsing JSON
-
> print(JSON.stringify(JSON.parse('{}')));
< {}
-
> print(JSON.stringify(JSON.parse('{ "a": "bcd" }')));
< {"a":"bcd"}
-
> print(JSON.stringify(JSON.parse('{ "a": "bcd"  , "e": "fgh" }')));
< {"e":"fgh","a":"bcd"}
-
> print(JSON.stringify(JSON.parse('{ "a": "bcd", "e": "fgh", "f": { "g\u004C": 123.456e+11 } }')));
< {"e":"fgh","f":{"gL":12345600000000},"a":"bcd"}
-
> print(JSON.stringify(JSON.parse('{"a":"bcd","e":"fgh","f":{"g\u004C":123.456e+11}}')));
< {"e":"fgh","f":{"gL":12345600000000},"a":"bcd"}
-
> try { print(JSON.stringify(JSON.parse('{'))) } catch (x) { print(x) }
< SyntaxError: Error parsing JSON
-
> try { print(JSON.stringify(JSON.parse('{ a:"b" }'))) } catch (x) { print(x) }
< SyntaxError: Error parsing JSON
-
> try { print(JSON.stringify(JSON.parse('{ "a" }'))) } catch (x) { print(x) }
< SyntaxError: Error parsing JSON
-
> try { print(JSON.stringify(JSON.parse('{ "a": }'))) } catch (x) { print(x) }
< SyntaxError: Error parsing JSON
-
> try { print(JSON.stringify(JSON.parse('{ "a":"b" "c":"d" }'))) } catch (x) { print(x) }
< SyntaxError: Error parsing JSON
-
> try { print(JSON.stringify(JSON.parse('{ "a":"b","c":"d", }'))) } catch (x) { print(x) }
< SyntaxError: Error parsing JSON
-
> try { print(JSON.stringify(JSON.parse('{ "a":"b",,"c":"d" }'))) } catch (x) { print(x) }
< SyntaxError: Error parsing JSON
-
> print(JSON.stringify(JSON.parse('{"a":"bcd","e":"fgh","f":{"g\u004C":123.456e+11}}', function(k, v) { return (k === "gL" ? "qwertyiop" : v) })));
< {"e":"fgh","f":{"gL":"qwertyiop"},"a":"bcd"}
-
> try { print(JSON.stringify(JSON.parse("[1eE2]"))) } catch (x) { print(x) }
< SyntaxError: Error parsing JSON
-
> var s = ''; for (var i = 0; i < 63; ++i) s += '['; s += '234'; for (var i = 0; i < 63; ++i) s += ']'; try { print(JSON.stringify(JSON.parse(s))) } catch (x) { print(x) }
< TypeError: Structure too deeply nested for JSON conversion
-
> var s = ''; for (var i = 0; i < 62; ++i) s += '['; s += '234'; for (var i = 0; i < 62; ++i) s += ']'; try { print(JSON.stringify(JSON.parse(s))) } catch (x) { print(x) }
< [[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[234]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]
-
> var s = ''; for (var i = 0; i < 62; ++i) s += '['; s += '234'; for (var i = 0; i < 62; ++i) s += ']'; try { print(JSON.stringify([JSON.parse(s)])) } catch (x) { print(x) }
< TypeError: Structure too deeply nested for JSON conversion
-
> print(JSON.stringify(new Date("2019-03-03T04:00:03.000Z")))
< "2019-03-03T04:00:03.000Z"
-
> print(JSON.stringify(new Date(Infinity)))
< null
-
