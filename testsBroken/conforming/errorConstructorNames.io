> print(Error.name)
< Error
> print(SyntaxError.name)
< SyntaxError
> print(delete SyntaxError.name)
// ES6:
// < false
< true
> print(SyntaxError.name)
// ES6:
// < Error
< 
> print(Error.prototype.name)
< Error
> print(Error.isPrototypeOf(SyntaxError))
// ES6: 19.5.6.2: In ECMAScript 2015, the [[Prototype]] internal slot of a NativeError constructor is the Error constructor. In previous editions it was the Function prototype object.
// < true
< false
> print(Error.prototype.isPrototypeOf(SyntaxError))
< false
