> var obj = { a: 1 };
> var d = Object.getOwnPropertyDescriptor(obj, 'a');
> print(d.value === 1 && d.writable && d.enumerable && d.configurable);
< true
-
> var value;
> var acc = {};
> Object.defineProperty(acc, 'x', { get: function() { return 5; }, set: function(v) { value = v; }, enumerable: false, configurable: false });
> var d2 = Object.getOwnPropertyDescriptor(acc, 'x');
> print(typeof d2.get === 'function' && typeof d2.set === 'function' && d2.enumerable === false && d2.configurable === false);
< true
-
