// ES5.1 11.1.5 takes an IdentifierName, not an Identifier, as a PropertyName, and 11.2.1 does the same after the
// dot, so every ReservedWord (7.6.1) is usable as a property name. ES3 11.1.5 / 11.2.1 asked for an Identifier and
// so forbade all of them; NuXJS has always been lenient here, which is why this test is shared rather than an es5
// twin. See docs/notes/ECMAScript Compatibility Notes.md. Verified against V8.
> var words = ("break do instanceof typeof case else new var catch finally return void continue for switch while "
>		+ "debugger function this with default if throw delete in try class enum extends super const export import "
>		+ "implements let private public interface package protected static yield null true false").split(" ");
> function check() {
>	var bad = [];
>	for (var i = 0; i < words.length; ++i) {
>		var w = words[i];
>		try {
>			var o = eval("({ " + w + ": 1 })");							// 11.1.5 as a literal key
>			if (o[w] !== 1) bad.push(w + ":literalValue");
>			if (eval("(function (x) { return x." + w + " })")(o) !== 1) bad.push(w + ":dotGet");
>			eval("(function (x) { x." + w + " = 2 })")(o);				// 11.2.1 after the dot
>			if (o[w] !== 2) bad.push(w + ":dotSet");
>			if (eval("(function (x) { return delete x." + w + " })")(o) !== true) bad.push(w + ":dotDelete");
>			if (eval("({ " + w + ": 1, })." + w) !== 1) bad.push(w + ":trailingComma");
>			if (eval("'use strict'; ({ " + w + ": 3 })." + w) !== 3) bad.push(w + ":strict");
>		} catch (e) {
>			bad.push(w + ":" + e.name);
>		}
>	}
>	return words.length + " words, failures: " + (bad.length === 0 ? "none" : bad.join(" "));
> }
-
// 45 words: the 7.6.1.1 keywords, the 7.6.1.2 future reserved words including the strict-only ones, and the
// null / true / false literals, which 7.8.1 and 7.8.2 keep out of ReservedWord but 7.6 still makes IdentifierNames.
> print(check())
< 45 words, failures: none
-
// They are still reserved everywhere an Identifier is actually required, so this is a property-name rule only.
> try { eval("var if = 1"); print("no throw") } catch (e) { print(e.name) }
< SyntaxError
> try { eval("function for() {}"); print("no throw") } catch (e) { print(e.name) }
< SyntaxError
> try { eval("function f(new) {}"); print("no throw") } catch (e) { print(e.name) }
< SyntaxError
> try { eval("this: while (0) break this"); print("no throw") } catch (e) { print(e.name) }
< SyntaxError
-
// A reserved word reads back as an ordinary string key, so the bracket form and for-in agree with the dot form.
> var o = { "delete": 1 }; print(o.delete + " " + o["delete"] + " " + ("delete" in o) + " " + o.hasOwnProperty("delete"))
< 1 1 true true
> var o = { in: 1 }; var k = []; for (var p in o) k.push(p); print(k.join(",") + " " + typeof k[0])
< in string
-
