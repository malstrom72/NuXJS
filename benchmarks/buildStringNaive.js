for (var i = 0; i < 10; ++i) (function() { var s = ''; for (var i = 0; i < 20000; ++i) s += 'x'; print(s.length); })();
