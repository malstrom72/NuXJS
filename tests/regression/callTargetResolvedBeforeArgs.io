// CLI:
> function a() { print("a"); }
> function b() { print("b"); }
> var o = { f: a };
> o.f(o.f = b);
< b
-
