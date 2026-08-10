// ES5.1 15.10.6: the RegExp prototype object is itself a regular expression object, its [[Class]] "RegExp" and
// its 15.10.7 data properties set as if by `new RegExp()`. ES3 15.10.6 says the same but the es3 build has always
// handed out a plain object there, so this is guarded and has no es3 twin. ES2015 reverted the whole idea, making
// the prototype ordinary with accessors that throw, so V8 is not an oracle here and the spec text is.
> print(Object.prototype.toString.call(RegExp.prototype))
< [object RegExp]
-
// 15.10.7.1-.5: source, global, ignoreCase and multiline are own, non-writable, non-enumerable, non-configurable.
> var p = RegExp.prototype, m = ["source", "global", "ignoreCase", "multiline"], out = [];
> for (var i = 0; i < m.length; ++i) { var d = Object.getOwnPropertyDescriptor(p, m[i]); out.push(d.writable + "" + d.enumerable + d.configurable); }
> print(out.join(" "))
< falsefalsefalse falsefalsefalse falsefalsefalse falsefalsefalse
-
// 15.10.7.5: lastIndex is the writable one.
> var d = Object.getOwnPropertyDescriptor(RegExp.prototype, "lastIndex");
> print(d.value + " " + d.writable + " " + d.enumerable + " " + d.configurable)
< 0 true false false
-
// The values are those of `new RegExp()`, and the prototype chain and constructor are untouched by all this.
> var p = RegExp.prototype;
> print([p.source === "", p.global, p.ignoreCase, p.multiline, p.constructor === RegExp, Object.getPrototypeOf(p) === Object.prototype].join(" "))
< true false false false true true
-
// Being a real RegExp, the prototype answers exec and test rather than throwing, matching empty wherever tried.
// This is what pins the hand-written matcher in stdlib.js against compileRegExp's output for the empty pattern.
> print(JSON.stringify(RegExp.prototype.exec("abc")) + " " + RegExp.prototype.exec("abc").index + " " + RegExp.prototype.test("abc") + " " + RegExp.prototype.toString())
< [""] 0 true //
-
> var r = new RegExp();
> print(JSON.stringify(r.exec("abc")) + " " + r.exec("abc").index + " " + r.test("abc") + " " + r.toString())
< [""] 0 true //
-
// None of it disturbs ordinary instances, which still take the prototype and keep their own properties.
> print([/a/.source, /ab/g.global, /a/i.ignoreCase, /a/m.multiline, Object.getPrototypeOf(/a/) === RegExp.prototype].join(" "))
< a true true true true
-
> print(/b(c)/.exec("abc") + " | " + "xaybz".replace(/[abz]/g, "-") + " | " + /x/.test("axb") + " | " + "a1b2".split(/\d/).join(","))
< bc,c | x-y-- | true | a,b,
-
