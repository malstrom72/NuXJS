// ES5.1 7.6.1.2: the future reserved words (implements, interface, let, package, private, protected, public,
// static, yield) may not be used as identifiers in strict mode. Verified against V8.
// Each is a SyntaxError as a variable name in strict mode.
> function check(word) {
>   try { eval('"use strict"; var ' + word + ' = 1;'); return "OK"; } catch (e) { return e.name; }
> }
> var words = ["implements", "interface", "let", "package", "private", "protected", "public", "static", "yield"];
> for (var i = 0; i < words.length; ++i) print(words[i] + ": " + check(words[i]));
< implements: SyntaxError
< interface: SyntaxError
< let: SyntaxError
< package: SyntaxError
< private: SyntaxError
< protected: SyntaxError
< public: SyntaxError
< static: SyntaxError
< yield: SyntaxError
-
// Reserved as references, function names, parameters, and catch parameters.
> try { eval('"use strict"; yield;'); print("no error") } catch (e) { print(e.name) }
< SyntaxError
> try { eval('"use strict"; function static() {}'); print("no error") } catch (e) { print(e.name) }
< SyntaxError
> try { eval('"use strict"; function f(public) {}'); print("no error") } catch (e) { print(e.name) }
< SyntaxError
> try { eval('function f(public) { "use strict"; }'); print("no error") } catch (e) { print(e.name) }
< SyntaxError
> try { eval('"use strict"; try {} catch (let) {}'); print("no error") } catch (e) { print(e.name) }
< SyntaxError
-
// They remain valid as property names even in strict mode.
> "use strict";
> var o = { public: 1, let: 2, "class": 3 }; print(o.public + o.let + o["class"])
< 6
-
// In non-strict code they are ordinary identifiers.
> var let = 1; var yield = 2; function f(static) { return static; }
> print(let + yield); print(f(10))
< 3
< 10
-
