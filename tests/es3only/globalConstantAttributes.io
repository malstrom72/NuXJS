// ES3 15.1.1: the global value properties NaN, Infinity and undefined have the attributes { DontEnum, DontDelete }.
// ReadOnly is NOT among them, so in ES3 they are writable. (ES5.1 15.1.1 added ReadOnly — see the tests/es5 twin.)
> function flagsOf(name) {
> 	var was = this[name], enumerable = false;
> 	for (var k in this) if (k === name) enumerable = true;
> 	var deleted = (delete this[name]);
> 	this[name] = "written";
> 	var writable = (this[name] === "written");
> 	this[name] = was;
> 	return "enumerable:" + enumerable + " deletable:" + deleted + " writable:" + writable;
> }
-
> print(flagsOf("NaN"))
< enumerable:false deletable:false writable:true
> print(flagsOf("Infinity"))
< enumerable:false deletable:false writable:true
> print(flagsOf("undefined"))
< enumerable:false deletable:false writable:true
-
// The values themselves are the expected ones.
> print(isNaN(NaN)); print(Infinity); print(typeof undefined)
< true
< Infinity
< undefined
-
