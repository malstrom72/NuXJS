> if (false && false || true && true) print("ok"); else print("oops");
> if (!(false && true || true && false)) print("ok"); else print("oops")
> if (!(true && false || false && true)) print("ok"); else print("oops");
> if (false && true || true && false || !(false && false)) print("ok"); else print("oops")
> if ((3<5 && 5<3 || 2==3 && 2==2) || !(3>4 || 7<5)) print("ok"); else print("oops");
> if ((3<5 && 5<3 || 2==3 && 2==2) || !(3>4 || 5<7)) print("oops"); else print("ok");
> print ((3<5 && 5<3 || 2==3 && 2==2) || !(3>4 || 7<5) ? ("ok") : ("oops"));
< ok
< ok
< ok
< ok
< ok
< ok
< ok
-
