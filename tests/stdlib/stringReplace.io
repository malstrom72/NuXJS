> print("apan bapan banan".replace("bapan",function() { arguments.join = Array.prototype.join; print(arguments.join()); return "hola" }))
< bapan,5,apan bapan banan
< apan hola banan
-
> print("apan bapan banan".replace("banan",function() { arguments.join = Array.prototype.join; print(arguments.join()); return "hola" }))
< banan,11,apan bapan banan
< apan bapan hola
-
> print("apan bapan banan".replace("xx",function() { arguments.join = Array.prototype.join; print(arguments.join()); return "hola" }))
< apan bapan banan
-
> print("apan bapan banan".replace("",function() { arguments.join = Array.prototype.join; print(arguments.join()); return "hola" }))
< ,0,apan bapan banan
< holaapan bapan banan
-
> print("apan bapan banan".replace("apan bapan banan",function() { arguments.join = Array.prototype.join; print(arguments.join()); return "hola" }))
< apan bapan banan,0,apan bapan banan
< hola
-
> print("apan bapan banan".replace("apan bapan banana",function() { arguments.join = Array.prototype.join; print(arguments.join()); return "hola" }))
< apan bapan banan
-
> print("apan bapan banan".replace(/ba(.)(.)n/,function() { arguments.join = Array.prototype.join; print(arguments.join()); return "hola" }))
< bapan,p,a,5,apan bapan banan
< apan hola banan
-
> print("apan bapan banan".replace(RegExp(""),function() { arguments.join = Array.prototype.join; print(arguments.join()); return "hola" }))
< ,0,apan bapan banan
< holaapan bapan banan
-
> print("apan bapan banan".replace(RegExp("z"),function() { arguments.join = Array.prototype.join; print(arguments.join()); return "hola" }))
< apan bapan banan
-
> print("apan bapan banan".replace("bapan","hola"))
< apan hola banan
-
> print("apan bapan banan".replace("bapan","hola $$ $10"))
< apan hola $ $10 banan
-
> print("apan bapan banan".replace("bapan","hola $$ $10 $$$ $$$$"))
< apan hola $ $10 $$ $$ banan
-
> print("apan bapan banan".replace("bapan","hola $$ $10 $& $$$ $$$$"))
< apan hola $ $10 bapan $$ $$ banan
-
> print("apan bapan banan".replace("bapan","hola $$ $0 $1 $2 $& $$$ $$$$"))
< apan hola $ $0 $1 $2 bapan $$ $$ banan
-
> print("apan bapan banan".replace(/bapan/,"hola $$ $0 $1 $2 $& $$$ $$$$"))
< apan hola $ $0 $1 $2 bapan $$ $$ banan
-
> print("apan bapan banan".replace(/ba(.)an/,"hola $$ $0 $1 $2 $& $$$ $$$$"))
< apan hola $ $0 p $2 bapan $$ $$ banan
-
> print("apan bapan laban banan".replace(/ba(.)an/g,"hola $$ $0 $1 $2 $& $$$ $$$$"))
< apan hola $ $0 p $2 bapan $$ $$ laban hola $ $0 n $2 banan $$ $$
-
> print("apan bapan laban banan".replace(/ba(.)an/g,"hola $$ $0 $1 $2 $& $$$ $$$$ $1"))
< apan hola $ $0 p $2 bapan $$ $$ p laban hola $ $0 n $2 banan $$ $$ n
-
> print("apan bapan laban banan".replace(/ba(.)an/g,"$`"))
< apan apan  laban apan bapan laban 
-
> print("apan bapan laban banan".replace(/ba(.)an/g,"$`X"))
< apan apan X laban apan bapan laban X
-
> print("apan bapan laban banan babian".replace(/ba(.)an/g,"X $'"))
< apan X  laban banan babian laban X  babian babian
-
> print("xyzzy".replace("z", "$"))
< xy$zy
-
