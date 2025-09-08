> var o = {};
> Object.preventExtensions(o);
> try { Object.defineProperty(o, "x", { value: 1 }); } catch (e) { print(e instanceof TypeError); }
< true
-
> print("x" in o);
< false
