> function getArguments() { return arguments; }
> print(Object.getOwnPropertyDescriptor(getArguments(), 'caller') === undefined);
< true
-
