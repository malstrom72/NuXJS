> print(eval('a=[]; for (a[0] in "abcd") print(a[0])'))
< 0
< 1
< 2
< 3
< undefined
-
> print(eval('a=[]; "hellu"; for (a[0] in "abcd") "there"'))
< there
-
> print(eval('a=[]; "hellu"; for (a[0] in "abcd") if (false) "there"'))
< hellu
-
> print(eval('a=[]; "hellu"; for (a[0] in "abcd") if (true) break'))
< hellu
-
> print(eval('a=[]; out: { "hellu"; for (a[0] in "abcd") if (true) break out }'))
< hellu
-
> print(eval('a=[]; out: { "hellu"; for (a[23+57-(23+57)] in "abcd") if (true) break out }'))
< hellu
-
> print(eval('a=[]; out: { "hellu"; for (a[23+57-(23+57)] in "abcd") { if (true) continue; "there" } }'))
< hellu
-
> print(eval('a=[]; out: { "hellu"; for (a[23+57-(23+57)] in "abcd") { if (false) continue; "there" } }'))
< there
-
> print(eval('a=[]; out: { "hellu"; for (a[(function() { print("tick"); return 0 })()] in "abcd") { if (false) continue; "there" } }'))
< tick
< tick
< tick
< tick
< there
-
> print(eval('a={}; for (a.x in "abcd") print(a.x)'))
< 0
< 1
< 2
< 3
< undefined
-
> print((function(){a=[]; for (a[0] in "abcd") print(a[0])})())
< 0
< 1
< 2
< 3
< undefined
-
> print((function(){a=[]; "hellu"; for (a[0] in "abcd") "there"})())
< undefined
-
> print((function(){a=[]; "hellu"; for (a[0] in "abcd") if (false) "there"})())
< undefined
-
> print((function(){a=[]; "hellu"; for (a[0] in "abcd") if (true) break})())
< undefined
-
> print((function(){a=[]; out: { "hellu"; for (a[0] in "abcd") if (true) break out }})())
< undefined
-
> print((function(){a=[]; out: { "hellu"; for (a[23+57-(23+57)] in "abcd") if (true) return "there" }})())
< there
-
> print((function(){a=[]; out: { "hellu"; for (a[23+57-(23+57)] in "") if (true) return "there" }})())
< undefined
-
> print((function(){a=[]; out: { "hellu"; for (a[23+57-(23+57)] in "abcd") { if (true) continue; "there" } }})())
< undefined
-
> print((function(){a=[]; out: { "hellu"; for (a[23+57-(23+57)] in "abcd") { if (false) continue; "there" } }})())
< undefined
-
> print((function(){a=[]; out: { "hellu"; for (a[(function() { print("tick"); return 0 })()] in "abcd") { if (false) continue; "there" } }})())
< tick
< tick
< tick
< tick
< undefined
-
> print((function(){a={}; for (a.x in "abcd") print(a.x)})())
< 0
< 1
< 2
< 3
< undefined
-
