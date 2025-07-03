> (function() { for (var i in arguments) print(i) })('1', '2', '3', '4');
// ES5.1: 10.6: In Edition 5 the array indexed properties of argument objects that correspond to actual formal parameters are enumerable. In Edition 3, such properties were not enumerable.
// 0
// 1
// 2
// 3
-
> (function() { print(arguments); })()
// ES5.1: 10.6: In Edition 5 the value of the [[Class]] internal property of an arguments object is "Arguments". In Edition 3, it was "Object". This is observable if toString is called as a method of an arguments object.
// < [object Arguments]
< [object Object]
-
> function f1(a,b,c) { print(a); print(arguments[0]); a = 7; print(a); print(arguments[0]); arguments[0] = 5; print(a); print(arguments[0]); Object.defineProperty(arguments, '0', { value: 'z', writable: false, enumerable: false }); print(a); print(arguments[0]); a = 9; print(a); print(arguments[0]); print('-'); for (i in arguments) print(i); print('-'); }
> f1(1234,2345,3456)
< 1234
< 1234
< 7
< 7
< 5
< 5
< 5
< z
< 9
< z
< -
// ES5.1: 10.6: In Edition 5 the array indexed properties of argument objects that correspond to actual formal parameters are enumerable. In Edition 3, such properties were not enumerable.
// < 1
// < 2
< -
-
> function f2(a,b,c) { print(a); print(arguments[0]); a = 7; print(a); print(arguments[0]); arguments[0] = 5; print(a); print(arguments[0]); Object.defineProperty(arguments, '0', { value: 'z', writable: true, enumerable: true }); print(a); print(arguments[0]); a = 9; print(a); print(arguments[0]); print('-'); for (i in arguments) print(i); print('-'); }
> f2(1234,2345,3456)
< 1234
< 1234
< 7
< 7
< 5
< 5
< 5
< z
< 9
< z
< -
< 0
// ES5.1: 10.6: In Edition 5 the array indexed properties of argument objects that correspond to actual formal parameters are enumerable. In Edition 3, such properties were not enumerable.
// < 1
// < 2
< -
-
