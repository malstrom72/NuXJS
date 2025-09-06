> var obj = {};
> print(Object.isExtensible(obj));
> Object.preventExtensions(obj);
> print(Object.isExtensible(obj));
> Object.preventExtensions(obj);
> print(Object.isExtensible(obj));
< true
< false
< false
-
