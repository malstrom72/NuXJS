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
