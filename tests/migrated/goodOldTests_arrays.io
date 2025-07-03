> emptyArray = [   ]  ;
> print(emptyArray.length);
> print(emptyArray[0]);
< 0
< undefined
-
> var x = 100;
> bigArray = [
>   1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10
> , 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10
> , 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10
> , 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10
> , 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10
> , 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10
>  , 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 1, 2, 3, 4, 5, 6, 7, 8, 9, 1000 / x ];
> (function() { for (var i = 0; i < bigArray.length; ++i) bigArray[i] = bigArray[i] * 1234; })();
> print(bigArray.length);
> print(bigArray[279]);
> print(bigArray[280]);
> bigArray[12345] = null;
> print(bigArray.length);
> bigArray[' 12346'] = 1;
> print(bigArray.length);
> print(bigArray[' 12346']);
> print(bigArray[12346]);
> bigArray['12346'] = "hola";
> print(bigArray[12346]);
> bigArray[-1.234] = 55;
> print(bigArray[-1]);
> print(bigArray[-1.234]);
> bigArray.length = 3;
> print(bigArray.length);
> print(bigArray[2]);
> print(bigArray[3]);
> print(bigArray[12345]);
< 280
< 12340
< undefined
< 12346
< 12346
< 1
< undefined
< hola
< undefined
< 55
< 3
< 3702
< undefined
< undefined
-
> newedArray = new Array(1,2,3,4);
> print(newedArray.length);
> print(newedArray[0]);
> print(newedArray[3]);
< 4
< 1
< 4
-
> newedArray = new Array();
> print(newedArray.length);
< 0
-
> /* FIX : should throw
> newedArray = new Array(-1);
> print(newedArray.length);
> print(newedArray[0]);
> */
-
> newedArray = new Array(50);
> print(newedArray.length);
< 50
-
> /* FIX : should throw
> newedArray = new Array(50.5);
> print(newedArray.length);
> print(newedArray[0]);
> */
-
> print(Array.prototype.length);
> print(delete Array.prototype.length);
> Array.prototype.patch = "patched";
> print(bigArray.patch);
> print(delete Array.prototype.patch);
< 0
< false
< patched
< true
-
> print("*** types ***")
< *** types ***
-
> print((function() { print(x); var x; print(x); x = void print("turn to void"); return x })());
< undefined
< undefined
< turn to void
< undefined
-
> (function() { var f = function() {
> var a;
> print(typeof a);
> print(typeof null);
> print(typeof false);
> print(typeof 3.5);
> print(typeof "zzz");
> print(typeof f);
> print(typeof "zzz"[1]);
> print(typeof "zzz"[5]);
> print(typeof doesNotExist);
> doesExist = "I exist";
> print(typeof doesExist);
> }; f(); })();
< undefined
< object
< boolean
< number
< string
< function
< string
< undefined
< undefined
< string
-
