>     if (true) {
>         var constants = [
>             undefined, null, false, true, 1.2345, 12, +Infinity, NaN, '', 'xyzzy'
>             , { "i am": "object" }, [ 'i', 'am', 'array' ]
>         ];
>         var constructorNames = [ 'Boolean', 'Number', 'String', 'Object'/*, 'Array'*/ ];
>         var testArguments = [ 'true', '3.4567', -99.99, 123.4, 5.678 ];
>         for (var j = 0; j < constructorNames.length; ++j) {
>             var name = constructorNames[j];
>             var constructor = this[name];
>             for (var k = 0; k < 2; ++k) {
>                 var s = '';
>                 for (var i = -1; i < constants.length; ++i) {
>                     if (s) s += ', ';
>                     try {
>                         var o = (k === 0 ?
>                                 (i < 0 ? new constructor() : new constructor(constants[i]))
>                                 : (i < 0 ? constructor() : constructor(constants[i])));
>                         try {
>                             s += (typeof o)[0] + '_' + o.valueOf();
>                         }
>                         catch (x) {
>                             s += 'error';
>                         }
>                         s += "/";
>                         try {
>                             s += (typeof o)[0] + '_' + o.toString();
>                         }
>                         catch (x) {
>                             s += 'error';
>                         }
>                     }
>                     catch (x) {
>                         s += 'error';
>                     }
>                 }
>                 print((k === 0 ? 'new ' : '') + name + '(): ' + s);
>             }
>         }
>     }
>     
< new Boolean(): o_false/o_false, o_false/o_false, o_false/o_false, o_false/o_false, o_true/o_true, o_true/o_true, o_true/o_true, o_true/o_true, o_false/o_false, o_false/o_false, o_true/o_true, o_true/o_true, o_true/o_true
< Boolean(): b_false/b_false, b_false/b_false, b_false/b_false, b_false/b_false, b_true/b_true, b_true/b_true, b_true/b_true, b_true/b_true, b_false/b_false, b_false/b_false, b_true/b_true, b_true/b_true, b_true/b_true
< new Number(): o_0/o_0, o_NaN/o_NaN, o_0/o_0, o_0/o_0, o_1/o_1, o_1.2345/o_1.2345, o_12/o_12, o_Infinity/o_Infinity, o_NaN/o_NaN, o_0/o_0, o_NaN/o_NaN, o_NaN/o_NaN, o_NaN/o_NaN
< Number(): n_0/n_0, n_NaN/n_NaN, n_0/n_0, n_0/n_0, n_1/n_1, n_1.2345/n_1.2345, n_12/n_12, n_Infinity/n_Infinity, n_NaN/n_NaN, n_0/n_0, n_NaN/n_NaN, n_NaN/n_NaN, n_NaN/n_NaN
< new String(): o_/o_, o_undefined/o_undefined, o_null/o_null, o_false/o_false, o_true/o_true, o_1.2345/o_1.2345, o_12/o_12, o_Infinity/o_Infinity, o_NaN/o_NaN, o_/o_, o_xyzzy/o_xyzzy, o_[object Object]/o_[object Object], o_i,am,array/o_i,am,array
< String(): s_/s_, s_undefined/s_undefined, s_null/s_null, s_false/s_false, s_true/s_true, s_1.2345/s_1.2345, s_12/s_12, s_Infinity/s_Infinity, s_NaN/s_NaN, s_/s_, s_xyzzy/s_xyzzy, s_[object Object]/s_[object Object], s_i,am,array/s_i,am,array
< new Object(): o_[object Object]/o_[object Object], o_[object Object]/o_[object Object], o_[object Object]/o_[object Object], o_false/o_false, o_true/o_true, o_1.2345/o_1.2345, o_12/o_12, o_Infinity/o_Infinity, o_NaN/o_NaN, o_/o_, o_xyzzy/o_xyzzy, o_[object Object]/o_[object Object], o_i,am,array/o_i,am,array
< Object(): o_[object Object]/o_[object Object], o_[object Object]/o_[object Object], o_[object Object]/o_[object Object], o_false/o_false, o_true/o_true, o_1.2345/o_1.2345, o_12/o_12, o_Infinity/o_Infinity, o_NaN/o_NaN, o_/o_, o_xyzzy/o_xyzzy, o_[object Object]/o_[object Object], o_i,am,array/o_i,am,array
-
>     {
>         var o0 = new Object();
>         var o1 = new Object();
>         print("o0 === o1: " + (o0 === o1));
>         o0 = new Object();
>         o1 = new Object(o0);
>         print("o0 === o1: " + (o0 === o1));
>     }
>     
< o0 === o1: false
< o0 === o1: true
-
>     /*
>         According to 11.2.1 (and 8.7.1), any property access may result in a conversion of the target base (i.e. the
>         left-hand side of '.' or '[]') to an object (if it is a "primitive type"). A string is a "primitive type". This
>         means that, in theory, any subscript access ('[]') on a string requires the creation of a temporary full-blown
>         String object (which is then just thrown away).
>     
>         Workaround in NuXJS: strings are "shallow" objects meaning that they can't be extended but they have
>         properties that can be accessed without any object conversion / creation. Only member calls (on a member in
>         String.prototype) will actually convert "this" to a full-blown "deep" String object. Any such member call
>         *might* indirectly use "this" for extending the String so this is necessary to obtain 100% EcmaScript
>         compatibility.
>     */
>     
>     if (true) {
>         var breakOuts = [ ];
>         String.prototype.test = function(i, s) { breakOuts[i] = this; breakOuts[i].s = s; };
>         var s = "zxcv";
>         s.test(0, 'asdf');
>         s.test(1, 'qwerty');
>         print('delete String.prototype.test: ' + delete String.prototype.test);
>         print('typeof breakOuts[0]: ' + typeof breakOuts[0]);
>         print('typeof breakOuts[0].s: ' + typeof breakOuts[0].s);
>         print('breakOuts[0]: ' + breakOuts[0]);
>         print('breakOuts[0].s: ' + breakOuts[0].s);
>         print('breakOuts[1]: ' + breakOuts[1]);
>         print('breakOuts[1].s: ' + breakOuts[1].s);
>     }
< delete String.prototype.test: true
< typeof breakOuts[0]: object
< typeof breakOuts[0].s: string
< breakOuts[0]: zxcv
< breakOuts[0].s: asdf
< breakOuts[1]: zxcv
< breakOuts[1].s: qwerty
-
>     
>     /*
>         According to 15.7.4.4 Number.valueOf can't be transferred.
>     */
>     
>     {
>         var MyBoolean = function() { }
>         var MyNumber = function() { }
>         var MyString = function() { }
>     
>         MyBoolean.prototype = Boolean.prototype;
>         MyNumber.prototype = Number.prototype;
>         MyString.prototype = String.prototype;
>     
>         var myBoolean = new MyBoolean();
>         var myNumber = new MyNumber();
>         var myString = new MyString();
>         try { print("myBoolean: " + (myBoolean.valueOf())); } catch (x) { print("exception: " + x); }
>         try { print("myNumber: " + (+myNumber)); } catch (x) { print("exception: " + x); }
>         try { print("myString: " + (''+myString)); } catch (x) { print("exception: " + x); }
>     }
< exception: TypeError: Boolean.prototype.valueOf is not generic
< exception: TypeError: Number.prototype.valueOf is not generic
< exception: TypeError: String.prototype.valueOf is not generic
-
>     
>     {
>         for (i in { valueOf: 'test' }) print(i); // should print 'valueOf'
>         for (i in { somethingElse: 'test' }) print(i); // should print 'somethingElse'
>     }
< valueOf
< somethingElse
-
