> print("hello there".search("there"))
< 6
-
> print("hello there".search("zhere"))
< -1
-
> print("hello there".search(""))
< 0
-
> print("hello there".search("e$"))
< 10
-
> print("hello there".search("$"))
< 11
-
> print("hello there".search("tHe"))
< -1
-
> print("hello there".search(/tHe/i))
< 6
-
> var re = new RegExp(/e/g)
> print("hello there".search(re))
< 1
-
