> var d = Object.getOwnPropertyDescriptor(Function.prototype, 'arguments');
> print(d.enumerable === false);
> print(d.configurable === true);
> print(typeof d.get === 'function');
> print(d.get === d.set);
> try { Function.prototype.arguments; } catch (e) { print(e instanceof TypeError); }
> try { Function.prototype.arguments = function(){}; } catch (e) { print(e instanceof TypeError); }
< true
< true
< true
< true
< true
< true
-
