> function f(){ "use strict";
> try { arguments.callee; } catch(e){ print(e instanceof TypeError); }
> try { arguments.caller; } catch(e){ print(e instanceof TypeError); } }
> f();
< true
< true
-
