> try { Object.defineProperty(1, "x", { value: 1 }); } catch (e) { print(e instanceof TypeError); }
< true
-
> try { Object.defineProperties(1, { a: { value: 1 } }); } catch (e) { print(e instanceof TypeError); }
< true
-
