> var globals = this; var oj="eh"; try { throw function() { print(typeof this); print(this === globals); this.oj="hoppla" } } catch (x) { x(); print(oj); }; print(oj)
< object
< true
< hoppla
< hoppla
-
