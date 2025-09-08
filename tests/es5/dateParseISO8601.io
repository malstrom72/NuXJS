> print(Date.parse("1970-01-01T00:00:00Z") === 0);
< true
-
> print(isNaN(Date.parse("1970-01-01T00:00:00Zjunk")));
< true
-
