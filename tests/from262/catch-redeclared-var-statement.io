> foo = "prior to throw";
>   try {
>     throw new Error();
>   }
>   catch (foo) {
>     var foo = "initializer in catch";
>   };
> print(foo);
< prior to throw
-
