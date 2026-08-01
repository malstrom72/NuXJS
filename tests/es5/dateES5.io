// ES5.1 15.9.4.4 Date.now and 15.9.5.44 Date.prototype.toJSON, neither of which ES3 had.
> print(typeof Date.now + " " + (Date.now() > 1262304000000) + " " + Date.now.length)
< function true 0
> var d = Object.getOwnPropertyDescriptor(Date, "now"); print(d.writable + " " + d.enumerable + " " + d.configurable)
< true false true
-
// 15.9.5.44 is fully generic: ToObject the receiver, ToPrimitive it with hint Number, and call whatever
// toISOString it carries. It is not tied to a real Date at all.
> print(Date.prototype.toJSON.call({ toISOString: function () { return "X"; } }))
< X
> print(Date.prototype.toJSON.call({ valueOf: function () { return 5; }, toISOString: function () { return "Y"; } }))
< Y
> var seen; Date.prototype.toJSON.call({ toISOString: function () { seen = (this.tag === "T"); return ""; }, tag: "T" }); print(seen)
< true
-
// Step 3 returns null for a non-finite time value, and step 5 throws when toISOString is not callable.
> print(String(new Date(NaN).toJSON()))
< null
> print(String(Date.prototype.toJSON.call({ valueOf: function () { return Infinity; }, toISOString: function () { return "Z"; } })))
< null
> try { Date.prototype.toJSON.call({}); print("no throw") } catch (e) { print(e.name) }
< TypeError
> try { Date.prototype.toJSON.call({ toISOString: 5 }); print("no throw") } catch (e) { print(e.name) }
< TypeError
-
// A real Date still round-trips through toISOString, and toJSON has length 1 (the ignored `key` argument).
> print(new Date(1318258080000).toJSON() + " " + Date.prototype.toJSON.length)
< 2011-10-10T14:48:00.000Z 1
> print(JSON.stringify({ d: new Date(0) }))
< {"d":"1970-01-01T00:00:00.000Z"}
-
