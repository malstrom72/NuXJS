> print("abcd".indexOf("a"))
< 0
-
> print("abcd".indexOf("d"))
< 3
-
> print("abcd".indexOf("e"))
< -1
-
> print("abcd".indexOf("abc"))
< 0
-
> print("abcd".indexOf("bcd"))
< 1
-
> print("abcd".indexOf("cde"))
< -1
-
> print("abcd".indexOf("efghijkl"))
< -1
-
> print("abcdabcd".indexOf("a"))
< 0
-
> print("abcdabcd".indexOf("abcd"))
< 0
-
> print("abcdabcde".indexOf("abcde"))
< 4
-
> print("aBcDAbCd".indexOf("AbCd"))
< 4
-
> print("".indexOf("a"))
< -1
-
> print("a".indexOf(""))
< 0
-
> print("abcd".indexOf(""))
< 0
-
> print("abcd".indexOf("a", 0))
< 0
-
> print("abcd".indexOf("a", 1))
< -1
-
> print("abcdabcd".indexOf("abcd", 1))
< 4
-
> print("abcdabcd".indexOf("abcd", 4))
< 4
-
> print("abcdabcd".indexOf("abcd", 5))
< -1
-
> print("abcdabcd".indexOf("d", 7))
< 7
-
> print("abcdabcd".indexOf("d", 8))
< -1
-
> print("abcdabcd".indexOf("d", Infinity))
< -1
-
> print("abcdabcd".indexOf("d", -1))
< 3
-
> print("abcdabcd".indexOf("d", -Infinity))
< 3
-
> print("abcdabcd".indexOf("d", "not a number"))
< 3
-
> print("abcdabcd".lastIndexOf("d"))
< 7
-
> print("abcdabcd".lastIndexOf("c"))
< 6
-
> print("abcdabcd".lastIndexOf("e"))
< -1
-
> print("abcdabcd".lastIndexOf("bcd"))
< 5
-
> print("abcdabcd".lastIndexOf("bcda"))
< 1
-
> print("abcdabcd".lastIndexOf("abcdabcd"))
< 0
-
> print("abcdabcd".lastIndexOf("abcdabcde"))
< -1
-
> print("abcdabcd".lastIndexOf(""))
< 8
-
> print("abcdabcd".lastIndexOf("d",8))
< 7
-
> print("abcdabcd".lastIndexOf("d",7))
< 7
-
> print("abcdabcd".lastIndexOf("d",6))
< 3
-
> print("abcdabcd".lastIndexOf("d",3))
< 3
-
> print("abcdabcd".lastIndexOf("d",2))
< -1
-
> print("abcdabcd".lastIndexOf("d",0))
< -1
-
> print("abcdabcd".lastIndexOf("d",-1))
< -1
-
> print("abcdabcd".lastIndexOf("d",-100))
< -1
-
> print("abcdabcd".lastIndexOf("d",Infinity))
< 7
-
> print("abcdabcd".lastIndexOf("d",-Infinity))
< -1
-
> print("abcdabcd".lastIndexOf("c", "not a number"))
< 6
-
