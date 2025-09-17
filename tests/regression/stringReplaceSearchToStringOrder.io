> var log = [];
> var search = { toString: function() { log.push("search"); return "a"; } };
> var replace = { toString: function() { log.push("replace"); return "b"; } };
> print("a".replace(search, replace));
< b
> print(log.join(","));
< search,replace
> log = [];
> search = { toString: function() { log.push("search-throw"); throw new Error("search"); } };
> replace = { toString: function() { log.push("replace"); return "b"; } };
> try { "a".replace(search, replace); } catch (e) { print(e.message); }
< search
> print(log.join(","));
< search-throw
-
