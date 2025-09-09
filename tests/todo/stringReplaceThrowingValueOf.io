> try { "a".replace("a", { valueOf: function(){ throw new Error("Y"); } }); } catch (e) { print(e.message); }
< Y
-
