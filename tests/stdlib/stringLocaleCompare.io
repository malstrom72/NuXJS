> print("a".localeCompare("a"))
< 0
-
> print("a".localeCompare("A"))
< 1
-
> print("a".localeCompare("b"))
< -1
-
> print("b".localeCompare("a"))
< 1
-
> print("aa".localeCompare("a"))
< 1
-
> print("a".localeCompare("aa"))
< -1
-
> print("".localeCompare("aa"))
< -1
-
> print("aa".localeCompare(""))
< 1
-
