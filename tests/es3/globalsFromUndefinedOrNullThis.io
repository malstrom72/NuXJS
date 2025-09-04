> var globals = this;
-
> // Following is true in ES>3 too because of conversion described in 10.4.3, however in ES>3 this only applies to script functions
> (function() { print(this === globals); }).call(null);
< true
-
> // Following is true in ES>3 too because of conversion described in 10.4.3, however in ES>3 this only applies to script functions
> (function() { print(this === globals); }).call(undefined);
< true
-
> print(String.prototype.charAt.call(null, 0))
< [
-
> print(String.prototype.charAt.call(undefined, 0))
< [
-
> print(String.prototype.charCodeAt.call(null, 0))
< 91
-
> print(String.prototype.charCodeAt.call(undefined, 0))
< 91
-
