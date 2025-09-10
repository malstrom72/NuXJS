> function f() {
>  var a = 1, b = 2;
>  try {
>   throw "oops";
>  } catch (b) {
>   b = 3;
>   print(b);
>   try {
>    throw "oops again";
>   } catch (b) {
>    var b = 4;
>    print(b);
>   }
>   try {
>    throw "oops yet another time";
>   } catch (a) {
>    a = 5;
>    print(a);
>    print(b);
>   }
>   try {
>    throw "final throw";
>   } catch (c) {
>    c = 6;
>   }
>  }
>  var c = 7;
>  print(c);
> }
> f()
< 3
< 4
< 5
< 3
< 7
-
