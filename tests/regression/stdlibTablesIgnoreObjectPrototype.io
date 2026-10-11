// The standard library's internal lookup tables must not see keys added to Object.prototype.
> Object.prototype[String.fromCharCode(0xE9)] = 8
> print(/\w/.test(String.fromCharCode(0xE9)))
< false
-
> Object.prototype["zq,false,false"] = function () { }
> print("zq".replace(/zq/, "ok") + " " + new RegExp("zq").test("abczq"))
< ok true
-
> Object.prototype.x = "global"
> try { print(new RegExp("a", "x").global) } catch (e) { print(e.name) }
< SyntaxError
-
> var re = new RegExp("a", "gim")
> print(re.global + " " + re.ignoreCase + " " + re.multiline + " " + "aAa".replace(/a/gi, "b"))
< true true true bbb
-
