> g=(function(){return this;})()
> try { throw function(){ return this===g; } } catch(e){ print(e()); }
< true
-
> try { throw function(){ "use strict"; return this===undefined; } } catch(e){ print(e()); }
< true
-
