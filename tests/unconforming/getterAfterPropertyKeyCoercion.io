> var log = [];
> var obj = {};
> Object.defineProperty(obj, 'p', { get: function() { log.push('getter'); return 1; }, configurable: true });
> var key = { toString: function() { log.push('key'); return 'p'; } };
> obj[key];
> print(log.join(','));
// Expected per ES5: key,getter
< key
-
