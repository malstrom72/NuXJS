> 'use strict';
> function f() { return arguments.callee; }
> try { f(); print(false); } catch (e) { print(e instanceof TypeError); }
< true
-
