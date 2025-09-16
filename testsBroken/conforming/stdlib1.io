>     function analyzeFlags(object, property, testValue) {
>         var origObject = Object; // In case it is Object we are testing
>         property = '' + property;
>         testValue = (testValue != null ? testValue : { });
>         if (!object.hasOwnProperty(property)) {
>             print(property + " : doesn't exist");
>         } else {
>             var dontEnum = true;
>             for (var p in object) {
>                 if (p === property) {
>                     dontEnum = false;
>                     break;
>                 }
>             }
>             var doEnum = object.propertyIsEnumerable(property);
>             if (doEnum === dontEnum) {
>                 print("Warning! object.propertyIsEnumerable() returned " + doEnum + " for property '" + property
>                         + "' although it " + (dontEnum ? "was not" : "was") + " listed by for-in");
>             }
>             var valueWas = object[property];
>             object[property] = testValue;
>             var valueIs = object[property];
>             var readOnly = (valueIs !== testValue);
>             var deleted = delete object[property];
>             var dontDelete = object.hasOwnProperty(property);
>             print(property + " : " + (dontEnum ? "dontEnum," : "") + (readOnly ? "readOnly," : "")
>                     + (dontDelete ? "dontDelete," : "") + " (deleted:" + deleted + ')');
>             if (origObject.defineProperty) {
>                 origObject.defineProperty(object, property, { value: valueWas, enumerable: !dontEnum, configurable: !dontDelete, writable: !readOnly });
>             } else {
>                 object[property] = valueWas;
>             }
>         }
>     }
-     
>     var constants = [
>         [ this, "NaN" ], [ this, "Infinity" ], [ this, "undefined" ]
>         , [ Number, "MAX_VALUE" ], [ Number, "MIN_VALUE" ], [ Number, "NaN" ], [ Number, "NEGATIVE_INFINITY" ], [ Number, "POSITIVE_INFINITY" ]
>     ];
>     for (var i = 0; i < constants.length; ++i) {
>         var base = constants[i][0];
>         var constant = constants[i][1];
>         print(constant + ": " + base[constant]);
>         analyzeFlags(base, constant);
>     };
// ES5.1: 15.1.1: The value properties NaN, Infinity, and undefined of the Global Object have been changed to be read-only properties.
< NaN: NaN
< NaN : dontEnum,dontDelete, (deleted:false)
< Infinity: Infinity
< Infinity : dontEnum,dontDelete, (deleted:false)
< undefined: undefined
< undefined : dontEnum,dontDelete, (deleted:false)
< MAX_VALUE: 1.7976931348623157e+308
< MAX_VALUE : dontEnum,readOnly,dontDelete, (deleted:false)
< MIN_VALUE: 5e-324
< MIN_VALUE : dontEnum,readOnly,dontDelete, (deleted:false)
< NaN: NaN
< NaN : dontEnum,readOnly,dontDelete, (deleted:false)
< NEGATIVE_INFINITY: -Infinity
< NEGATIVE_INFINITY : dontEnum,readOnly,dontDelete, (deleted:false)
< POSITIVE_INFINITY: Infinity
< POSITIVE_INFINITY : dontEnum,readOnly,dontDelete, (deleted:false)
-    
>	  function testConstructor(constructor) {
>         print(constructor + ": " + typeof this[constructor]);
>         analyzeFlags(this, constructor);
>         print(constructor + ".prototype: " + this[constructor].prototype);
>         analyzeFlags(this[constructor], 'prototype');
>         print(constructor + ".prototype.constructor: " + typeof this[constructor].prototype.constructor);
>         analyzeFlags(this[constructor].prototype, 'constructor');
>         print(this[constructor].prototype.constructor === this[constructor]);
>         print(constructor + ".length: " + this[constructor].length);
>         analyzeFlags(this[constructor], 'length');
>     }
-
// ES5.1: 15.3.5.2: In Edition 5, the prototype property of Function instances is not enumerable. In Edition 3, this property was enumerable.
> testConstructor("Object");
< Object: function
< Object : dontEnum, (deleted:true)
< Object.prototype: [object Object]
< prototype : dontEnum,readOnly,dontDelete, (deleted:false)
< Object.prototype.constructor: function
< constructor : dontEnum, (deleted:true)
< true
< Object.length: 1
< length : dontEnum,readOnly,dontDelete, (deleted:false)
-
> testConstructor("Boolean");
< Boolean: function
< Boolean : dontEnum, (deleted:true)
< Boolean.prototype: false
< prototype : dontEnum,readOnly,dontDelete, (deleted:false)
< Boolean.prototype.constructor: function
< constructor : dontEnum, (deleted:true)
< true
< Boolean.length: 1
< length : dontEnum,readOnly,dontDelete, (deleted:false)
-
> testConstructor("Number");
< Number: function
< Number : dontEnum, (deleted:true)
< Number.prototype: 0
< prototype : dontEnum,readOnly,dontDelete, (deleted:false)
< Number.prototype.constructor: function
< constructor : dontEnum, (deleted:true)
< true
< Number.length: 1
< length : dontEnum,readOnly,dontDelete, (deleted:false)
-
> testConstructor("String");
< String: function
< String : dontEnum, (deleted:true)
< String.prototype: 
< prototype : dontEnum,readOnly,dontDelete, (deleted:false)
< String.prototype.constructor: function
< constructor : dontEnum, (deleted:true)
< true
< String.length: 1
< length : dontEnum,readOnly,dontDelete, (deleted:false)
-
> testConstructor("Function");
< Function: function
< Function : dontEnum, (deleted:true)
< Function.prototype: function() { [native code] }
< prototype : dontEnum,readOnly,dontDelete, (deleted:false)
< Function.prototype.constructor: function
< constructor : dontEnum, (deleted:true)
< true
< Function.length: 1
< length : dontEnum,readOnly,dontDelete, (deleted:false)
-
> testConstructor("Error");
< Error: function
< Error : dontEnum, (deleted:true)
< Error.prototype: Error
< prototype : dontEnum,readOnly,dontDelete, (deleted:false)
< Error.prototype.constructor: function
< constructor : dontEnum, (deleted:true)
< true
< Error.length: 1
< length : dontEnum,readOnly,dontDelete, (deleted:false)
-
> testConstructor("EvalError");
< EvalError: function
< EvalError : dontEnum, (deleted:true)
< EvalError.prototype: EvalError
< prototype : dontEnum,readOnly,dontDelete, (deleted:false)
< EvalError.prototype.constructor: function
< constructor : dontEnum, (deleted:true)
< true
< EvalError.length: 1
< length : dontEnum,readOnly,dontDelete, (deleted:false)
-
> testConstructor("RangeError");
< RangeError: function
< RangeError : dontEnum, (deleted:true)
< RangeError.prototype: RangeError
< prototype : dontEnum,readOnly,dontDelete, (deleted:false)
< RangeError.prototype.constructor: function
< constructor : dontEnum, (deleted:true)
< true
< RangeError.length: 1
< length : dontEnum,readOnly,dontDelete, (deleted:false)
-
> testConstructor("ReferenceError");
< ReferenceError: function
< ReferenceError : dontEnum, (deleted:true)
< ReferenceError.prototype: ReferenceError
< prototype : dontEnum,readOnly,dontDelete, (deleted:false)
< ReferenceError.prototype.constructor: function
< constructor : dontEnum, (deleted:true)
< true
< ReferenceError.length: 1
< length : dontEnum,readOnly,dontDelete, (deleted:false)
-
> testConstructor("SyntaxError");
< SyntaxError: function
< SyntaxError : dontEnum, (deleted:true)
< SyntaxError.prototype: SyntaxError
< prototype : dontEnum,readOnly,dontDelete, (deleted:false)
< SyntaxError.prototype.constructor: function
< constructor : dontEnum, (deleted:true)
< true
< SyntaxError.length: 1
< length : dontEnum,readOnly,dontDelete, (deleted:false)
-
> testConstructor("TypeError"); 
< TypeError: function
< TypeError : dontEnum, (deleted:true)
< TypeError.prototype: TypeError
< prototype : dontEnum,readOnly,dontDelete, (deleted:false)
< TypeError.prototype.constructor: function
< constructor : dontEnum, (deleted:true)
< true
< TypeError.length: 1
< length : dontEnum,readOnly,dontDelete, (deleted:false)
-
> testConstructor("URIError");
< URIError: function
< URIError : dontEnum, (deleted:true)
< URIError.prototype: URIError
< prototype : dontEnum,readOnly,dontDelete, (deleted:false)
< URIError.prototype.constructor: function
< constructor : dontEnum, (deleted:true)
< true
< URIError.length: 1
< length : dontEnum,readOnly,dontDelete, (deleted:false)
-
>     
>     // FIX : test that all functions in all standard library objects are not constructable and that they don't have prototype fields
> //  var globalObjects = [ "Object", "Boolean", "Number", "String", "Function", "Error", "Math" ]; <- rest of errors
>     
>         var x = Object(true);
>         print("x: " + x);
>         print("x instanceof Boolean: " + (x instanceof Boolean));
>         var realBoolean = Boolean;
>         Boolean = function(b) { print("custom Boolean call"); return realBoolean(!b) };
>         x = new Boolean(true);
>         print("x: " + x);
>         print("x instanceof Boolean: " + (x instanceof Boolean));
>         print("x instanceof realBoolean: " + (x instanceof realBoolean));
>         realBoolean.prototype.capture = function() { return this; };
>         Boolean.prototype.capture = function() { return this; };
>         x = (true).capture();
>         delete realBoolean.prototype.capture;
>         delete Boolean.prototype.capture;
>         print("x: " + x);
>         print("x instanceof Boolean: " + (x instanceof Boolean));
>         print("x instanceof realBoolean: " + (x instanceof realBoolean));
>         x = Object(true);
>         print("x: " + x);
>         print("x instanceof Boolean: " + (x instanceof Boolean));
>         print("x instanceof realBoolean: " + (x instanceof realBoolean));
>     
>         var x = Object(1.2345);
>         print("x: " + x);
>         print("x instanceof Number: " + (x instanceof Number));
>         var realNumber = Number;
>         Number = function(b) { print("custom Number call"); return realNumber(!b) };
>         x = new Number(1.2345);
>         print("x: " + x);
>         print("x instanceof Number: " + (x instanceof Number));
>         print("x instanceof realNumber: " + (x instanceof realNumber));
>         realNumber.prototype.capture = function() { return this; };
>         Number.prototype.capture = function() { return this; };
>         x = (1.2345).capture();
>         delete realNumber.prototype.capture;
>         delete Number.prototype.capture;
>         print("x: " + x);
>         print("x instanceof Number: " + (x instanceof Number));
>         print("x instanceof realNumber: " + (x instanceof realNumber));
>         x = Object(1.2345);
>         print("x: " + x);
>         print("x instanceof Number: " + (x instanceof Number));
>         print("x instanceof realNumber: " + (x instanceof realNumber));
>     
>         var x = Object("strongbad");
>         print("x: " + x);
>         print("x instanceof String: " + (x instanceof String));
>         var realString = String;
>         String = function(b) { print("custom String call"); return realString(!b) };
>         x = new String("strongbad");
>         print("x: " + x);
>         print("x instanceof String: " + (x instanceof String));
>         print("x instanceof realString: " + (x instanceof realString));
>         realString.prototype.capture = function() { return this; };
>         String.prototype.capture = function() { return this; };
>         x = ("strongbad").capture();
>         delete realString.prototype.capture;
>         delete String.prototype.capture;
>         print("x: " + x);
>         print("x instanceof String: " + (x instanceof String));
>         print("x instanceof realString: " + (x instanceof realString));
>         x = Object("strongbad");
>         print("x: " + x);
>         print("x instanceof String: " + (x instanceof String));
>         print("x instanceof realString: " + (x instanceof realString));
< x: true
< x instanceof Boolean: true
< custom Boolean call
< x: [object Object]
< x instanceof Boolean: true
< x instanceof realBoolean: false
< x: true
< x instanceof Boolean: false
< x instanceof realBoolean: true
< x: true
< x instanceof Boolean: false
< x instanceof realBoolean: true
< x: 1.2345
< x instanceof Number: true
< custom Number call
< x: [object Object]
< x instanceof Number: true
< x instanceof realNumber: false
< x: 1.2345
< x instanceof Number: false
< x instanceof realNumber: true
< x: 1.2345
< x instanceof Number: false
< x instanceof realNumber: true
< x: strongbad
< x instanceof String: true
< custom String call
< x: [object Object]
< x instanceof String: true
< x instanceof realString: false
< x: strongbad
< x instanceof String: false
< x instanceof realString: true
< x: strongbad
< x instanceof String: false
< x instanceof realString: true
>     
>     // FIX : test errors
>     
>     // FIX : test that all function's have names that matches their property names in their "owner objects"
>     
>         var global = this;
>         function test() { print(this.toString() + (this === global ? ' (global)' : '')); print('count: ' + arguments.length); for (i = 0; i < arguments.length; ++i) print(arguments[i].toString()); print('-') }
>         test(1,2,3,4,5);
>         var o = { toString: function() { return "me" }, test: test };
>         o.test(6,7,8);
>         test.call(null, 9,10,11,12);
>         test.call(o, 9,10,11,12);
>         test.apply(null, [ 13,14,15,16 ]);
>         test.apply(o, [ 13,14,15,16 ]);
>         test.call(o);
>         test.apply(o);
>         test.call();
>         test.apply();
>         test.call("snuttelisnutt");
>         test.apply("snuttelisnutt");
>         (function() { test.apply(o, arguments); })(17,18,19,20);
>         try { test.apply(o, "snuttelisnutt"); } catch (e) { print(e); }
>         try { test.apply(o, { 'wrong': 'type of object' }); } catch (e) { print(e); }
< [object Object] (global)
< count: 5
< 1
< 2
< 3
< 4
< 5
< -
< me
< count: 3
< 6
< 7
< 8
< -
< [object Object] (global)
< count: 4
< 9
< 10
< 11
< 12
< -
< me
< count: 4
< 9
< 10
< 11
< 12
< -
< [object Object] (global)
< count: 4
< 13
< 14
< 15
< 16
< -
< me
< count: 4
< 13
< 14
< 15
< 16
< -
< me
< count: 0
< -
< me
< count: 0
< -
< [object Object] (global)
< count: 0
< -
< [object Object] (global)
< count: 0
< -
< snuttelisnutt
< count: 0
< -
< snuttelisnutt
< count: 0
< -
< me
< count: 4
< 17
< 18
< 19
< 20
< -
< TypeError: Argument list has wrong type
< TypeError: Argument list has wrong type
-
