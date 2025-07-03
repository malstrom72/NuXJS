> f = function() { }
> var a = 1 , b = 2 , c , d = 1 in f ; print(a + ", " + b + ", " + c + ", " + d);
< 1, 2, undefined, false
-
> f = function ( a , b , c ) { print("a:" + a + ", b:" + b + ", c:" + c) }
> f ( 'first', 2, true )
< a:first, b:2, c:true
-
>  var fib = function ( y ) { if ( y >= 2 ) return fib ( y - 1 ) + fib ( y - 2 ) ; else return y ; };
> print(fib(15));
< 610
-
> var fib=function(a){return 2<=a?fib(a-1)+fib(a-2):a};print(fib(15));
< 610
-
> f=function(n) { var i = 0; while (i < n) { f[i] = i * 1234; ++i } }
> f(1000)
> print(f[0])
< 0
-
> print(f[999])
< 1232766
-
> print(f[1000])
< undefined
-
> print(f[-1])
< undefined
-
> x=9;(function() { var y=3,x=5 })(); print(x);
< 9
-
> f = function(a,b,c) { }
> print(f.length)
< 3
-
> f.length = 0
> print("f.length=" + f.length);
< f.length=3
-
> print("delete f.length=" + delete f.length);
< delete f.length=false
-
> print("f.length=" + f.length);
< f.length=3
-
> f = function() { }
> print(f.length);
< 0
-
> (function() { function  f (  )  {  print (  "hej"  ) }; f() })();
< hej
-
> (function() { print(typeof g); function g() { } })(); // function
< function
-
> (function() { var g; print(typeof g); function g() { } })(); // function
< function
-
> (function() { print(typeof g); var g = 23; print(typeof g); function g() { } })(); // function, number
< function
< number
-
> (function() { print(g.length); function g(a,b) { }; function g(a,b,c,d) { } })(); // 4
< 4
-
> // FIX : js doesn't like -> (function() { print(g.length); if (false) function g(a,b) { }; if (false) function g(a,b,c,d) { } })(); // 4
> print("del: " + delete g);
< del: true
-
> (function() { g = "qwerty"; function g(a,b,c,d) { }; print(g); print("del: " + delete g); })(); // qwerty, del: false
< qwerty
< del: false
-
> print("hasg: " + ("g" in this));
< hasg: false
-
> (function f () { print ( typeof f ) } ) ();
< function
-
> (function f(n) { print(n); if (n < 10) f(n + 1); print(n) })(0)
< 0
< 1
< 2
< 3
< 4
< 5
< 6
< 7
< 8
< 9
< 10
< 10
< 9
< 8
< 7
< 6
< 5
< 4
< 3
< 2
< 1
< 0
-
> print("del: " + delete f); // true
< del: true
-
> print("hasf: " + ("f" in this)); // hasf: false
< hasf: false
-
> (function f() { f=3; print(typeof f); })(); // function
< function
-
> (function f() { eval("f=3"); print(typeof f); })(); // function
< function
-
> print("hasf: " + ("f" in this)); // hasf: false
< hasf: false
-
> (function() { f=3; print(typeof f); })(); // number
< number
-
> print("hasf: " + ("f" in this)); // hasf: true
< hasf: true
-
> print("del: " + delete f); // true
< del: true
-
> (function f() { print(typeof f); var f=3; print(typeof f); })(); // undefined, number
< undefined
< number
-
> (function f() { print("del: " + delete f); print(typeof f); })(); // del: false, function
< del: false
< function
-
> (function f() { print("del: " + delete f); var f = 27; print("del: " + delete f); print(typeof f); })(); // del: false, del: false, number
< del: false
< del: false
< number
-
> (function f() { print("del: " + delete f); f = 27; print("del: " + delete f); print(typeof f); })(); // del: false, del: false, function
< del: false
< del: false
< function
-
> print("hasf: " + ("f" in this)); // hasf: false
< hasf: false
-
> (function f() { function f(a,b) { }; print(f.length); })(); // 2
< 2
-
> (function f() { function f(a,b) { }; print("del: " + delete f); print(f.length); })(); // del: false, 2
< del: false
< 2
-
> (function f() { print("del: " + delete f); f = 27; print("del: " + delete f); function f(a,b) { }; print(typeof f); })(); // del: false, del: false, number
< del: false
< del: false
< number
-
> print("hasf: " + ("f" in this)); // hasf: false
< hasf: false
-
> (function f() { print(f.length); function f(a,b,c,d) { }; print(f.length); })(); // 4, 4
< 4
< 4
-
> print("typeof(function(){}): "+typeof(function(){}));
< typeof(function(){}): function
-
> print("typeof(Function.prototype): "+typeof(Function.prototype));
< typeof(Function.prototype): function
-
> print("Function.prototype.isPrototypeOf(function(){}): "+Function.prototype.isPrototypeOf(function(){}));
< Function.prototype.isPrototypeOf(function(){}): true
-
> print("Function.prototype.isPrototypeOf(Function.prototype): "+Function.prototype.isPrototypeOf(Function.prototype));
< Function.prototype.isPrototypeOf(Function.prototype): false
-
> // fix : print("Function instanceof Object: "+(Function instanceof Object));
> // fix : print("Function instanceof Function: "+(Function instanceof Function));
> // fix : print("(function(){}) instanceof Function: "+((function(){}) instanceof Function));
> print("Function.prototype.length: "+Function.prototype.length);
< Function.prototype.length: 0
-
> 
-
