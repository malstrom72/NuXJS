> o = { y: 5 }; with (o) { print(y) };
< 5
-
> (function() { p = { y: 3 }; with (p) { print(y) } })();
< 3
-
> (function() { p = { y: 3 }; with (p) { with (o) { print(y) }; print(y); } })();
< 5
< 3
-
> (function() { var y = 123; p = { y: 3 }; with (p) { with (o) { print(y) }; print(y); } print(y); })();
< 5
< 3
< 123
-
> (function() { var y = 123; all: { p = { y: 3 }; with (p) { with (o) { print(y); break all; }; print(y); } }; print(y); })();
< 5
< 123
-
> (function() { try { var y = 123; all: { p = { y: 3 }; with (p) { with (o) { print(y); throw "up"; }; print(y); } }; } catch (e) { print(e + " " + y); } })();
< 5
< up 123
-
> print((function() { with ({ x: 3 }) { return x; }})());
< 3
-
> o={x:3};with(o) { var x; x=5; print(x) }; print(x);
< 5
< undefined
-
> o={x:3};with(o) { var x=5; print(x) }; print(x);
< 5
< undefined
-
> o={x:3};with(o) { var x=9; print(x) }; print(x);
< 9
< undefined
-
> o={x:3};with(o) { var x=9; z=123;print(x) }; print(x); print(z);
< 9
< undefined
< 123
-
> TestObject=function() { }; TestObject.prototype = { z:5 };
> o=new TestObject;o.x=3; with(o) { var x=9; z=123;print(x) }
> print(z)
< 9
< 123
-
> o=new TestObject;o.x=3; with(o) { var x=9; z=512;print(x) };
> print(z)
> print(TestObject.prototype.z)
> print(o.x)
> print(o.z)
< 9
< 123
< 5
< 9
< 512
-
> o=new TestObject
> print(o.z)
< 5
-
> TestObject.prototype.z=7
> print(o.z)
< 7
-
> o=new TestObject;o.x=3; with(o) { var x=9; z=678; print(x) }
> print(z)
> print(o.z)
> print(o.hasOwnProperty('z'))
< 9
< 123
< 678
< true
> with ({ slime: "grime" }) print(slime)
< grime
-
> with ({ slime: "grime" }) { eval("var slime=3"); print(slime) }
< 3
-
> var o = { slime: "grime" }; with (o) { eval("var slime=3"); print(slime) }
< 3
-
> var o = { slime: "grime" }; with (o) { eval("var slime=3"); print(slime) }; print(o.slime); print(slime);
< 3
< 3
< undefined
-
> var o={x:"y"};with(o){print(delete(x));};print(typeof o.x);
< true
< undefined
-
> with({O:null,o:null}){function O(){};print(typeof O);};print(typeof O);
< object
< function
-
> if (Object.defineProperty) with({O:null,o:null}){O=function(){};Object.defineProperty(O.prototype,'x',{value:'y',writable:false});o=new O;print(o.x);print(o.hasOwnProperty('x'));o.x=7;print(o.x);(function(){with(o){x=9;print(x)}})();(function(){var x=12;with(o){x=9;print(x)};print(x)})()};
< y
< false
< y
< y
< y
< 12
-
> with({O:null,o:null}){O=function(){};O.prototype.x='y';o=new O;print(o.x);print(o.hasOwnProperty('x'));o.x=7;print(o.x);(function(){with(o){x=9;print(x)}})();(function(){var x=12;with(o){x=11;print(x)};print(x)})();print(o.x)}
< y
< false
< 7
< 9
< 11
< 12
< 11
-
> with({O:null,o:null}){O=function(){};O.prototype.x='y';o=new O;print(o.x);print(o.hasOwnProperty('x'));(function(){with(o){x=9;print(x)}})();(function(){var x=12;with(o){x=11;print(x)};print(x)})();print(o.x);print(O.prototype.x)}
< y
< false
< 9
< 11
< 12
< 11
< y
-
> with({O:null,o:null}){O=function(){};o=new O;print(o.x);print(o.hasOwnProperty('x'));(function(){with(o){x=9;print(x)}})();(function(){var x=12;with(o){x=11;print(x)};print(x)})();print(o.x);print(O.prototype.x)}
< undefined
< false
< 9
< 11
< 11
< undefined
< undefined
-
> (function() { var o = { x: 123, f: 567 }; with (o) { print(f); function f() { function x() { }; print(typeof x); x = 'abc'; print(x) }; f=f; print(f) }; print(typeof f); f(); print(o.x) })();
< 567
< 567
< function
< function
< abc
< 123
-
> (function() { var o = { x: 123, f: 567 }; with (o) { print(f); f=function() { var f = 243; function x() { }; print(typeof x); x = 'abc'; print(x) }; f=f; print(typeof f) }; print(typeof o.f); o.f(); print(typeof o.f); print(o.x) })();
< 567
< function
< function
< function
< abc
< function
< 123
-
> (function() { var o = { x: 123, f: 567 }; with (o) { print(f); f=function() { f = 243; function x() { }; print(typeof x); x = 'abc'; print(x) }; f=f; print(typeof f) }; print(typeof o.f); o.f(); print(typeof o.f); print(o.x) })();
< 567
< function
< function
< function
< abc
< number
< 123
-
> (function() { var o = { x: 123, f: 567 }; with (o) { print(f); f=function() { function x() { }; print(typeof x); print(typeof o.x) }; }; print(typeof o.f); o.f(); print(o.x) })();
< 567
< function
< function
< number
< 123
-
> (function() { var o = { x: 123, f: 567 }; with (o) { print(f); eval("function f() { };"); print(f); }; print(o.f); })();
< 567
< 567
< 567
-
