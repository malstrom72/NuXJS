> var ws = '\u1680';
> print(parseInt(ws + '123') === 123);
< true
-
> print(parseInt('123' + ws) === 123);
< true
-
> var ws2 = '\uFEFF';
> print(parseFloat(ws2 + '-1.5' + ws2) === -1.5);
< true
-
