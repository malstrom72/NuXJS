> var d = Object.getOwnPropertyDescriptor(Function.prototype, 'caller');
> print(d.enumerable === false);
> print(d.configurable === true);
> print(typeof d.get === 'function');
> print(d.get === d.set);
> try { Function.prototype.caller; } catch (e) { print(e instanceof TypeError); }
> try { Function.prototype.caller = function(){}; } catch (e) { print(e instanceof TypeError); }
< true
< true
< true
< true
< true
< true
-
