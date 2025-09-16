> function f(x) { var y = (x > 0 ? f(x - 1,1,2,3,4,5) : 0); return x * 10 + y; }
> try { print(f(10000, 1,2,3,4,5)) } catch (x) { print("failed as it should"); }
< failed as it should
-
