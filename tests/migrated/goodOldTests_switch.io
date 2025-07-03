> for(var x=-3;x<=3;++x)switch(x+3){case 1:case 2:case 1+2:print(x)}
< -2
< -1
< 0
-
> f = function(n) { print('test:' + n); };
> for (var x = -3; x <= 3; ++x) switch (  x + 3  )   { case 1  : case 2  : case f ( x )   , 1 + 3  : print(x) }
< test:-3
< -2
< -1
< test:0
< test:1
< 1
< test:2
< test:3
-
> switch (3) { case 2: print("NO"); default: print("HEJ"); case 3: print("3") }
< 3
-
> switch ("1") { case 1: print('1'); case "1": print('"1"'); case 2.0: print("continues to 2"); break; case "3": print("but not to 3"); case "1": print('Second "1" is not executed'); default: print("Neither is default") }
< "1"
< continues to 2
-
> switch (1.0) { case 0: print('0'); default: print('default'); case "1.0": print('1'); case "1": print('"1"'); case 2.0: print("continues to 2"); break; case "3": print("but not to 3"); case "1": print('Second "1" is not executed'); }
< default
< 1
< "1"
< continues to 2
-
> for (var i = 0; i < 10; ++i) { switch (i) { case 5: continue }; print(i) }
< 0
< 1
< 2
< 3
< 4
< 6
< 7
< 8
< 9
-
