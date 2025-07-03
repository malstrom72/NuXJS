> function buildProtoChain(n) { var o = { x: " stop", top: "top" }, f = function() { this.x = i; this[i] = "plupp"; };  for (var i = 0; i < n; ++i) { f.prototype = o; o = new f; }; return o; }
> function checkProtoChain(o) { var count = 0, sum = 0, x = 1; print(o.top); do { found = x in o; print(x + ": " + found); x *= 2 } while (found); while ((o = Object.getPrototypeOf(o)) !== Object.prototype) { sum += o.x; ++count }; print(count); print(sum); }
-
> checkProtoChain(buildProtoChain(10))
< top
< 1: true
< 2: true
< 4: true
< 8: true
< 16: false
< 10
< 36 stop
-
> checkProtoChain(buildProtoChain(20))
< top
< 1: true
< 2: true
< 4: true
< 8: true
< 16: true
< 32: false
< 20
< 171 stop
-
> checkProtoChain(buildProtoChain(31))
< top
< 1: true
< 2: true
< 4: true
< 8: true
< 16: true
< 32: false
< 31
< 435 stop
-
> checkProtoChain(buildProtoChain(40))
! !!!! RangeError: Prototype chain too long
-
> checkProtoChain(buildProtoChain(80))
! !!!! RangeError: Prototype chain too long
-
> checkProtoChain(buildProtoChain(10000))
! !!!! RangeError: Prototype chain too long
-
> checkProtoChain(buildProtoChain(32))
! !!!! RangeError: Prototype chain too long
-
> var o = buildProtoChain(31)
> o.qwerty = 'iop';
> print(delete o[1]);
> print(delete o[30]);
> var x = 0, a = []; for (var i in o) { a.push(i); }; a.sort(); print('' + a);
< true
< true
< 0,1,10,11,12,13,14,15,16,17,18,19,2,20,21,22,23,24,25,26,27,28,29,3,4,5,6,7,8,9,qwerty,top,x
-
