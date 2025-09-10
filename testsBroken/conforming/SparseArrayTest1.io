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
> a=[]
-
> a[3]='x'
-
> print(contents(a));
< { 3: x }
-
> a[0]=1
-
> a[1]=2
-
> print(contents(a));
< { 0: 1, 1: 2, 3: x }
-
> a[2]=5
-
> print(contents(a));
< { 0: 1, 1: 2, 2: 5, 3: x }
-
> print(delete a[0])
< true
-
> print(contents(a));
< { 1: 2, 2: 5, 3: x }
-
> Object.defineProperty(a, '1', { value: 'x', writable: false, enumerable: false, configurable: false });
> Object.defineProperty(a, '4', { value: 'y', writable: false, enumerable: true, configurable: true });
-
> print(contents(a));
< { 2: 5, 3: x, 4: y }
-
> a[0]=234
-
> print(contents(a));
< { 0: 234, 2: 5, 3: x, 4: y }
-
> a[1]=20349
-
> print(contents(a));
< { 0: 234, 2: 5, 3: x, 4: y }
-
> print(delete a[1]);
< false
-
> print(contents(a));
< { 0: 234, 2: 5, 3: x, 4: y }
-
> print(delete a[4]);
< true
-
> print(contents(a));
< { 0: 234, 2: 5, 3: x }
-
> Array.prototype[5] = '123'
> print(Array.prototype.length);
< 6
-
> print(contents(a));
< { 0: 234, 2: 5, 3: x, 5: 123 }
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
> analyzeFlags(a, 0);
< 0 :  (deleted:true)
-
> analyzeFlags(a, 1);
< 1 : dontEnum,readOnly,dontDelete, (deleted:false)
-
> analyzeFlags(a, 2);
< 2 :  (deleted:true)
-
> analyzeFlags(a, 3);
< 3 :  (deleted:true)
-
> analyzeFlags(a, 4);
< 4 : doesn't exist
-
> analyzeFlags(a, 5);
< 5 : doesn't exist
-
> analyzeFlags(a, 'length', 19273812);
< length : dontEnum,dontDelete, (deleted:false)
-
> a[5] = 3993
> print(contents(a));
< { 0: 234, 2: 5, 3: x, 5: 3993 }
-
> analyzeFlags(a, 5);
< 5 :  (deleted:true)
-
