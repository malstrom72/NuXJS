// Each call evals a closure inside the previous one, so name lookup walks 20000 scopes; it used to recurse and overflow the C++ stack.
> var src = "(function () { return eval(src) })"
> var g = eval(src)
> for (var i = 0; i < 20000; ++i) g = g()
> print(typeof g)
< function
-
