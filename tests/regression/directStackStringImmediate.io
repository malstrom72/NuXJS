> try {
>	throw new Error("direct immediate stack");
> } catch (err) {
>	print(err.hasOwnProperty("stack"));
>	print(typeof err.stack === "string");
>	print(err.stack.indexOf("direct immediate stack") >= 0);
>	print(!err.propertyIsEnumerable("stack"));
> }
< true
< true
< true
< true
-
