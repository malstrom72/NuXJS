> (function(){ for (var k in arguments) print(k) })(1,2,3)
< 0
< 1
< 2
-
> (function(){ print(Object.prototype.toString.call(arguments)) })()
< [object Arguments]
-
