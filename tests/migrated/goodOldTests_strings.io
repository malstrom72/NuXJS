> print("abcdefgh"[0]);
> print("abcdefgh"[4]);
> print("abcdefgh"[8]);
> print("abcdefgh"[-1]);
> print("abcdefgh".length);
> s = "abcdefgh"; s = s[0] + s[3] + s[7] + s[1]; print(s);
> s = "0123456789"; print(s.length); s.length = 0; print(s.length); // both output 10, string lengths are not writable
> /*print("multi\
> line string");*/
> print("line\nfeed\ttab\'single quotes\'\n\"double quotes\" back\\slash  \b\b xxx \f \x40 \rcr");
> print("\u1234"[0] === String.fromCharCode(1234));
> print("\u1234"[0] === String.fromCharCode(0x1234));
< a
< e
< undefined
< undefined
< 8
< adhb
< 10
< 10
< line
< feed	tab'single quotes'
< "double quotes" back\slash   xxx  @ cr
< false
< true
-
