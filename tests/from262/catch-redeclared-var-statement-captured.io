> function capturedFoo() {return foo};
>   foo = "prior to throw";
>   try {
>     throw new Error();
>   }
>   catch (foo) {
>     var foo = "initializer in catch";
>   };
> print(capturedFoo());
< prior to throw
-
