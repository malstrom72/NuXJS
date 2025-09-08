> var d = new Date(0); d.toISOString = function(){ return "custom"; }; print(d.toJSON());
< custom
-
> print(Date.prototype.toJSON.call({ toISOString: function(){ return "generic"; }, valueOf: function(){ return 0; }}));
< generic
-
> print(Date.prototype.toJSON.call({ toISOString: function(){ throw 'fail'; }, valueOf: function(){ return Infinity; }}));
< null
-
> print(new Date(NaN).toJSON());
< null
-
> try { Date.prototype.toJSON.call({ valueOf: function(){ return 0; } }); } catch(e) { print(e instanceof TypeError); }
< true
-
