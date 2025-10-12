> var script = "function namedF() {\n" +
> "a=3\n" +
> "helper.callProp();\n" +
> "}\n" +
> "var helper = {};\n" +
> "helper.callProp = function() {\n" +
> "b=5\n" +
> "callNamed();\n" +
> "}\n" +
> "function callNamed() {\n" +
> "a=null;\n" +
> "helper.inner();\n" +
> "}\n" +
> "helper.inner = function() {\n" +
> "a.x=null;\n" +
> "}\n" +
> "namedF();\n" +
> "print(a);\n";
> try {
> 	eval(script);
> 	namedF();
> } catch (err) {
> 	var frames = err.stack.split("\n");
> 	print(frames[1].indexOf("at callNamed (") < 0);
> 	print(frames[2].indexOf("at callNamed (") >= 0);
> 	print(frames[3].indexOf("at namedF (") < 0);
> 	print(frames[4].indexOf("at namedF (") >= 0);
> 	print(frames[1].indexOf(":15:") >= 0);
> 	print(frames[2].indexOf(":12:") >= 0);
> 	print(frames[3].indexOf(":8:") >= 0);
> 	print(frames[4].indexOf(":3:") >= 0);
> 	print(frames[5].indexOf(":17:") >= 0);
> }
< true
< true
< true
< true
< true
< true
< true
< true
< true
-
