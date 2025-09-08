> print(new Date(0).toISOString());
< 1970-01-01T00:00:00.000Z
-
> try { Date.prototype.toISOString.call({}); } catch (e) { print(e instanceof TypeError); }
< true
-
> try { new Date(NaN).toISOString(); } catch (e) { print(e instanceof RangeError); }
< true
-
