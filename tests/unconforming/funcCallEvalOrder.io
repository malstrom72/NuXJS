> function a() { print("a") }
> function b() { print("b") }
> o = { f: a };
> o.f(o.f=b)
< b
-
