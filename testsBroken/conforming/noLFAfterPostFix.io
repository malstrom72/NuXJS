> var a = 0, b = 1;
> a
> ++
> b
> print(a);
> print(b);
< 0
< 2
-
> try { eval("a\n++"); } catch (e) { print(e.name) }
< SyntaxError
-
> var a = 0, b = 1;
> a
> --
> b
> print(a);
> print(b);
< 0
< 0
-
> try { eval("a\n--"); } catch (e) { print(e.name) }
< SyntaxError
-
> var a=1,b=2,c=3;
> a=b
> ++c
> print(a);
> print(b);
> print(c);
< 2
< 2
< 4
-
