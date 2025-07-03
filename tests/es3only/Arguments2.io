> function sort(a) {
> 	for (i = 0; i < a.length - 1; ++i) {
> 		for (j = i + 1; j < a.length; ++j) {
> 			if (a[j] < a[i]) {
> 				a[i] = [ a[j], a[j] = a[i] ][0];
> 			}
> 		}
> 	}
> 	return a;
> }
> var a = sort([ "pok", "adf", "viusdh", "oqritj", "qthreguajf", "avpok", "pok" ]);
> for (var i = 0; i < a.length; ++i) print(a[i]);
< adf
< avpok
< oqritj
< pok
< pok
< qthreguajf
< viusdh
-
> function contents(o) {
> 	var keys = [ ];
> 	for (var i in o) {
> 		keys[keys.length] = i;
> 	}
> 	sort(keys);
> 	var s = "{ ";
> 	for (var i = 0; i < keys.length; ++i) {
> 		s += keys[i] + ": " + o[keys[i]] + (i < keys.length - 1 ? ", " : ""); 
> 	}
> 	return s + " }";
> }
> print(contents({}));
> print(contents({ "kzxcjvn": "oaierjf", "goiegjf": "odisjv", "kjscnv": "oeriuf", "asdf": "poqker" }));
< {  }
< { asdf: poqker, goiegjf: odisjv, kjscnv: oeriuf, kzxcjvn: oaierjf }
-
> function analyzeFlags(object, property, testValue) {
>   property = '' + property;
> 	testValue = (testValue != null ? testValue : { });
>	if (!object.hasOwnProperty(property)) {
>		print(property + " : doesn't exist");
>	} else {
> 		var dontEnum = true;
> 		for (var p in object) {
> 			if (p === property) {
> 				dontEnum = false;
> 				break;
> 			}
> 		}
>		var doEnum = object.propertyIsEnumerable(property);
>		if (doEnum === dontEnum) {
>			print("object.propertyIsEnumerable() returned " + doEnum + " for property '" + property
>					+ "' although it " + (dontEnum ? "was not" : "was") + " listed by for-in");
>		}
> 		var valueWas = object[property];
> 		object[property] = testValue;
> 		var valueIs = object[property];
> 		var readOnly = (valueIs !== testValue);
> 		var deleted = delete object[property];
> 		var dontDelete = object.hasOwnProperty(property);
> 		print(property + " : " + (dontEnum ? "dontEnum," : "") + (readOnly ? "readOnly," : "")
> 				+ (dontDelete ? "dontDelete," : "") + " (deleted:" + deleted + ')');
> 		Object.defineProperty(object, property, { value: valueWas, enumerable: !dontEnum, configurable: !dontDelete, writable: !readOnly });
>	}
> }
-
> function f() {
>  print(contents(arguments));
>  print(arguments.length);
>  print(arguments['length']);
>  analyzeFlags(arguments, 'length');
>  print(typeof arguments.callee);
>  print(arguments.callee === f);
>  print(typeof arguments['callee']);
>  print(arguments['callee'] === f);
>  analyzeFlags(arguments, 'callee');
>  for (var i = 0; i < arguments.length; ++i) analyzeFlags(arguments, i);
>  print('-');
> }
-
> f();
< {  }
< 0
< 0
< length : dontEnum, (deleted:true)
< function
< true
< function
< true
< callee : dontEnum, (deleted:true)
< -
-
> f('abcd');
// ES5.1: 10.6: In Edition 5 the array indexed properties of argument objects that correspond to actual formal parameters are enumerable. In Edition 3, such properties were not enumerable.
// < { 0: abcd }
< {  }
< 1
< 1
< length : dontEnum, (deleted:true)
< function
< true
< function
< true
< callee : dontEnum, (deleted:true)
// ES5.1:
// < 0 :  (deleted:true)
< 0 : dontEnum, (deleted:true)
< -
-
> f('a', 'b', 'c', 'd');
// ES5.1:
// < { 0: a, 1: b, 2: c, 3: d }
< {  }
< 4
< 4
< length : dontEnum, (deleted:true)
< function
< true
< function
< true
< callee : dontEnum, (deleted:true)
// ES5.1:
// < 0 :  (deleted:true)
// < 1 :  (deleted:true)
// < 2 :  (deleted:true)
// < 3 :  (deleted:true)
< 0 : dontEnum, (deleted:true)
< 1 : dontEnum, (deleted:true)
< 2 : dontEnum, (deleted:true)
< 3 : dontEnum, (deleted:true)
< -
-
