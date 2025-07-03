> s="abcdefgh";
> print(s[2]);
< c
-
> print(s['2'])
< c
-
> print(s['002'])
< undefined
-
> print(s['   2    '])
< undefined
-
> print(s['   +2e0 '])
< undefined
-
> print(s['   0x02   '])
< undefined
-
