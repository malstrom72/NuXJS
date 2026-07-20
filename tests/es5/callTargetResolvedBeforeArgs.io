// ES5.1 11.2.3: GetValue on the callee happens before the arguments are evaluated, so an argument
// expression that replaces the method does not change which function is called (ES3 called "b").
> function a() { print("a"); }
> function b() { print("b"); }
> var o = { f: a };
> o.f(o.f = b);
< a
-
// The same holds when the getter itself is the mutation point.
> var calls = []; var m = {
>	get f() { calls.push("fetch"); return function (x) { calls.push("run " + x); }; }
> };
> m.f((calls.push("arg"), 1)); print(calls.join(","))
< fetch,arg,run 1
-
