> var re = new RegExp(Array(201).join("(") + "hi" + Array(201).join(")"));
> var r = re.exec("hi");
> print(r.length);
< 201
-
