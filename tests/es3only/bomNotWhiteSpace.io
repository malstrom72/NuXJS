// ES3 7.2 does not list the byte order mark, which only ES5.1 moved out of the 7.1 format control set
// and into WhiteSpace. tests/es5/whiteSpaceSet.io asserts the opposite for the es5 build.
> print(/\s/.test("\ufeff"))
< false
-
> print(isNaN(Number("\ufeff1")))
< true
-
> print(isNaN(parseInt("\ufeff1")))
< true
-
