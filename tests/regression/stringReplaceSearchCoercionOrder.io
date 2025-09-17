> var order = [];
> var search = { toString: function() { order.push("search"); throw "search"; }, valueOf: function() { order.push("search valueOf"); throw "search valueOf"; } };
> var replace = { toString: function() { order.push("replace"); throw "replace"; }, valueOf: function() { order.push("replace valueOf"); throw "replace valueOf"; } };
> try { "".replace(search, replace); } catch (e) { print(e === "search"); }
> print(order.join(","));
> order = [];
> search = { toString: function() { order.push("search"); return "a"; }, valueOf: function() { order.push("search valueOf"); return "a"; } };
> replace = { toString: function() { order.push("replace"); return "b"; }, valueOf: function() { order.push("replace valueOf"); return "b"; } };
> print("ax".replace(search, replace));
> print(order.join(","));
