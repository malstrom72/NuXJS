// ES5.1: 15.5.5.2: In Edition 5, the individual characters of a String object’s [[PrimitiveValue] may be accessed as array indexed properties of the String object. These properties are non-writable and non-configurable and shadow any inherited properties with the same names. In Edition 3, these properties did not exist and ECMAScript code could dynamically add and remove writable properties with such names and could access inherited properties with such names.
> print(3 in new String("pokpokpko"));
< true
-
> print((new String("pokpokpokok")).hasOwnProperty(3));
< true
-
> var s = '';
> for (var i in new String("abcdefghijklmn")) s += i + ",";
> print(s);
< 0,1,2,3,4,5,6,7,8,9,10,11,12,13,
-
