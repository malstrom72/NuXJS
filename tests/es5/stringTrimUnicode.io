> print("\u1680foo\u3000".trim())
< foo
-
> print("\u2000bar".trimLeft())
< bar
-
> print("baz\u205F".trimRight())
< baz
-
> print("\uFEFFqux\uFEFF".trim())
< qux
-
