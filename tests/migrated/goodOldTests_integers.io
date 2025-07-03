> print(1 << 5 == 32)
> print(1 << 37 == 32)
> print(32 >> 5 == 1)
> print(32 >> 37 == 1)
> print(32 << -23 == 16384)
> print(16384 >> -23 == 32)
> print(-1 << 5 == -32)
> print(-1 << 37 == -32)
> print(-32 >> 5 == -1)
> print(-32 >> 37 == -1)
> print(-32 << -23 == -16384)
> print(-16384 >> -23 == -32)
> print(-16384 >>> 23 == 511)
> print(-16384 >>> -23 == 8388576)
> print(~~16384.9 == 16384);
> print(~~-16384.9 == -16384);
> print((-16384.9)>>0 == -16384);
> print(1<<31 == -2147483648);
> print(0xCFCFCFCF == 3486502863);
> print(-0xCFCFCFCF == -3486502863);
> print(~~0xCFCFCFCF == -808464433);
> print((80189565849)>>0 == -1414812775);
> print(-808464433>>>0 == 0xCFCFCFCF);
> print(1.0/0.0); // Should be Infinity
> print(-1.0/0.0);  // Should be -Infinity
> print(~~(1.0/0.0) == 0);
> print(~~(-1.0/0.0) == 0);
> print(+"q"); // Should be NaN
> print(~~(+"q") == 0);
> print(4294967295.0|0); // Should be -1
> print((-4294967295.0)|0); // Should be 1
> print(-4294967295.0|0); // Should be 1
> print(2147483648.0|0); // Should be -2147483648
> print(-2147483648.0|0); // Should be -2147483648
> print(4294967295>>>0); // Should be 4294967295
> print((-4294967295)>>>0); // Should be 1
< true
< true
< true
< true
< true
< true
< true
< true
< true
< true
< true
< true
< true
< true
< true
< true
< true
< true
< true
< true
< true
< true
< true
< Infinity
< -Infinity
< true
< true
< NaN
< true
< -1
< 1
< 1
< -2147483648
< -2147483648
< 4294967295
< 1
-
> var i = 0 ;  j = 1234.5; while (   i   <   100.0e+1   )  {  j = j + i ; ++ i  }
>  do { j = j - i * 0.5 } while ( i ++ < 2000 )
>  print (  i + ", " + j )  ;
< 2001, -250015.5
-
> var i=0;for(j=1234.5;1E3>i;)j+=i,++i;do j-=0.5*i;while(2E3>i++);print(i+", "+j);
< 2001, -250015.5
-
