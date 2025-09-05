> var desc = Object.getOwnPropertyDescriptor(Function.prototype, 'name');
> print(typeof desc.get);
< function
-
> function Foo(){}
> delete Foo.name;
> print(Foo.name);
< 
-
> try { desc.get.call({}); } catch(e){ print(e instanceof TypeError); }
< true
-
