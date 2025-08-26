> var s = " \tfoo \n";
-
> print(s.trimLeft().charCodeAt(0));
< 102
-
> print(s.trimLeft().charCodeAt(s.trimLeft().length - 1));
< 10
-
> print(s.trimRight().charCodeAt(0));
< 32
-
> print(s.trimRight().charCodeAt(s.trimRight().length - 1));
< 111
-
