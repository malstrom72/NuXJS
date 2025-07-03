> emptyObject = {};
> print(typeof emptyObject);
< object
-
> filledObject =   {  a  :   "b"   , 3  :   (5,10+23)   , ","  :   emptyObject != null ? "y":"n"  };
> print(filledObject.a);
> print(filledObject[3]);
> print(filledObject[","]);
< b
< 33
< y
-
> deepObject = { left : { l : "ll" , r:"lr" },right:{l:"rl",r:"rr"} };
> print(deepObject.left.l); print(deepObject.left.r); print(deepObject.right.l); print(deepObject.right.r);
< ll
< lr
< rl
< rr
-
> objectFromLiteral = { a : "this" , c : "is" , };
> print(objectFromLiteral.a);
> print(objectFromLiteral.c);
< this
< is
-
> objectFromCall = Object();
> objectFromCall.f = "expected";
> objectFromCall.g = "behavior";
> print(objectFromCall.f);
> print(objectFromCall.g);
< expected
< behavior
-
> objectFromConstructor = new Object();
> objectFromConstructor.h = "... and";
> objectFromConstructor.i = "this too";
> print(objectFromConstructor.h);
> print(objectFromConstructor.i);
< ... and
< this too
-
> MyObject = function() { }; objectFromCustomConstructor = new MyObject; objectFromCustomConstructor.name = "magnus"; objectFromCustomConstructor.age = 41;
> print("name" in objectFromCustomConstructor);
> print("age" in objectFromCustomConstructor);
> print("nope" in objectFromCustomConstructor);
> // FIX : enable once we have toString in object.prototype
> // print(objectFromCustomConstructor in objectFromCustomConstructor);
> print("objectFromCustomConstructor" in this);
< true
< true
< false
< true
-
> /* FIX :
> Object.prototype.patch = "patched";
> print(emptyObject.patch);
> print(deepObject.patch);
> print(objectFromLiteral.patch);
> print(objectFromCall.patch);
> print(objectFromConstructor.patch);
> print(objectFromCustomConstructor.patch);
> print(delete Object.prototype.patch);
> */
-
> // had a bug with this...
> (function() {
> var o = { a: 1 };
> o.a += 5;
> print(o.a++);
> print(++o.a);
> var a = {b:0};
> a.b=1;
> a.b+=1
> function fo(a,b) { var o = { }; o[a] = b; return o; };
> function i(j) { return j; };
> print(fo('q','g')[i('q')]);
> (o = fo('q','g'))[i('q')] = 5;
> print(o.q);
> (o = fo('q',3))[i('q')] += fo('z',5)[i('z')];
> print(o.q);
> })();
< 6
< 8
< g
< 5
< 8
-
