// CLI:
> var log = [];
> var obj = {};
> Object.defineProperty(obj, 'p', { set: function(v) { log.push('setter'); }, configurable: true });
> var key = { toString: function() { log.push('key'); return 'p'; } };
> obj[key] = 1;
> print(log.join(','));
// Expected per ES5: key,setter
< key
-
