> f=function(a, b) { this.a=a; this.b=b; this.c="cee"; this.dump=function() { print("a: " + this.a  + ", b: " + this.b + ", c: " + this.c); } }
> x = new f
> x.dump()
< a: undefined, b: undefined, c: cee
-
> g=function(c) { this.c=c }
> g.prototype = x;
> y = new g;
> y.dump();
> y = new g("hey")
> y.dump();
< a: undefined, b: undefined, c: undefined
< a: undefined, b: undefined, c: hey
-
> x = new f ( "aah" , "bee" )
> x.dump()
< a: aah, b: bee, c: cee
-
> g=function(c) { this.c=c; this.d="dee" }
> g.prototype = x;
> y = new g("hey")
> y.dump();
< a: aah, b: bee, c: hey
-
> print("a" in x);
> print("b" in x);
> print("c" in x);
> print("d" in x);
< true
< true
< true
< false
-
> print("a" in y);
> print("b" in y);
> print("c" in y);
> print("d" in y);
> print("e" in y);
< true
< true
< true
< true
< false
-
> h=function(e) { this.e=e; }
> h.prototype = y;
> z = new h("yo!")
> x.a="changed"
> z.dump();
< a: changed, b: bee, c: hey
-
> print("a" in z);
> print("b" in z);
> print("c" in z);
> print("d" in z);
> print("e" in z);
< true
< true
< true
< true
< true
-
> g=function(c) { this.c=c; this.d="dee" }
> g.prototype = "not valid";
> y = new g("hey")
> print("a" in y);
> print("b" in y);
> print("c" in y);
> print("d" in y);
< false
< false
< true
< true
-
