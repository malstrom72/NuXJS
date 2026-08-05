// ES5.1 9.10 CheckObjectCoercible / 9.9 ToObject: step 1 of these methods rejects a null or undefined this value
// with a TypeError. In ES3 the global object was substituted at frame entry (10.4.3) and the step was unreachable,
// which is what tests/es3only/globalsFromUndefinedOrNullThis.io still records for that build.
// 15.5.4.4-19, all seventeen String.prototype methods that begin with CheckObjectCoercible.
> var S = String.prototype, thrown = 0, n = 0;
> var m = ["charAt","charCodeAt","concat","indexOf","lastIndexOf","localeCompare","match","replace","search",
>		"slice","split","substr","substring","toLocaleLowerCase","toLocaleUpperCase","toLowerCase","toUpperCase"];
> for (var i = 0; i < m.length; ++i) {
>	for (var j = 0; j < 2; ++j) {
>		++n;
>		try { S[m[i]].call(j ? null : undefined, "a", "b") } catch (e) { if (e instanceof TypeError) ++thrown; }
>	}
> }
> print(n + " " + thrown)
< 34 34
-
// The message names the method, so a borrowed built-in says which one was misused.
> try { String.prototype.charAt.call(null, 0) } catch (e) { print(e.message) }
< String.prototype.charAt called on null or undefined
-
// 15.4.4.4, .5, .10 and .3: the generic Array.prototype methods take ToObject(this) as step 1.
> var A = Array.prototype, thrown = 0, n = 0;
> var m = ["concat","join","slice","toLocaleString"];
> for (var i = 0; i < m.length; ++i) {
>	for (var j = 0; j < 2; ++j) {
>		++n;
>		try { A[m[i]].call(j ? null : undefined) } catch (e) { if (e instanceof TypeError) ++thrown; }
>	}
> }
> print(n + " " + thrown)
< 8 8
-
> try { Array.prototype.join.call(undefined) } catch (e) { print(e.message) }
< Array.prototype.join called on null or undefined
-
// 15.2.4.3, .4, .5 and .7 on Object.prototype. The natives behind hasOwnProperty and propertyIsEnumerable answer
// false for a non-object rather than throwing, so the step is spelled out in the library.
> var O = Object.prototype, thrown = 0, n = 0;
> var m = ["hasOwnProperty","propertyIsEnumerable","toLocaleString","valueOf"];
> for (var i = 0; i < m.length; ++i) {
>	for (var j = 0; j < 2; ++j) {
>		++n;
>		try { O[m[i]].call(j ? null : undefined, "x") } catch (e) { if (e instanceof TypeError) ++thrown; }
>	}
> }
> print(n + " " + thrown)
< 8 8
-
// 15.2.4.6 tests V before ToObject(this), so a primitive V answers false even with a null this value.
> print(Object.prototype.isPrototypeOf.call(null, 5))
< false
> try { Object.prototype.isPrototypeOf.call(null, {}) } catch (e) { print(e.name) }
< TypeError
> try { Object.prototype.isPrototypeOf.call(undefined, {}) } catch (e) { print(e.name) }
< TypeError
-
// Number.prototype.toLocaleString and Date.prototype.toLocaleString are the same function object as
// Object.prototype.toLocaleString in this implementation, so they inherit the step. (DEVIATION: 15.7.4.2 and
// 15.9.5.5 specify three distinct functions.)
> try { Number.prototype.toLocaleString.call(null) } catch (e) { print(e.name) }
< TypeError
> try { Date.prototype.toLocaleString.call(null) } catch (e) { print(e.name) }
< TypeError
-
// 15.2.4.4 returns ToObject(this), so a primitive receiver comes back boxed rather than raw.
> print(typeof Object.prototype.valueOf.call(5))
< object
> var o = {}; print(Object.prototype.valueOf.call(o) === o)
< true
-
// None of this disturbs the ordinary paths, including the borrowed and generic ones.
> print("abc".charAt(1) + String.prototype.charAt.call(new String("abc"), 1) + String.prototype.charAt.call(12345, 2))
< bb3
> print(String.prototype.charAt.call({ toString: function () { return "xyz" } }, 1))
< y
> print(Array.prototype.join.call({ 0: "a", 1: "b", length: 2 }, "-") + " " + Array.prototype.slice.call("abc", 1).join(""))
< a-b bc
> print(Object.prototype.hasOwnProperty.call("ab", "0") + " " + Object.prototype.toLocaleString.call([1, 2]))
< true 1,2
-
