> try {
>	({}).notAFunction();
> } catch (err) {
>	print(err instanceof TypeError);
>	print(err.hasOwnProperty("stack"));
>	print(typeof err.stack === "string");
>	print(err.stack.indexOf("TypeError") === 0);
> }
< true
< true
< true
< true
-
