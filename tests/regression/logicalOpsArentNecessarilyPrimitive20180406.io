> o={valueOf:function() { return "111"; }}
> print((false||o)+'xxx')
< 111xxx
-
> print((true&&o)+'xxx')
< 111xxx
-
