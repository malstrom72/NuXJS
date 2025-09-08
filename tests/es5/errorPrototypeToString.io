> try { Error.prototype.toString.call(null); } catch (e) { print(e instanceof TypeError); }
< true
-
> print(Error.prototype.toString.call({name:"Foo", message:"bar"}));
< Foo: bar
-
> print(Error.prototype.toString.call({name:"Foo"}));
< Foo
-
> print(Error.prototype.toString.call({message:"bar"}));
< Error: bar
-
> print(Error.prototype.toString.call({}));
< Error
-
> print(Error.prototype.toString.call({name:"", message:""}));
< 
-
> print(Error.prototype.toString.call({name:5, message:10}));
< 5: 10
-
> var e = new Error();
> print(e.toString());
< Error
-
