> function callNativeImmediate() {
>	return (function innerNativeThrow() {
>		throw new Error("native immediate stack");
>	}).call(null);
> }
> try {
>	callNativeImmediate();
> } catch (err) {
>	print(err.hasOwnProperty("stack"));
>	print(typeof err.stack === "string");
>	print(err.stack.indexOf("native immediate stack") >= 0);
>	print(err.stack.indexOf("callNativeImmediate") >= 0);
> }
< true
< true
< true
< true
-
