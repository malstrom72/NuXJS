// ES5.1 10.6 Arguments Object. Twin of tests/es3only/Arguments3.io, which keeps the ES3 answers and carries these
// expectations as comments. Three things moved: the array indexed properties are enumerable (ES3 10.1.8 made them
// DontEnum), the class is "Arguments" rather than "Object", and defineProperty now runs the real 10.6 algorithm,
// whose step 5 (b)(i) writes a descriptor value straight through to the mapped parameter. Verified against V8.
> (function() { for (var i in arguments) print(i) })('1', '2', '3', '4');
< 0
< 1
< 2
< 3
-
> (function() { print(arguments); })()
< [object Arguments]
-
// { writable: false } is what 10.6 step 5 (b)(ii) severs the mapping on, but the value in the same descriptor is
// put on the map first, so `a` becomes 'z' before the link goes and the later a = 9 no longer shows through.
> function f1(a,b,c) { print(a); print(arguments[0]); a = 7; print(a); print(arguments[0]); arguments[0] = 5; print(a); print(arguments[0]); Object.defineProperty(arguments, '0', { value: 'z', writable: false, enumerable: false }); print(a); print(arguments[0]); a = 9; print(a); print(arguments[0]); print('-'); for (i in arguments) print(i); print('-'); }
> f1(1234,2345,3456)
< 1234
< 1234
< 7
< 7
< 5
< 5
< z
< z
< 9
< z
< -
< 1
< 2
< -
-
// The same descriptor with the defaults restated changes no attribute and is not an accessor, so step 5 leaves the
// mapping alone: a = 9 still reaches arguments[0], and index 0 is still enumerable.
> function f2(a,b,c) { print(a); print(arguments[0]); a = 7; print(a); print(arguments[0]); arguments[0] = 5; print(a); print(arguments[0]); Object.defineProperty(arguments, '0', { value: 'z', writable: true, enumerable: true }); print(a); print(arguments[0]); a = 9; print(a); print(arguments[0]); print('-'); for (i in arguments) print(i); print('-'); }
> f2(1234,2345,3456)
< 1234
< 1234
< 7
< 7
< 5
< 5
< z
< z
< 9
< 9
< -
< 0
< 1
< 2
< -
-
