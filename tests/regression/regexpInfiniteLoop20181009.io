> print(/[^ ]/.test(""))
< false
-
> print(JSON.stringify(/((?!koala)[^ ])*/.exec("koaala")))
< ["koaala","a"]
-
> print(/[^ ]*/.test("koaala"))
< true
-
