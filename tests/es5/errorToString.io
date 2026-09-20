// 15.11.4.4 (8-10), es5 build only (the shared toString in tests/stdlib/errorPrototypes.io keeps ES3's
// implementation-defined shape): an empty name yields the message alone, an empty message the name alone,
// and a falsy-but-present message still prints.
> var e = new Error("ErrorMessage"); e.name = ""; print("[" + e + "]")
< [ErrorMessage]
> var e2 = new Error(); e2.name = ""; print("[" + e2 + "]")
< []
> var e3 = new Error("m"); e3.name = "N"; print("[" + e3 + "]")
< [N: m]
> var e4 = new Error(); e4.name = "N"; e4.message = 0; print("[" + e4 + "]")
< [N: 0]
-
// 15.11.4.4 step 1 rejects a non-object receiver. Reaching it at all needs the entry to be strict: 10.4.3 would
// otherwise box the primitive into the global object and report ITS name and message as the error's.
> var name = "GLOBALNAME", message = "GLOBALMSG";
> var r = []; var vs = [null, void 0, "x", 5, true];
> for (var i = 0; i < vs.length; ++i) { try { r.push(Error.prototype.toString.call(vs[i])) } catch (e) { r.push(e.name) } }
> print(r.join(","))
< TypeError,TypeError,TypeError,TypeError,TypeError
-
// An ordinary object is fine, and picks up the inherited empty message.
> print("[" + Error.prototype.toString.call({}) + "]")
< [Error]
-
// Steps 2 and 5 read name and message ONCE each; reading either twice shows up as the second value.
> var i = 0, j = 0;
> var probe = { get name() { return ["A", "B"][i++] }, get message() { return ["M1", "M2"][j++] } };
> print(Error.prototype.toString.call(probe) + " " + i + j)
< A: M1 11
-
