> var script = "f=function() {\n" +
> "a=3\n" +
> "g();\n" +
> "}\n" +
> "g=function() {\n" +
> "b=5\n" +
> "a=null;\n" +
> "h();\n" +
> "}\n" +
> "h=function() {\n" +
> "a.x=null;\n" +
> "}\n" +
> "f()\n" +
> "print(a);\n";
> try {
>	eval(script);
>	f();
> } catch (err) {
>	var frames = err.stack.split("\n");
>	print(frames[1].indexOf("at h (") >= 0);
>	print(frames[2].indexOf("at g (") >= 0);
>	print(frames[3].indexOf("at f (") >= 0);
>	print(frames[1].indexOf(":11:") >= 0);
>	print(frames[2].indexOf(":8:") >= 0);
>	print(frames[3].indexOf(":3:") >= 0);
>	print(frames[4].indexOf(":13:") >= 0);
> }
< true
< true
< true
< true
< true
< true
< true
-
