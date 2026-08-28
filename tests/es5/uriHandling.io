// 15.1.3: the four URI handlers, encoding and decoding over the spec's exact UTF-8 table. Output is kept ASCII
// (the REPL prints raw code units), so decoded non-ASCII is asserted through charCodeAt.
> print(encodeURI("http://a.se/x y#q?r=1&s;") + " | " + encodeURIComponent("http://a.se/x y#q"))
< http://a.se/x%20y#q?r=1&s; | http%3A%2F%2Fa.se%2Fx%20y%23q
-
// The unescaped set stays put in both, uriReserved and '#' only survive encodeURI.
> print(encodeURI("-_.!~*'();/?:@&=+$,#") + " | " + encodeURIComponent(";/?:@&=+$,#"))
< -_.!~*'();/?:@&=+$,# | %3B%2F%3F%3A%40%26%3D%2B%24%2C%23
-
// decodeURI keeps an escaped uriReserved character escaped (15.1.3.1 reservedURISet); decodeURIComponent frees it.
> print(decodeURI("a%3Fb%2Fc%20d") + " | " + decodeURIComponent("a%3Fb%2Fc%20d"))
< a%3Fb%2Fc d | a?b/c d
-
// Multi-byte round trips: 2-byte, 3-byte and an astral pair through 4 bytes.
> var s = String.fromCharCode(0xF6, 0x20AC) + "😀";
> var e = encodeURIComponent(s); print(e)
< %C3%B6%E2%82%AC%F0%9F%98%80
> var d = decodeURIComponent(e); var codes = ""; for (var i = 0; i < d.length; ++i) codes += d.charCodeAt(i).toString(16) + ",";
> print(d.length + " " + codes)
< 4 f6,20ac,d83d,de00,
-
// Malformed input is a URIError: lone surrogate halves on encode; on decode a truncated or non-hex escape, the
// overlong forms, the surrogate gap and anything past 0x10FFFF.
> function t(f) { try { f(); return "no throw"; } catch (e) { return e.name; } }
> print(t(function () { encodeURI("\uD800"); }) + t(function () { encodeURI("\uDC00x"); }))
< URIErrorURIError
> print(t(function () { decodeURI("%"); }) + t(function () { decodeURI("%GG"); }) + t(function () { decodeURI("%C3"); }))
< URIErrorURIErrorURIError
> print(t(function () { decodeURI("%C0%80"); }) + t(function () { decodeURI("%E0%80%80"); }))
< URIErrorURIError
> print(t(function () { decodeURI("%ED%A0%80"); }) + t(function () { decodeURI("%F5%80%80%80"); }) + t(function () { decodeURI("%C3%C3"); }))
< URIErrorURIErrorURIError
-
// The four are ordinary built-ins: length 1, writable, non-enumerable, configurable, not constructors.
> var ud = Object.getOwnPropertyDescriptor(this, "decodeURI");
> print(decodeURI.length + encodeURI.length + decodeURIComponent.length + encodeURIComponent.length + " " + ud.writable + ud.enumerable + ud.configurable)
< 4 truefalsetrue
> try { new encodeURI("x"); } catch (e) { print(e.name) }
< TypeError
-
// 15.2.3.4 on a String object: indices, then table properties, length last (the order 15.2.3.3-4-44 pins).
> var sw = new String("abc"); sw[5] = "de";
> print(Object.getOwnPropertyNames(sw).join(","))
< 0,1,2,5,length
-
