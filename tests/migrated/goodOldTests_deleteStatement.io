> delete z;
> print(function() { z=3; return delete z }())
> print(function() { return delete f.z }())
> print(function() { return delete "i"[0] }())
> print(function() { var z=3; return delete z }())
> print(function() { var z=3; var g=function() {  return delete z; } ; return g; }()())
> print(delete "constant is always ok");
< true
! !!!! ReferenceError: f is not defined
-
> (function() { var x=new(function(){}); x.a="a"; var b=function(){}; b.prototype=x; var c=new b; c.a="b"; print(c.a); delete c.a; print(c.a) })();
< b
< a
-
> print('delete "asdf".qwer: ' + (delete "asdf".qwer));
> print('delete (123).qwer: ' + (delete (123).qwer));
> print('delete (false).qwer: ' + (delete (false).qwer));
< delete "asdf".qwer: true
< delete (123).qwer: true
< delete (false).qwer: true
-
