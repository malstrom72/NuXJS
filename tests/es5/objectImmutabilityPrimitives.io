> try { Object.preventExtensions(1); } catch (e) { print(e instanceof TypeError); }
< true
-
> try { Object.seal('x'); } catch (e) { print(e instanceof TypeError); }
< true
-
> try { Object.freeze(true); } catch (e) { print(e instanceof TypeError); }
< true
-
> print(Object.isExtensible(1));
< false
-
> print(Object.isSealed(1));
< true
-
> print(Object.isFrozen(1));
< true
