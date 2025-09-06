> function f(a){ delete arguments[0]; a = 2; return arguments[0] === undefined && a === 2; }
> print(f(1))
< true
-
> function g(a){ Object.defineProperty(arguments, "0", { value: 2, writable: true, enumerable: true, configurable: true }); a = 3; return arguments[0] === 2 && a === 3; }
> print(g(1))
< true
-
> function h(a){ Object.defineProperty(arguments, "0", { get: function(){ return 5; } }); a = 6; return arguments[0] === 5 && a === 6; }
> print(h(1))
< true
-
> function i(a){ var log = 0; Object.defineProperty(arguments, "0", { get: function(){ return 5; }, set: function(v){ log = v; } }); arguments[0] = 7; return a === 1 && log === 7 && arguments[0] === 5; }
> print(i(1))
< true
-
