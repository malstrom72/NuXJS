// CLI:
> try { "a".replace("a", { toString: function(){ throw new Error("X"); } }); } catch (e) { print(e.message); }
< X
-
