> var called = false
> var subject = { toString: function() { return {}; }, valueOf: function() { called = true; return "aabaac"; } }
> var r = /(aa|aabaac|ba|b|c)*/.exec(subject)
> print(r[0])
> print(r.index)
> print(r.input)
> print(called)
< aaba
< 0
< aabaac
< true
-
