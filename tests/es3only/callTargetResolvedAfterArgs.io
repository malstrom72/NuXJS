// ES3 11.2.3 evaluates the arguments before GetValue on the callee, so an argument expression that
// replaces the method changes which function is called. (ES5 twin: tests/es5/callTargetResolvedBeforeArgs.io.)
> function a() { print("a"); }
> function b() { print("b"); }
> var o = { f: a };
> o.f(o.f = b);
< b
-
