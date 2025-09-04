> var d = new Date(Date.UTC(2000, 0, 2, 3, 4, 5, 6)); print(d.toISOString());
< 2000-01-02T03:04:05.006Z
-
> print(d.toJSON());
< 2000-01-02T03:04:05.006Z
-
> try { new Date(NaN).toISOString(); } catch(e){ print(e instanceof RangeError); }
< true
-
> print(new Date(NaN).toJSON());
< null
-
