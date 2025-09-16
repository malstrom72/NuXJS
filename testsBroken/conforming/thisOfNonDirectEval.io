> globals=this
> e=eval
> o={ test1: function() { return e("this") }, test2: function() { return eval("this") } }
-
> print(o.test1()==globals)
< true
-
> print(o.test1()==o)
< false
-
> print(o.test2()==globals)
< false
-
> print(o.test2()==o)
< true
-
