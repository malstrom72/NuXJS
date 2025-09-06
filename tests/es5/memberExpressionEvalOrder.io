> log = [];
> function obj(){ log[log.length] = 'obj'; return { foo: function(){} }; }
> function prop(){ log[log.length] = 'prop'; return 'foo'; }
> function arg(){ log[log.length] = 'arg'; return 0; }
> obj()[prop()](arg());
> print(log.join());
< obj,prop,arg
-
