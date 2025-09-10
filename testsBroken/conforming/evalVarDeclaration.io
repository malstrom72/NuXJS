> function a() {
>   function b() {
>     x += 1;
>   };
>   b();
>   eval("var x = 125");
>   b();
>   print("local x: " + x);
> };
> var x = 9876;
> a();
> print("global x: " + x);
< local x: 126
< global x: 9877
-
