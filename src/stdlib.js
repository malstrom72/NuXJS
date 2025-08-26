/*
	@preserve: Array,Boolean,Date,E,Error,Function,Infinity,LN10,LN2,LOG10E,LOG2E,MAX_VALUE,MIN_VALUE,Math
	@preserve: NEGATIVE_INFINITY,NaN,Number,Object,PI,POSITIVE_INFINITY,RangeError,RegExp,SQRT1_2,SQRT2,String
	@preserve: SyntaxError,TypeError,UTC,abs,acos,apply,arguments,asin,atan,atan2,break,call,callWithArgs,case,ceil
	@preserve: charAt,charCodeAt,configurable,concat,cos,default,defineProperty,delete,do,dontDelete,dontEnum,get,set
	@preserve: else,enumerable,eval,exec,exp,false,finally,floor,for,fromCharCode,function,getCurrentTime
	@preserve: getDate,getDay,getFullYear,getHours,getInternalProperty,getMilliseconds,getMinutes,getMonth
	@preserve: getPrototypeOf,getSeconds,getTime,getTimezoneOffset,getUTCDate,getUTCDay,getUTCFullYear,getUTCHours
	@preserve: getUTCMilliseconds,getUTCMinutes,getUTCMonth,getUTCSeconds,hasOwnProperty,if,ignoreCase,in,index,indexOf
	@preserve: input,isArray,isFinite,isNaN,isPropertyEnumerable,join,lastIndex,lastIndexOf,length,localeCompare,log
	@preserve: match,max,maxNumber,message,min,minNumber,multiline,name,new,now,null,parseFloat,parseInt,pow
	@preserve: propertyIsEnumerable,prototype,push,readOnly,regExpCanonicalize,return,reverse,round,setDate
	@preserve: setFullYear,setHours,setMilliseconds,setMinutes,setMonth,setSeconds,setTime,setUTCDate
	@preserve: setUTCFullYear,setUTCHours,setUTCMilliseconds,setUTCMinutes,setUTCMonth,setUTCSeconds,shift,sin,slice
	@preserve: sort,distinctConstructor,sqrt,submatch,substr,substring,switch,tan,this,throw,time,toExponential
	@preserve: toFixed,toISOString,toLocaleDateString,toLocaleLowerCase,toLocaleString,toLocaleTimeString
	@preserve: toLocaleUpperCase,toLowerCase,toPrecision,toString,toTimeString,toUTCString,toUpperCase,trim,trimLeft,trimRight,true,try,typeof
	@preserve: undefined,upperToLower,value,valueOf,var,void,while,writable,pop,parse,toDateString,instanceof,test
	@preserve: toPrimitiveNumber,toPrimitiveString,constructor,isPrototypeOf,prototypes,createWrapper,$match
	@preserve: $sub,createRegExp,CC,global,source,JSON,stringify,toJSON,unshift,compileFunction,localTimeDifference
	@preserve: splice,split,search,replace,random,evalFunction,updateDateValue,toPrimitive
	support: {
	prototypes: {	// built-in prototype objects
	object, function, string, boolean, number, date, array
	},
	eval(code: string): any
	asin(), atan() etc..
	isNaN(), isFinite()
	defineProperty(o: object, property: string, value: any, readOnly: boolean, dontEnum: boolean, dontDelete: boolean): boolean
	compileFunction(sourceCode: string, name: string): function
	createWrapper(className: string, internalValue: any, prototype: object): object
	distinctConstructor(regularCall: function): function									// = exception on construction and no .prototype either
	distinctConstructor(regularCall: function, constructorCall: function): function
	callWithArgs(func: function, [this: object], [args: array], [offset: number]): any
	getInternalProperty(o: object, "class"|"value"|"prototype"): any
	hasOwnProperty(o: object, name: string): boolean
	isPropertyEnumerable(o: object, name: string): boolean
	pow(x: number, y: number): number
	parseFloat(s: string) : number
	charCodeAt(s: string, i: number): string
	substring(s: string, from: number, to: number): string
	submatch(text: string, offset: number, match: string): boolean
	getCurrentTime(): number
	localTimeDifference(epochTime: number): number
	updateDateValue(o: object, v: number): number
	acos(x: number): number
	asin(x: number): number
	atan(x: number): number
	cos(x: number): number
	exp(x: number): number
	floor(x: number): number
	log(x: number): number
	random(): number
	sin(x: number): number
	sqrt(x: number): number
	tan(x: number): number
	undefined
	NaN
	Infinity
	}
	*/
	(function(support) {
	var globals = this;
	var unconstructable = support.distinctConstructor; // these are the same now, but not guaranteed in the future
	var $isNaN = support.isNaN, $isFinite = support.isFinite, $floor = support.floor, $NaN = support.NaN
	, $Infinity = support.Infinity, $match = support.submatch, $sub = support.substring // "$match" and "$sub" are used from within regexps, so names has to be preserved
	, $getInternalProperty = support.getInternalProperty, $callWithArgs = support.callWithArgs
	, $charCodeAt = support.charCodeAt, abs, syntaxError, rangeError, typeError
	, ALPHA_DIGITS_LOWER = "0123456789abcdefghijklmnopqrstuvwxyz", ALPHA_DIGITS_UPPER = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"
	, WHITE_SPACES = " \f\n\r\t\v\xA0\u2028\u2029";
	var PARSE_INT_CHARS = (function() {
	var pic = { }, ws = WHITE_SPACES;
	for (var i = ws.length - 1; i >= 0; --i) {
	pic[ws[i]] = null;
	}
	var adl = ALPHA_DIGITS_LOWER, adu = ALPHA_DIGITS_UPPER;
	for (var i = adl.length - 1; i >= 0; --i) {
	pic[adl[i]] = i;
	pic[adu[i]] = i;
	}
	return pic
	})();
	function StringBuilder() {
	var i = 20, b = this.buffers = [ ];
	do { b[--i] = '' } while (i > 0)
	}
	StringBuilder.prototype.append = function append(s) {
	for (var i = 0, n = 256, b = this.buffers; (b[i] += s).length >= n && i < 20; n <<= 1, ++i) {
	s = b[i];
	b[i] = ''
	}
	return this;
	};
	StringBuilder.prototype.build = function build() {
	var i, b, s = (b = this.buffers)[i = 19];
	do { s += b[--i] } while (i > 0);
	return s
	};
	function isPrimitive(v) {
	var v, t;
	return (((t = typeof v) !== "object" || v === null) && t !== "function")
	}
	function objectToPrimitive(o, f1, f2) {
	var v;
	if ((typeof (o[f1]) !== "function" || !isPrimitive(v = o[f1]()))
	&& (typeof (o[f2]) !== "function" || !isPrimitive(v = o[f2]()))) {
	throw typeError("Error converting object to primitive type");
	}
	return v
	}
	support.toPrimitiveNumber = function(o) { return objectToPrimitive(o, "valueOf", "toString"); };
	support.toPrimitiveString = function(o) { return objectToPrimitive(o, "toString", "valueOf"); };
	support.toPrimitive = function(o) {
	return support[$getInternalProperty(o, "class") === "Date" ? "toPrimitiveString" : "toPrimitiveNumber"](o);
	};
	function int(v) { return $isNaN(v = +v) ? 0 : (!$isFinite(v) ? v : (v < 0 ? -$floor(-v) : $floor(v))); }
	function int32(v) { return int(v) | 0; }
	function uint32(v) { return int(v) >>> 0; }
	// TODO : what a waste of cycles, could be a simple OBJ_TO_STRING, problem with ''+s is that it uses OBJ_TO_NUMBER which only affects the priority of toString vs valueOf... so subtle!
	function str(o) { return '' + (isPrimitive(o) ? o : support.toPrimitiveString(o)) }
	function defineProperties(object, attribs, props) {
	var ro = attribs.readOnly, de = attribs.dontEnum, dd = attribs.dontDelete;
	for (var p in props) support.defineProperty(object, p, props[p], ro, de, dd);
	return object
	}
	function checkClass(object, expectedClass, forFunction) {
	if ($getInternalProperty(object, "class") !== expectedClass) {
	throw typeError(expectedClass + ".prototype." + forFunction + " is not generic");
	}
	}
	function leftPad(s, l) { var n = (s = "00000000000000000000" + s).length; return $sub(s, n - l, n); }
	function numberToString(num, digits, eNotationBelow) {
	var string = '';
	if (num < 0) {
	num = -num;
	string = '-';
	}
	var significand = 0, exponent = 0, magnitude;
	if (num !== 0) {
	if (num < 1e-323) {
	exponent = -324;
	significand = num / 1e-323 * 10.0;
	} else {
	if ((exponent = $floor(support.log(num) * 0.43429448190325182765113)) < -323) exponent = -323;
	if (num >= (magnitude = support.pow(10, exponent)) * 10.0) {
	magnitude *= 10.0;
	++exponent;
	}
	significand = num / magnitude;
	}
	}
	if (digits === void 0) string += significand;
	else {
	magnitude = support.pow(10, digits);
	var integer = $floor(significand), decimals = $floor((significand - integer) * magnitude + 0.5);
	integer += (decimals >= magnitude ? 1 : 0);
	if (integer >= 10) {
	integer = 1;
	++exponent;
	}
	if (exponent >= eNotationBelow && exponent <= digits) {
	digits -= exponent;
	magnitude = support.pow(10, digits);
	integer = $floor(num);
	decimals = $floor((num - integer) * magnitude + 0.5);
	if (decimals >= magnitude) ++integer;
	exponent = null;
	}
	string += integer;
	if (digits > 0) string += '.' + leftPad(decimals, digits);
	}
	if (exponent !== null) string += (exponent >= 0 ? "e+" : 'e') + exponent;
	return string
	}
	function numberToRadix(val, radix) {
	var sign = '', s = '';
	if ((val = int(val)) < 0) {
	val = -val;
	sign = '-';
	}
	do { s = ALPHA_DIGITS_LOWER[val % radix] + s } while ((val = $floor(val / radix)) > 0);
	return sign + s;
	}
	// eval without loads of local variables but with access to all internals
	function evalThere(s) {
	var customEval = eval;
	eval = support.evalFunction; // must reassign for "direct mode" eval
	try { return eval(s); } finally { eval = customEval; }
	}
	/* --- Object --- */
	var Object = function Object(v) {
	switch (typeof v) {
	case "object":
	case "function": if (v !== null) return v;
	case "undefined": return { };
	case "boolean": return new Boolean(v);
	case "number": return new Number(v);
	case "string": return new String(v);
	}
	};
	defineProperties(Object, { dontEnum: true, readOnly: true, dontDelete: true }, { prototype: support.prototypes.Object });
	defineProperties(Object.prototype, { dontEnum: true }, {
	constructor: Object,
	valueOf: unconstructable(function valueOf() { return this }),
	toLocaleString: unconstructable(function toLocaleString() { return this.toString() }),
	toString: unconstructable(function toString() {
	var s;
	return "[object " + (((s = $getInternalProperty(this, "class")) === "Arguments") ? "Object" : s) + ']'
	}),
	hasOwnProperty: unconstructable(function hasOwnProperty(name) { return support.hasOwnProperty(this, str(name)) }),
	propertyIsEnumerable: unconstructable(function propertyIsEnumerable(name) { return support.isPropertyEnumerable(this, str(name)) }),
	isPrototypeOf: unconstructable(function isPrototypeOf(v) {
	while (v = $getInternalProperty(v, "prototype")) {
	if (v === this) return true;
	}
	return false;
	})
	});
	/* --- Function --- */
	var Function = function Function(body) {
	var argv, src = '(', n = (argv = arguments).length - 1;
	for (var i = 0; i < n; ++i) {
	src += argv[i];
	if (i < n - 1) src += ',';
	}
	src += ") {\n";
	if (n >= 0) src += argv[n];
	return support.compileFunction(src + "\n}", "anonymous")
	};
	defineProperties(Function, { dontEnum: true, readOnly: true, dontDelete: true }, { prototype: support.prototypes.Function });
	defineProperties(Function.prototype, { dontEnum: true }, {
	constructor: Function,
	apply: unconstructable(function apply(thisArg, argArray) { // FIX : <- 100% native version in the future I think
	var theClass;
	if (argArray == null) argArray = [ ];
	else if ((theClass = $getInternalProperty(argArray, "class")) !== "Array" && theClass !== "Arguments") {
	throw typeError("Argument list has wrong type");
	};
	return $callWithArgs(this, thisArg, argArray);
	}),
	call: unconstructable(function call(thisArg) { // FIX : <- 100% native version in the future I think
	return $callWithArgs(this, thisArg, arguments, 1);
	}),
	toString: unconstructable(function toString() { // FIX : <- generic, make a factory function
	checkClass(this, "Function", "toString");
	return $getInternalProperty(this, "value");
	})
	});
	/* --- Boolean --- */
	var Boolean = support.distinctConstructor(function Boolean(v) {
	return !!v;
	}, function Boolean(v) {
	return support.createWrapper("Boolean", !!v, support.prototypes.Boolean);
	});
	defineProperties(Boolean, { dontEnum: true, readOnly: true, dontDelete: true }, { prototype: support.prototypes.Boolean });
	defineProperties(Boolean.prototype, { dontEnum: true }, {
	constructor: Boolean,
	valueOf: unconstructable(function valueOf() {
	checkClass(this, "Boolean", "valueOf");
	return $getInternalProperty(this, "value");
	}),
	toString: unconstructable(function toString() {
	checkClass(this, "Boolean", "toString");
	return '' + $getInternalProperty(this, "value");
	})
	});
	/* --- Number --- */
	function getInternalNumber(object, forFunction) {
	checkClass(object, "Number", forFunction);
	return $getInternalProperty(object, "value")
	}
	var Number = support.distinctConstructor(function Number(v) {
	return (arguments.length ? +v : 0);
	}, function Number(v) {
	return support.createWrapper("Number", arguments.length ? +v : 0, support.prototypes.Number);
	});
	defineProperties(Number, { dontEnum: true, readOnly: true, dontDelete: true }, { prototype: support.prototypes.Number });
	defineProperties(Number, { dontEnum: true, readOnly: true, dontDelete: true }, {
	MAX_VALUE: support.maxNumber,
	MIN_VALUE: support.minNumber,
	NaN: $NaN,
	NEGATIVE_INFINITY: -$Infinity,
	POSITIVE_INFINITY: $Infinity
	});
	defineProperties(Number.prototype, { dontEnum: true }, {
	constructor: Number,
	valueOf: unconstructable(function valueOf() { return getInternalNumber(this, "valueOf") }),
	toLocaleString: Object.prototype.toLocaleString,
	toString: unconstructable(function toString(radix) {
	var val = getInternalNumber(this, "toString");
	if (radix === void 0 || !$isFinite(val)) return '' + val;
	else if ((radix = int(radix)) < 2 || radix > 36) throw rangeError("Illegal radix for toString()");
	else return numberToRadix(val, radix);
	}),
	toExponential: unconstructable(function toExponential(fractionDigits) {
	var val, digits;
	if (!$isFinite(val = getInternalNumber(this, "toExponential"))) return val;
	else if (fractionDigits === void 0) return numberToString(val, void 0, $Infinity);
	else {
	if ((digits = int(fractionDigits)) < 0 || digits > 20) {
	throw rangeError("Illegal fractionDigits argument for toExponential()");
	}
	return numberToString(val, digits, $Infinity);
	}
	}),
	toFixed: unconstructable(function toFixed(fractionDigits) {
	var val, digits;
	if ((digits = int(fractionDigits)) < 0 || digits > 20) {
	throw rangeError("Illegal fractionDigits argument for toFixed()");
	}
	if ($isNaN(val = getInternalNumber(this, "toFixed")) || val <= -1e21 || val >= 1e21) return '' + val;
	else {
	var s = '';
	if (val < 0) {
	val = -val;
	s = '-';
	}
	var magnitude = support.pow(10, digits);
	var integer = $floor(val);
	var decimals = $floor((val - integer) * magnitude + 0.5);
	s += integer + (decimals >= magnitude ? 1 : 0);
	if (digits > 0) {
	s += '.' + leftPad(decimals, digits);
	}
	return s;
	}
	}),
	toPrecision: unconstructable(function toPrecision(precision) {
	var val = getInternalNumber(this, "toPrecision"), digits;
	if (precision === void 0 || !$isFinite(val)) return val;
	else {
	if ((digits = int(precision) - 1) < 0 || digits > 20) {
	throw rangeError("Illegal precision argument for toPrecision()");
	}
	return numberToString(val, digits, -6);
	}
	})
	});
	/* --- String --- */
	var lowerToUpper, upperToLower; // "upperToLower" is used from within regexps, so the name has to be preserved
	function createCaseTables() {
	// In the future constant tables might be (nearly) free to setup, but as of 20160423 this is quite "expensive".
	lowerToUpper = {
	"\xdf":"SS","\u0131":"I","\u0149":"\u02bcn","\u017f":"S","\u01c5":"\u01c4","\u01c8":"\u01c7","\u01cb":"\u01ca","\u01f0":"j\u030c","\u01f2":"\u01f1","\u0345":"\u0399","\u0390":"\u03b9\u0308\u030d","\u03b0":"\u03c5\u0308\u030d","\u03c2":"\u03a3","\u03d0":"\u0392","\u03d1":"\u0398","\u03d5":"\u03a6","\u03d6":"\u03a0","\u03f0":"\u039a","\u03f1":"\u03a1","\u03f2":"\u03a3","\u0587":"\u0535\u0552","\u1e96":"h\u0331","\u1e97":"t\u0308","\u1e98":"w\u030a","\u1e99":"y\u030a","\u1e9a":"a\u02be","\u1e9b":"\u1e60","\u1f50":"\u03c5\u0313","\u1f52":"\u03c5\u0313\u0300",
	"\u1f54":"\u03c5\u0313\u0301","\u1f56":"\u03c5\u0313\u0342","\u1f80":"\u1f08\u03b9","\u1f81":"\u1f09\u03b9","\u1f82":"\u1f0a\u03b9","\u1f83":"\u1f0b\u03b9","\u1f84":"\u1f0c\u03b9","\u1f85":"\u1f0d\u03b9","\u1f86":"\u1f0e\u03b9","\u1f87":"\u1f0f\u03b9","\u1f88":"\u1f08\u03b9","\u1f90":"\u1f28\u03b9","\u1f91":"\u1f29\u03b9","\u1f92":"\u1f2a\u03b9","\u1f93":"\u1f2b\u03b9","\u1f94":"\u1f2c\u03b9","\u1f95":"\u1f2d\u03b9","\u1f96":"\u1f2e\u03b9","\u1f97":"\u1f2f\u03b9","\u1fa0":"\u1f68\u03b9","\u1fa1":"\u1f69\u03b9","\u1fa2":"\u1f6a\u03b9","\u1fa3":"\u1f6b\u03b9",
	"\u1fa4":"\u1f6c\u03b9","\u1fa5":"\u1f6d\u03b9","\u1fa6":"\u1f6e\u03b9","\u1fa7":"\u1f6f\u03b9","\u1fb2":"\u1f70\u03b9","\u1fb3":"\u0391\u03b9","\u1fb4":"\u1f71\u03b9","\u1fb6":"\u03b1\u0342","\u1fb7":"\u1fb6\u03b9","\u1fbe":"\u0399","\u1fc2":"\u1f74\u03b9","\u1fc3":"\u0397\u03b9","\u1fc4":"\u1f75\u03b9","\u1fc6":"\u03b7\u0342","\u1fc7":"\u1fc6\u03b9","\u1fd2":"\u03b9\u0308\u0300","\u1fd3":"\u03b9\u0308\u0301","\u1fd6":"\u03b9\u0342","\u1fd7":"\u03b9\u0308\u0342","\u1fe2":"\u03c5\u0308\u0300","\u1fe3":"\u03c5\u0308\u0301","\u1fe4":"\u03c1\u0313","\u1fe6":"\u03c5\u0342",
	"\u1fe7":"\u03c5\u0308\u0342","\u1ff2":"\u1f7c\u03b9","\u1ff3":"\u03a9\u03b9","\u1ff4":"\u1f7d\u03b9","\u1ff6":"\u03c9\u0342","\u1ff7":"\u1ff6\u03b9","\ufb00":"FF","\ufb01":"FI","\ufb02":"FL","\ufb03":"FFI","\ufb04":"FFL","\ufb05":"ST","\ufb06":"ST","\ufb13":"\u0544\u0546","\ufb14":"\u0544\u0535","\ufb15":"\u0544\u053b","\ufb16":"\u054e\u0546","\ufb17":"\u0544\u053d"
	};
	upperToLower = {
	"\u0130":"i","\u01c5":"\u01c6","\u01c8":"\u01c9","\u01cb":"\u01cc","\u01f2":"\u01f3","\u10a0":"\u10d0","\u10a1":"\u10d1","\u10a2":"\u10d2","\u10a3":"\u10d3","\u10a4":"\u10d4","\u10a5":"\u10d5","\u10a6":"\u10d6","\u10a7":"\u10d7","\u10a8":"\u10d8","\u10a9":"\u10d9","\u10aa":"\u10da","\u10ab":"\u10db","\u10ac":"\u10dc","\u10ad":"\u10dd","\u10ae":"\u10de","\u10af":"\u10df","\u10b0":"\u10e0","\u10b1":"\u10e1","\u10b2":"\u10e2","\u10b3":"\u10e3","\u10b4":"\u10e4","\u10b5":"\u10e5","\u10b6":"\u10e6","\u10b7":"\u10e7","\u10b8":"\u10e8","\u10b9":"\u10e9","\u10ba":"\u10ea",
	"\u10bb":"\u10eb","\u10bc":"\u10ec","\u10bd":"\u10ed","\u10be":"\u10ee","\u10bf":"\u10ef","\u10c0":"\u10f0","\u10c1":"\u10f1","\u10c2":"\u10f2","\u10c3":"\u10f3","\u10c4":"\u10f4","\u10c5":"\u10f5","\u1f88":"\u1f80","\u1f89":"\u1f81","\u1f8a":"\u1f82","\u1f8b":"\u1f83","\u1f8c":"\u1f84","\u1f8d":"\u1f85","\u1f8e":"\u1f86","\u1f8f":"\u1f87","\u1f98":"\u1f90","\u1f99":"\u1f91","\u1f9a":"\u1f92","\u1f9b":"\u1f93","\u1f9c":"\u1f94","\u1f9d":"\u1f95","\u1f9e":"\u1f96","\u1f9f":"\u1f97","\u1fa8":"\u1fa0","\u1fa9":"\u1fa1","\u1faa":"\u1fa2","\u1fab":"\u1fa3","\u1fac":"\u1fa4",
	"\u1fad":"\u1fa5","\u1fae":"\u1fa6","\u1faf":"\u1fa7","\u1fbc":"\u1fb3","\u1fcc":"\u1fc3","\u1ffc":"\u1ff3"
	};
	var c, BIDIRECTIONAL = {
	'A':"a",'B':"b",'C':"c",'D':"d",'E':"e",'F':"f",'G':"g",'H':"h",'I':"i",'J':"j",'K':"k",'L':"l",'M':"m",'N':"n",'O':"o",'P':"p",'Q':"q",'R':"r",'S':"s",'T':"t",'U':"u",'V':"v",'W':"w",'X':"x",'Y':"y",'Z':"z",
	"\xc0":"\xe0","\xc1":"\xe1","\xc2":"\xe2","\xc3":"\xe3","\xc4":"\xe4","\xc5":"\xe5","\xc6":"\xe6","\xc7":"\xe7","\xc8":"\xe8","\xc9":"\xe9","\xca":"\xea","\xcb":"\xeb","\xcc":"\xec","\xcd":"\xed","\xce":"\xee","\xcf":"\xef","\xd0":"\xf0","\xd1":"\xf1","\xd2":"\xf2","\xd3":"\xf3","\xd4":"\xf4","\xd5":"\xf5","\xd6":"\xf6","\xd8":"\xf8","\xd9":"\xf9","\xda":"\xfa","\xdb":"\xfb","\xdc":"\xfc","\xdd":"\xfd","\xde":"\xfe",
	"\u0100":"\u0101","\u0102":"\u0103","\u0104":"\u0105","\u0106":"\u0107","\u0108":"\u0109","\u010a":"\u010b","\u010c":"\u010d","\u010e":"\u010f","\u0110":"\u0111","\u0112":"\u0113","\u0114":"\u0115","\u0116":"\u0117","\u0118":"\u0119","\u011a":"\u011b","\u011c":"\u011d","\u011e":"\u011f","\u0120":"\u0121","\u0122":"\u0123","\u0124":"\u0125","\u0126":"\u0127","\u0128":"\u0129","\u012a":"\u012b","\u012c":"\u012d","\u012e":"\u012f","\u0132":"\u0133","\u0134":"\u0135","\u0136":"\u0137","\u0139":"\u013a","\u013b":"\u013c","\u013d":"\u013e","\u013f":"\u0140","\u0141":"\u0142",
	"\u0143":"\u0144","\u0145":"\u0146","\u0147":"\u0148","\u014a":"\u014b","\u014c":"\u014d","\u014e":"\u014f","\u0150":"\u0151","\u0152":"\u0153","\u0154":"\u0155","\u0156":"\u0157","\u0158":"\u0159","\u015a":"\u015b","\u015c":"\u015d","\u015e":"\u015f","\u0160":"\u0161","\u0162":"\u0163","\u0164":"\u0165","\u0166":"\u0167","\u0168":"\u0169","\u016a":"\u016b","\u016c":"\u016d","\u016e":"\u016f","\u0170":"\u0171","\u0172":"\u0173","\u0174":"\u0175","\u0176":"\u0177","\u0178":"\xff","\u0179":"\u017a","\u017b":"\u017c","\u017d":"\u017e","\u0181":"\u0253","\u0182":"\u0183",
	"\u0184":"\u0185","\u0186":"\u0254","\u0187":"\u0188","\u0189":"\u0256","\u018a":"\u0257","\u018b":"\u018c","\u018e":"\u01dd","\u018f":"\u0259","\u0190":"\u025b","\u0191":"\u0192","\u0193":"\u0260","\u0194":"\u0263","\u0196":"\u0269","\u0197":"\u0268","\u0198":"\u0199","\u019c":"\u026f","\u019d":"\u0272","\u019f":"\u0275","\u01a0":"\u01a1","\u01a2":"\u01a3","\u01a4":"\u01a5","\u01a6":"\u0280","\u01a7":"\u01a8","\u01a9":"\u0283","\u01ac":"\u01ad","\u01ae":"\u0288","\u01af":"\u01b0","\u01b1":"\u028a","\u01b2":"\u028b","\u01b3":"\u01b4","\u01b5":"\u01b6","\u01b7":"\u0292",
	"\u01b8":"\u01b9","\u01bc":"\u01bd","\u01c4":"\u01c6","\u01c7":"\u01c9","\u01ca":"\u01cc","\u01cd":"\u01ce","\u01cf":"\u01d0","\u01d1":"\u01d2","\u01d3":"\u01d4","\u01d5":"\u01d6","\u01d7":"\u01d8","\u01d9":"\u01da","\u01db":"\u01dc","\u01de":"\u01df","\u01e0":"\u01e1","\u01e2":"\u01e3","\u01e4":"\u01e5","\u01e6":"\u01e7","\u01e8":"\u01e9","\u01ea":"\u01eb","\u01ec":"\u01ed","\u01ee":"\u01ef","\u01f1":"\u01f3","\u01f4":"\u01f5","\u01fa":"\u01fb","\u01fc":"\u01fd","\u01fe":"\u01ff","\u0200":"\u0201","\u0202":"\u0203","\u0204":"\u0205","\u0206":"\u0207","\u0208":"\u0209",
	"\u020a":"\u020b","\u020c":"\u020d","\u020e":"\u020f","\u0210":"\u0211","\u0212":"\u0213","\u0214":"\u0215","\u0216":"\u0217","\u0386":"\u03ac","\u0388":"\u03ad","\u0389":"\u03ae","\u038a":"\u03af","\u038c":"\u03cc","\u038e":"\u03cd","\u038f":"\u03ce","\u0391":"\u03b1","\u0392":"\u03b2","\u0393":"\u03b3","\u0394":"\u03b4","\u0395":"\u03b5","\u0396":"\u03b6","\u0397":"\u03b7","\u0398":"\u03b8","\u0399":"\u03b9","\u039a":"\u03ba","\u039b":"\u03bb","\u039c":"\u03bc","\u039d":"\u03bd","\u039e":"\u03be","\u039f":"\u03bf","\u03a0":"\u03c0","\u03a1":"\u03c1","\u03a3":"\u03c3",
	"\u03a4":"\u03c4","\u03a5":"\u03c5","\u03a6":"\u03c6","\u03a7":"\u03c7","\u03a8":"\u03c8","\u03a9":"\u03c9","\u03aa":"\u03ca","\u03ab":"\u03cb","\u03e2":"\u03e3","\u03e4":"\u03e5","\u03e6":"\u03e7","\u03e8":"\u03e9","\u03ea":"\u03eb","\u03ec":"\u03ed","\u03ee":"\u03ef","\u0401":"\u0451","\u0402":"\u0452","\u0403":"\u0453","\u0404":"\u0454","\u0405":"\u0455","\u0406":"\u0456","\u0407":"\u0457","\u0408":"\u0458","\u0409":"\u0459","\u040a":"\u045a","\u040b":"\u045b","\u040c":"\u045c","\u040e":"\u045e","\u040f":"\u045f","\u0410":"\u0430","\u0411":"\u0431","\u0412":"\u0432",
	"\u0413":"\u0433","\u0414":"\u0434","\u0415":"\u0435","\u0416":"\u0436","\u0417":"\u0437","\u0418":"\u0438","\u0419":"\u0439","\u041a":"\u043a","\u041b":"\u043b","\u041c":"\u043c","\u041d":"\u043d","\u041e":"\u043e","\u041f":"\u043f","\u0420":"\u0440","\u0421":"\u0441","\u0422":"\u0442","\u0423":"\u0443","\u0424":"\u0444","\u0425":"\u0445","\u0426":"\u0446","\u0427":"\u0447","\u0428":"\u0448","\u0429":"\u0449","\u042a":"\u044a","\u042b":"\u044b","\u042c":"\u044c","\u042d":"\u044d","\u042e":"\u044e","\u042f":"\u044f","\u0460":"\u0461","\u0462":"\u0463","\u0464":"\u0465",
	"\u0466":"\u0467","\u0468":"\u0469","\u046a":"\u046b","\u046c":"\u046d","\u046e":"\u046f","\u0470":"\u0471","\u0472":"\u0473","\u0474":"\u0475","\u0476":"\u0477","\u0478":"\u0479","\u047a":"\u047b","\u047c":"\u047d","\u047e":"\u047f","\u0480":"\u0481","\u0490":"\u0491","\u0492":"\u0493","\u0494":"\u0495","\u0496":"\u0497","\u0498":"\u0499","\u049a":"\u049b","\u049c":"\u049d","\u049e":"\u049f","\u04a0":"\u04a1","\u04a2":"\u04a3","\u04a4":"\u04a5","\u04a6":"\u04a7","\u04a8":"\u04a9","\u04aa":"\u04ab","\u04ac":"\u04ad","\u04ae":"\u04af","\u04b0":"\u04b1","\u04b2":"\u04b3",
	"\u04b4":"\u04b5","\u04b6":"\u04b7","\u04b8":"\u04b9","\u04ba":"\u04bb","\u04bc":"\u04bd","\u04be":"\u04bf","\u04c1":"\u04c2","\u04c3":"\u04c4","\u04c7":"\u04c8","\u04cb":"\u04cc","\u04d0":"\u04d1","\u04d2":"\u04d3","\u04d4":"\u04d5","\u04d6":"\u04d7","\u04d8":"\u04d9","\u04da":"\u04db","\u04dc":"\u04dd","\u04de":"\u04df","\u04e0":"\u04e1","\u04e2":"\u04e3","\u04e4":"\u04e5","\u04e6":"\u04e7","\u04e8":"\u04e9","\u04ea":"\u04eb","\u04ee":"\u04ef","\u04f0":"\u04f1","\u04f2":"\u04f3","\u04f4":"\u04f5","\u04f8":"\u04f9","\u0531":"\u0561","\u0532":"\u0562","\u0533":"\u0563",
	"\u0534":"\u0564","\u0535":"\u0565","\u0536":"\u0566","\u0537":"\u0567","\u0538":"\u0568","\u0539":"\u0569","\u053a":"\u056a","\u053b":"\u056b","\u053c":"\u056c","\u053d":"\u056d","\u053e":"\u056e","\u053f":"\u056f","\u0540":"\u0570","\u0541":"\u0571","\u0542":"\u0572","\u0543":"\u0573","\u0544":"\u0574","\u0545":"\u0575","\u0546":"\u0576","\u0547":"\u0577","\u0548":"\u0578","\u0549":"\u0579","\u054a":"\u057a","\u054b":"\u057b","\u054c":"\u057c","\u054d":"\u057d","\u054e":"\u057e","\u054f":"\u057f","\u0550":"\u0580","\u0551":"\u0581","\u0552":"\u0582","\u0553":"\u0583",
	"\u0554":"\u0584","\u0555":"\u0585","\u0556":"\u0586","\u1e00":"\u1e01","\u1e02":"\u1e03","\u1e04":"\u1e05","\u1e06":"\u1e07","\u1e08":"\u1e09","\u1e0a":"\u1e0b","\u1e0c":"\u1e0d","\u1e0e":"\u1e0f","\u1e10":"\u1e11","\u1e12":"\u1e13","\u1e14":"\u1e15","\u1e16":"\u1e17","\u1e18":"\u1e19","\u1e1a":"\u1e1b","\u1e1c":"\u1e1d","\u1e1e":"\u1e1f","\u1e20":"\u1e21","\u1e22":"\u1e23","\u1e24":"\u1e25","\u1e26":"\u1e27","\u1e28":"\u1e29","\u1e2a":"\u1e2b","\u1e2c":"\u1e2d","\u1e2e":"\u1e2f","\u1e30":"\u1e31","\u1e32":"\u1e33","\u1e34":"\u1e35","\u1e36":"\u1e37","\u1e38":"\u1e39",
	"\u1e3a":"\u1e3b","\u1e3c":"\u1e3d","\u1e3e":"\u1e3f","\u1e40":"\u1e41","\u1e42":"\u1e43","\u1e44":"\u1e45","\u1e46":"\u1e47","\u1e48":"\u1e49","\u1e4a":"\u1e4b","\u1e4c":"\u1e4d","\u1e4e":"\u1e4f","\u1e50":"\u1e51","\u1e52":"\u1e53","\u1e54":"\u1e55","\u1e56":"\u1e57","\u1e58":"\u1e59","\u1e5a":"\u1e5b","\u1e5c":"\u1e5d","\u1e5e":"\u1e5f","\u1e60":"\u1e61","\u1e62":"\u1e63","\u1e64":"\u1e65","\u1e66":"\u1e67","\u1e68":"\u1e69","\u1e6a":"\u1e6b","\u1e6c":"\u1e6d","\u1e6e":"\u1e6f","\u1e70":"\u1e71","\u1e72":"\u1e73","\u1e74":"\u1e75","\u1e76":"\u1e77","\u1e78":"\u1e79",
	"\u1e7a":"\u1e7b","\u1e7c":"\u1e7d","\u1e7e":"\u1e7f","\u1e80":"\u1e81","\u1e82":"\u1e83","\u1e84":"\u1e85","\u1e86":"\u1e87","\u1e88":"\u1e89","\u1e8a":"\u1e8b","\u1e8c":"\u1e8d","\u1e8e":"\u1e8f","\u1e90":"\u1e91","\u1e92":"\u1e93","\u1e94":"\u1e95","\u1ea0":"\u1ea1","\u1ea2":"\u1ea3","\u1ea4":"\u1ea5","\u1ea6":"\u1ea7","\u1ea8":"\u1ea9","\u1eaa":"\u1eab","\u1eac":"\u1ead","\u1eae":"\u1eaf","\u1eb0":"\u1eb1","\u1eb2":"\u1eb3","\u1eb4":"\u1eb5","\u1eb6":"\u1eb7","\u1eb8":"\u1eb9","\u1eba":"\u1ebb","\u1ebc":"\u1ebd","\u1ebe":"\u1ebf","\u1ec0":"\u1ec1","\u1ec2":"\u1ec3",
	"\u1ec4":"\u1ec5","\u1ec6":"\u1ec7","\u1ec8":"\u1ec9","\u1eca":"\u1ecb","\u1ecc":"\u1ecd","\u1ece":"\u1ecf","\u1ed0":"\u1ed1","\u1ed2":"\u1ed3","\u1ed4":"\u1ed5","\u1ed6":"\u1ed7","\u1ed8":"\u1ed9","\u1eda":"\u1edb","\u1edc":"\u1edd","\u1ede":"\u1edf","\u1ee0":"\u1ee1","\u1ee2":"\u1ee3","\u1ee4":"\u1ee5","\u1ee6":"\u1ee7","\u1ee8":"\u1ee9","\u1eea":"\u1eeb","\u1eec":"\u1eed","\u1eee":"\u1eef","\u1ef0":"\u1ef1","\u1ef2":"\u1ef3","\u1ef4":"\u1ef5","\u1ef6":"\u1ef7","\u1ef8":"\u1ef9","\u1f08":"\u1f00","\u1f09":"\u1f01","\u1f0a":"\u1f02","\u1f0b":"\u1f03","\u1f0c":"\u1f04",
	"\u1f0d":"\u1f05","\u1f0e":"\u1f06","\u1f0f":"\u1f07","\u1f18":"\u1f10","\u1f19":"\u1f11","\u1f1a":"\u1f12","\u1f1b":"\u1f13","\u1f1c":"\u1f14","\u1f1d":"\u1f15","\u1f28":"\u1f20","\u1f29":"\u1f21","\u1f2a":"\u1f22","\u1f2b":"\u1f23","\u1f2c":"\u1f24","\u1f2d":"\u1f25","\u1f2e":"\u1f26","\u1f2f":"\u1f27","\u1f38":"\u1f30","\u1f39":"\u1f31","\u1f3a":"\u1f32","\u1f3b":"\u1f33","\u1f3c":"\u1f34","\u1f3d":"\u1f35","\u1f3e":"\u1f36","\u1f3f":"\u1f37","\u1f48":"\u1f40","\u1f49":"\u1f41","\u1f4a":"\u1f42","\u1f4b":"\u1f43","\u1f4c":"\u1f44","\u1f4d":"\u1f45","\u1f59":"\u1f51",
	"\u1f5b":"\u1f53","\u1f5d":"\u1f55","\u1f5f":"\u1f57","\u1f68":"\u1f60","\u1f69":"\u1f61","\u1f6a":"\u1f62","\u1f6b":"\u1f63","\u1f6c":"\u1f64","\u1f6d":"\u1f65","\u1f6e":"\u1f66","\u1f6f":"\u1f67","\u1fb8":"\u1fb0","\u1fb9":"\u1fb1","\u1fba":"\u1f70","\u1fbb":"\u1f71","\u1fc8":"\u1f72","\u1fc9":"\u1f73","\u1fca":"\u1f74","\u1fcb":"\u1f75","\u1fd8":"\u1fd0","\u1fd9":"\u1fd1","\u1fda":"\u1f76","\u1fdb":"\u1f77","\u1fe8":"\u1fe0","\u1fe9":"\u1fe1","\u1fea":"\u1f7a","\u1feb":"\u1f7b","\u1fec":"\u1fe5","\u1ff8":"\u1f78","\u1ff9":"\u1f79","\u1ffa":"\u1f7c","\u1ffb":"\u1f7d",
	"\u2160":"\u2170","\u2161":"\u2171","\u2162":"\u2172","\u2163":"\u2173","\u2164":"\u2174","\u2165":"\u2175","\u2166":"\u2176","\u2167":"\u2177","\u2168":"\u2178","\u2169":"\u2179","\u216a":"\u217a","\u216b":"\u217b","\u216c":"\u217c","\u216d":"\u217d","\u216e":"\u217e","\u216f":"\u217f","\u24b6":"\u24d0","\u24b7":"\u24d1","\u24b8":"\u24d2","\u24b9":"\u24d3","\u24ba":"\u24d4","\u24bb":"\u24d5","\u24bc":"\u24d6","\u24bd":"\u24d7","\u24be":"\u24d8","\u24bf":"\u24d9","\u24c0":"\u24da","\u24c1":"\u24db","\u24c2":"\u24dc","\u24c3":"\u24dd","\u24c4":"\u24de","\u24c5":"\u24df",
	"\u24c6":"\u24e0","\u24c7":"\u24e1","\u24c8":"\u24e2","\u24c9":"\u24e3","\u24ca":"\u24e4","\u24cb":"\u24e5","\u24cc":"\u24e6","\u24cd":"\u24e7","\u24ce":"\u24e8","\u24cf":"\u24e9","\uff21":"\uff41","\uff22":"\uff42","\uff23":"\uff43","\uff24":"\uff44","\uff25":"\uff45","\uff26":"\uff46","\uff27":"\uff47","\uff28":"\uff48","\uff29":"\uff49","\uff2a":"\uff4a","\uff2b":"\uff4b","\uff2c":"\uff4c","\uff2d":"\uff4d","\uff2e":"\uff4e","\uff2f":"\uff4f","\uff30":"\uff50","\uff31":"\uff51","\uff32":"\uff52","\uff33":"\uff53","\uff34":"\uff54","\uff35":"\uff55","\uff36":"\uff56",
	"\uff37":"\uff57","\uff38":"\uff58","\uff39":"\uff59","\uff3a":"\uff5a"
	};
	for (c in BIDIRECTIONAL) lowerToUpper[upperToLower[c] = BIDIRECTIONAL[c]] = c
	};
	function translateString(string, table) {
	var i = -1, len = string.length, s = '', t, c;
	while (++i < len) s += (t = table[c = string[i]]) ? t : c;
	return s
	}
	function toLower(o) {
	if (!lowerToUpper) createCaseTables();
	return translateString(str(o), upperToLower);
	}
	function toUpper(o) {
	if (!lowerToUpper) createCaseTables();
	return translateString(str(o), lowerToUpper);
	}
	var String = support.distinctConstructor(function String(v) {
	return (arguments.length ? str(v) : '');
	}, function String(v) {
	var s;
	return defineProperties(
	support.createWrapper("String", (s = (arguments.length ? str(v) : '')), support.prototypes.String)
	,  { readOnly: true, dontEnum: true, dontDelete: true }, { length: s.length });
	});
	defineProperties(String, { dontEnum: true, readOnly: true, dontDelete: true }, { prototype: support.prototypes.String });
	defineProperties(String, { dontEnum: true }, {
	fromCharCode: unconstructable(function fromCharCode(v) {
	var argc, argv;
	if ((argc = (argv = arguments).length) === 1) return support.fromCharCode(v & 65535);
	for (var i = 0, s = ''; i < argc; ++i) s += support.fromCharCode(argv[i] & 65535);
	return s;
	})
	});
	defineProperties(String.prototype, { dontEnum: true }, {
	constructor: String,
	charAt: unconstructable(function charAt(pos) {
	var s;
	return (((pos = int(pos)) < 0 || pos >= (s = str(this)).length) ? '' : s[pos]);
	}),
	charCodeAt: unconstructable(function charCodeAt(pos) {
	return $charCodeAt(str(this), +pos);
	}),
	concat: unconstructable(function concat(string1) {
	var args, n = (args = arguments).length, s = str(this);
	for (var i = 0; i < n; ++i) s += str(args[i]);
	return s;
	}),
	indexOf: unconstructable(function indexOf(searchString) { // .length should be 1
	var s, i, e = (s = str(this)).length - (searchString = str(searchString)).length, pos = arguments[1];
	if ((i = int(pos)) < 0) i = 0;
	for (; i <= e; ++i) if ($match(s, i, searchString)) return i;
	return -1;
	}),
	lastIndexOf: unconstructable(function lastIndexOf(searchString) { // .length should be 1
	var s, i, e = (s = str(this)).length - (searchString = str(searchString)).length, pos = arguments[1];
	if ($isNaN(pos = +pos) || (i = int(pos)) > e) i = e;
	for (; i >= 0; --i) if ($match(s, i, searchString)) return i;
	return -1;
	}),
	localeCompare: unconstructable(function localeCompare(that) {
	var me, him;
	return ((me = str(this)) === (him = str(that)) ? 0 : (me < him ? -1 : 1));
	}),
	match: unconstructable(function match(regexp) {
	if ($getInternalProperty(regexp, "class") !== "RegExp") regexp = new RegExp(regexp);
	var s = str(this);
	if (!regexp.global) return regExpExecMethod(regexp, s);
	var i = regexp.lastIndex = 0, a = [ ], r;
	do {
	if (!(r = regExpExecMethod(regexp, s))) return (i === 0 ? null : a);
	if (!(a[i++] = r[0])) ++regexp.lastIndex;
	} while (true);
	}),
	replace: unconstructable(function replace(searchValue, replaceValue) {
	var s, sLength = (s = str(this)).length, replaceFunction = replaceValue, matches, i, p, t, l, e;
	if (typeof replaceFunction !== "function") {
	var r = str(replaceValue);
	for (i = r.length; --i >= 0 && r[i] != '$';);
	replaceFunction = (i < 0 ? function() { return r; } : function(m) {
	var t = '', p, ch, ch2, c, n;
	for (p = 0; ch = r[p]; ++p) {
	if (ch !== '$') t += ch;
	else switch (ch = r[++p]) {
	case (void 0): case '$': t += '$'; break;
	case '&': t += m; break;
	case '`': t += $sub(s, 0, arguments[arguments.length - 2]); break;
	case "'": t += $sub(s, arguments[arguments.length - 2] + m.length, sLength); break;
	default: {
	if (ch >= '0' && ch <= '9') {
	if (!(ch2 = r[p + 1]) || ch2 < '0' || ch2 > '9') ch2 = '';
	if ((n = +(ch + ch2)) >= 1 && n < arguments.length - 2) {
	t += ((c = arguments[n]) === void 0 ? '' : c);
	p += ch2.length;
	break;
	}
	}
	t += '$' + ch;
	break;
	}
	}
	}
	return t;
	})
	};
	if ($getInternalProperty(searchValue, "class") === "RegExp") {
	p = 0;
	t = new StringBuilder;
	if (searchValue.global) searchValue.lastIndex = 0;
	while (matches = regExpExecMethod(searchValue, s)) {
	matches[i = matches.length] = matches.index;
	matches[i + 1] = s;
	t.append($sub(s, p, matches.index) + str($callWithArgs(replaceFunction, null, matches)));
	p = matches.index + (l = matches[0].length);
	if (!searchValue.global) break;
	if (l === 0) ++searchValue.lastIndex;
	}
	return (t.append($sub(s, p, sLength))).build();
	} else {
	e = sLength - (l = (t = str(searchValue)).length);
	for (var p = 0; !$match(s, p, t); ++p) if (p >= e) return s;
	return $sub(s, 0, p) + str($callWithArgs(replaceFunction, null, [ t, p, s ])) + $sub(s, p + l, sLength);
	}
	}),
	search: unconstructable(function search(regexp) {
	if ($getInternalProperty(regexp, "class") !== "RegExp") regexp = new RegExp(regexp);
	var s, len = (s = str(this)).length, f = $getInternalProperty(regexp, "value");
	for (var i = 0; i <= len; ++i) if (f(s, i)) return i;
	return -1;
	}),
	slice: unconstructable(function slice(start, end) {
	var s = str(this);
	if ((start = int(start)) < 0) start += s.length;
	if (end === void 0) end = $Infinity;
	else if ((end = int(end)) < 0) end += s.length;
	return $sub(s, start, end);
	}),
	split: unconstructable(function split(separator, limit) {
	var s, sLength = (s = str(this)).length, a = [ ], aLength = 0, splitMatch;
	if (!(limit = ((limit === void 0) ? 0xFFFFFFFF : uint32(limit)))) return a;
	if (separator === void 0) return [ s ];
	if ($getInternalProperty(separator, "class") !== "RegExp") {
	var separatorLength = (separator = str(separator)).length;
	splitMatch = function(p) { if ($match(s, p, separator)) return [ p, p + separatorLength ]; }
	} else {
	var re = $getInternalProperty(separator, "value");
	splitMatch = function(p) { return re(s, p); }
	}
	if (!sLength) return (splitMatch(0) ? a : [ s ]);
	var p, b = p = 0, m, e;
	while (p !== sLength) {
	if (!(m = splitMatch(p)) || (e = m[1]) === b) ++p;
	else {
	m[0] = b;
	m[1] = p;
	p = b = e;
	for (var i = 0; i < m.length; i += 2) {
	a[aLength] = (m[i] === void 0 ? void 0 : $sub(s, m[i], m[i + 1]));
	if (++aLength === limit) return a;
	}
	}
	}
	a[aLength] = $sub(s, b, sLength);
	return a;
	}),
	substr: unconstructable(function substr(start, length) {
	var s = str(this);
	if ((start = int(start)) < 0) start = s.length + start;
	return $sub(s, start, (length === void 0 ? $Infinity : start + int(length)));
	}),
	substring: unconstructable(function substring(start, end) {
	start = int(start);
	if (end === void 0) end = $Infinity;
	else if ((end = int(end)) < start) {
	var swap = start;
	start = end;
	end = swap;
	}
	return $sub(str(this), start, end);
	}),
	toUpperCase: unconstructable(function toUpperCase() { return toUpper(this) }),
	toLocaleUpperCase: unconstructable(function toLocaleUpperCase() { return toUpper(this) }),
	toLowerCase: unconstructable(function toLowerCase() { return toLower(this) }),
	toLocaleLowerCase: unconstructable(function toLocaleLowerCase() { return toLower(this) }),
	trimLeft: unconstructable(function trimLeft() {
	var s = str(this), i = 0, j = s.length, c;
	for (; i < j; ++i) {
	c = s.charCodeAt(i);
	if (c !== 0x20 && (c < 0x09 || c > 0x0D) && c !== 0xA0 && c !== 0x2028 && c !== 0x2029 && c !== 0xFEFF) break;
	}
	return $sub(s, i, j);
	}),
	trimRight: unconstructable(function trimRight() {
	var s = str(this), j = s.length, c;
	for (; j > 0; --j) {
	c = s.charCodeAt(j - 1);
	if (c !== 0x20 && (c < 0x09 || c > 0x0D) && c !== 0xA0 && c !== 0x2028 && c !== 0x2029 && c !== 0xFEFF) break;
	}
	return $sub(s, 0, j);
	}),
	trim: unconstructable(function trim() {
	var s = str(this), i = 0, j = s.length, c;
	for (; i < j; ++i) {
	c = s.charCodeAt(i);
	if (c !== 0x20 && (c < 0x09 || c > 0x0D) && c !== 0xA0 && c !== 0x2028 && c !== 0x2029 && c !== 0xFEFF) break;
	}
	for (; j > i; --j) {
	c = s.charCodeAt(j - 1);
	if (c !== 0x20 && (c < 0x09 || c > 0x0D) && c !== 0xA0 && c !== 0x2028 && c !== 0x2029 && c !== 0xFEFF) break;
	}
	return $sub(s, i, j);
	}),
	valueOf: unconstructable(function valueOf() {
	checkClass(this, "String", "valueOf");
	return $getInternalProperty(this, "value");
	}),
	toString: unconstructable(function toString() {
	checkClass(this, "String", "toString");
	return $getInternalProperty(this, "value");
	})
	});
	/* --- Array --- */
	var Array = function Array(v) {
	var a = [ ], argv, argc;
	if ((argc = (argv = arguments).length) === 1 && typeof v === "number") {
	if ((v >>> 0) !== v) throw rangeError("Invalid array length");
	a.length = v;
	} else {
	for (var i = 0; i < argc; ++i) a[i] = argv[i];
	}
	return a
	};
	defineProperties(Array, { dontEnum: true, readOnly: true, dontDelete: true }, { prototype: support.prototypes.Array });
	defineProperties(Array.prototype, { dontEnum: true }, {
	constructor: Array,
	concat: unconstructable(function concat(item1) {
	var a = [ ], argv, argc = (argv = arguments).length, n = 0, v = this;
	for (var i = -1; i < argc; v = argv[++i]) {
	if ($getInternalProperty(v, "class") !== "Array") {
	a[n++] = v;
	} else {
	for (var j = 0, e = v.length; j < e; ++j) if (j in v) a[n + j] = v[j];
	a.length = (n += j);
	}
	}
	return a;
	}),
	join: unconstructable(function join(separator) {
	var s = new StringBuilder, s2, len = uint32(this.length);
	separator = (separator === void 0 ? ',' : str(separator));
	for (var i = 0; i < len; ++i) {
	if (i > 0) s.append(separator);
	if ((s2 = this[i]) != null) s.append(str(s2));
	}
	return s.build();
	}),
	pop: unconstructable(function pop() {
	var v = void 0, len;
	if ((len = uint32(this.length)) > 0) v = this[--len];
	this.length = len;
	return v;
	}),
	push: unconstructable(function push(item) {
	var argv, offset = uint32(this.length), end = (argv = arguments).length + offset;
	for (var i = offset; i < end; ++i) this[i] = argv[i - offset];
	return (this.length = end);
	}),
	reverse: unconstructable(function reverse() {
	var len, mid = $floor((len = uint32(this.length)) / 2);
	--len;
	for (var leftIndex = 0; leftIndex < mid; ++leftIndex) {
	var rightIndex = len - leftIndex;
	var gotRight = (rightIndex in this), rightValue = this[rightIndex];
	if (leftIndex in this) this[rightIndex] = this[leftIndex]; else delete this[rightIndex];
	if (gotRight) this[leftIndex] = rightValue; else delete this[leftIndex];
	}
	return this;
	}),
	shift: unconstructable(function shift() {
	var len, elementZero;
	if (len = uint32(this.length)) {
	elementZero = this[0];
	for (var i = 1; i < len; ++i) {
	if (i in this) this[i - 1] = this[i];
	else delete this[i - 1];
	}
	--len;
	};
	this.length = len;
	return elementZero;
	}),
	slice: unconstructable(function slice(start, end) {
	var a = [ ], len = uint32(this.length);
	if ((start = int(start)) < 0) { start += len; if (start < 0) start = 0; }
	if (end === void 0 || (end = int(end)) > len) end = len;
	else if (end < 0) end += len;
	for (var i = start, j = 0; i < end; ++i, ++j) if (i in this) a[j] = this[i];
	a.length = j;
	return a;
	}),
	sort: unconstructable(function sort(comparefn) {
	var self = this;
	function swap(arr, aIndex, bIndex) {
	var gotA = (aIndex in arr), aValue = arr[aIndex];
	if (bIndex in arr) arr[aIndex] = arr[bIndex]; else delete arr[aIndex];
	if (gotA) arr[bIndex] = aValue; else delete arr[bIndex];
	};
	function compare(arr, aIndex, bIndex) {
	if (!(aIndex in arr) && !(bIndex in arr)) return 0;
	else if (!(aIndex in arr)) return 1;
	else if (!(bIndex in arr)) return -1;
	else {
	var a = arr[aIndex];
	var b = arr[bIndex];
	if (a === void 0 && b === void 0) return 0;
	else if (a === void 0) return 1;
	else if (b === void 0) return -1;
	else return comparefn(a, b);
	}
	};
	function qsort(from, to) {
	var swp = swap, cmp = compare, arr = self, mid, low;
	for (--to; from + 1 < to; from = low) {
	var high = to;
	low = from;
	mid = $floor((low + high) / 2);
	while (low < high) {
	while (low <= high && cmp(arr, low, mid) <= 0 && cmp(arr, high, mid) >= 0) {
	++low;
	--high;
	}
	while (low <= high && cmp(arr, high, mid) > 0) --high;
	while (low <= high && cmp(arr, low, mid) < 0) ++low;
	if (mid === low || mid === high) mid ^= high ^ low;
	if (low < high) swp(arr, low, high);
	}
	qsort(from, low)
	}
	if (from < to && cmp(arr, from, to) > 0) swp(arr, from, to)
	};
	if (comparefn === void 0) {
	comparefn = function(a, b) {
	return ((a = str(a)) < (b = str(b)) ? -1 : (a > b ? 1 : 0));
	}
	};
	qsort(0, this.length >>> 0);
	return this;
	}),
	splice: unconstructable(function splice(start, deleteCount) {
	var a = [ ], len = uint32(this.length), argv, argc = (argv = arguments).length, end, itemCount, move;
	if ((start = int(start)) < 0) { start += len; if (start < 0) start = 0; }
	else if (start > len) start = len;
	if (argc == 1 || (end = start + int(deleteCount)) > len) end = len;
	else if (end < start) end = start;
	for (var i = start, j = 0; i < end; ++i, ++j) if (i in this) a[j] = this[i];
	a.length = j;
	if ((itemCount = argc - 2) < 0) itemCount = 0;
	if ((move = start + itemCount - end) !== 0) {
	var step = 1, j = end;
	if (move > 0) { step = -1; j = len - 1; }
	for (i = len - end; --i >= 0; j += step) {
	if (j in this) this[j + move] = this[j];
	else delete this[j + move];
	}
	for (i = len; --i >= len + move; ) delete this[i];
	}
	for (i = 2, j = start; i < argc; ++i, ++j) this[j] = argv[i];
	this.length = len + move;
	return a;
	}),
	toLocaleString: Object.prototype.toLocaleString,
	toString: unconstructable(function toString() {
	checkClass(this, "Array", "toString");
	return this.join();
	}),
	unshift: unconstructable(function unshift(item1) {
	var len, argv, n = (argv = arguments).length;
	if (len = uint32(this.length)) {
	for (var i = len; --i >= 0; ) {
	if (i in this) this[i + n] = this[i];
	else delete this[i + n];
	}
	}
	for (var i = 0; i < n; ++i) this[i] = argv[i];
	return (this.length = len + n);
	})
	});
	/* --- Date --- */
	function localMaxDiff() { // local max is during DST
	var startOfYearDiff = support.localTimeDifference(14516064e5); // 2016-01-01T00:00:00.000Z
	var midOfYearDiff = support.localTimeDifference(14673312e5); // 2016-07-01T00:00:00.000Z
	return (startOfYearDiff > midOfYearDiff ? startOfYearDiff : midOfYearDiff)
	}
	function localMinDiff() { // local min is timezone (non DST)
	var startOfYearDiff = support.localTimeDifference(14516064e5); // 2016-01-01T00:00:00.000Z
	var midOfYearDiff = support.localTimeDifference(14673312e5); // 2016-07-01T00:00:00.000Z
	return (startOfYearDiff < midOfYearDiff ? startOfYearDiff : midOfYearDiff)
	}
	function localTimeDiff(z) { var l = support.localTimeDifference(z); return ($isNaN(l) ? localMinDiff() : l) }
	function toLocalTime(z) { return $isNaN(z) ? z : z + localTimeDiff(z) }
	function checkDateClass(object) {
	if ($getInternalProperty(object, "class") !== "Date") throw typeError("this is not a Date object");
	}
	function getDateValue(object) { checkDateClass(object); return $getInternalProperty(object, "value"); }
	function getLocalDateValue(object) { return toLocalTime(getDateValue(object)); }
	function setDateValue(object, v) { checkDateClass(object); support.updateDateValue(object, v); return v; }
	function localDateTimeToString(v) {
	return $isNaN(v = toLocalTime(v)) ? "Invalid Date" : (epochToDateString(v) + ' ' + epochToTimeString(v));
	}
	function floorMod(x, n) { return (x % n + n) % n }
	function epochFromTime(hour, minute, second, ms) { return hour * 36e5 + minute * 6e4 + second * 1e3 + ms }
	function timeFromEpoch(z) { return [ floorMod($floor(z / 36e5), 24), floorMod($floor(z / 6e4), 60), floorMod($floor(z / 1e3), 60), floorMod(z, 1e3) ] }
	function fromLocalTime(z) { return $isNaN(z) ? z : (z - localTimeDiff(z - localMaxDiff())) }
	function weekdayFromTime(z) { return floorMod($floor(z / 864e5) + 4, 7) }
	function hourFromTime(z) { return floorMod($floor(z / 36e5), 24) }
	function minFromTime(z) { return floorMod($floor(z / 6e4), 60) }
	function secFromTime(z) { return floorMod($floor(z / 1e3), 60) }
	function msFromTime(z) { return floorMod(z, 1e3) }
	function timeClip(z) { return (!$isFinite(z) || abs(z) > 8.64e15 ? $NaN : int(z)) }
	function timeClipLocal(z) { return fromLocalTime(timeClip(z)); }
	function dateFromEpoch(z) {
	z = $floor(z / 864e5) + 719468;
	var era = int( (z >= 0 ? z : z - 146096) / 146097 );
	var doe = z - era * 146097;
	var yoe = int( (doe - int(doe / 1460) + int(doe / 36524) - int(doe / 146096)) / 365 );
	var y = yoe + era * 400;
	var doy = doe - (365 * yoe + int(yoe / 4) - int(yoe/100) );
	var mp = int( (5 * doy + 2) / 153);
	var m = mp + (mp < 10 ? 2 : -10);
	var d = doy - int( (153 * mp + 2) / 5 ) + 1;
	return [ (y + (m <= 1)), m, d ];
	}
	function epochToDateString(z) {
	var y, dt = dateFromEpoch(z);
	return (0 <= (y = dt[0]) && y <= 9999 ? leftPad(y, 4) : (y < 0 ? "-" : "+") + leftPad(abs(y), 6))
	+ "-" + leftPad(dt[1] + 1, 2) + "-" + leftPad(dt[2], 2);
	}
	function epochToTimeString(z, ms) {
	var tm = timeFromEpoch(z);
	return leftPad(tm[0], 2) + ":" + leftPad(tm[1], 2) + ":" + leftPad(tm[2], 2)
	+ (ms ? "." + leftPad($sub(tm[3], 0, 3), 3) : "")
	}
	function epochFromDate(year, month, day) {
	year += $floor(month / 12) - (floorMod(month, 12) <= 1);
	var era = int( (year >= 0 ? year : year - 399) / 400 );
	var yoe = year - era * 400;
	var doy = int( (153 * (month + (month > 1 ? -2 : 10)) + 2) / 5 ) + day - 1;
	var doe = yoe * 365 + int(yoe / 4) - int(yoe / 100) + doy;
	return (era * 146097 + doe - 719468) * 864e5;
	}
	function setDateParts(z, n, a) {
	var i, d = dateFromEpoch(z), r = floorMod(z, 864e5);
	for (i = 0; i < a.length; ++i, ++n) d[n] = int(a[i]);
	return $callWithArgs(epochFromDate, null, d) + r;
	}
	function setTimeParts(z, n, a) {
	var i, t = timeFromEpoch(z), r = $floor(z / 864e5) * 864e5;
	for (i = 0; i < a.length; ++i, ++n) t[n] = int(a[i]);
	return $callWithArgs(epochFromTime, null, t) + r;
	}
	function makeDateTime(year, month, date, hours, minutes, seconds, ms) {
	var argc = arguments.length;
	return epochFromDate( (year = int(year)) + (0 <= year && year <= 99 ? 1900 : 0),
	int(month), (argc > 2 ? int(date) : 1)) + epochFromTime( argc > 3 ? int(hours) : 0,
	argc > 4 ? int(minutes) : 0, argc > 5 ? int(seconds) : 0, argc > 6 ? int(ms) : 0);
	}
	function isoDate(d) {
	var z;
	return $isNaN(z = getDateValue(d)) ? null : epochToDateString(z) + "T" + epochToTimeString(z, true) + "Z";
	}
	var parseDate, Date = support.distinctConstructor(function Date() {
	return localDateTimeToString(support.getCurrentTime());
	}, function Date(year, month, date, hours, minutes, seconds, ms) {
	var v, argc;
	if ((argc = arguments.length) >= 2 && argc <= 7) v = timeClipLocal($callWithArgs(makeDateTime, null, arguments));
	else if (argc === 1) v = timeClip(typeof (v = support.toPrimitive(year)) === "string" ? parseDate(v) : +v);
	else v = support.getCurrentTime();
	return support.createWrapper("Date", v, support.prototypes.Date);
	});
	defineProperties(Date, { dontEnum: true, readOnly: true, dontDelete: true }, { prototype: support.prototypes.Date });
	defineProperties(Date, { dontEnum: true }, {
	parse: unconstructable(parseDate = function parse(s) {
	var z, y, i, ch, tz, tzh, tzm, i = 0;
	function readPart(len) {
	var v;
	for (v = 0; --len >= 0;) if ("0" <= s[i] && s[i] <= "9") v = v * 10 + (+s[i++]); else return $NaN;
	return v;
	}
	z = epochFromDate(
	((ch = s[i]) === "+" || ch === "-") && (++i, y = readPart(6), ch === "-" ? -y : y) || readPart(4),
	s[i] === "-" && (++i, readPart(2) - 1) || 0,
	s[i] === "-" && (++i, readPart(2)) || 1);
	z += epochFromTime(
	((ch = s[i]) === "T" || ch === "t" || ch === ' ') && (++i, readPart(2)) || 0,
	s[i] === ":" && (++i, readPart(2)) || 0,
	s[i] === ":" && (++i, readPart(2)) || 0,
	s[i] === "." && (++i, readPart(3)) || 0);
	while ((ch = s[i]) !== void 0 && ch !== "Z" && ch !== "z" && ch !== "+" && ch !== "-") ++i;
	if (ch === "Z" || ch === "z") tz = 0;
	else if (ch === "+" || ch === "-") {
	++i, tzh = readPart(2) * 36e5,
	s[i] === ":" && ++i, tzh += $isNaN(tzm = readPart(2)) ? 0 : tzm * 6e4,
	$isNaN(tzh) || (tz = ch === "-" ? -tzh : tzh);
	}
	return (tz === void 0 ? fromLocalTime(z) : z - tz)
	}),
	UTC: unconstructable(function UTC(year, month, date, hours, minutes, seconds, ms) {
		return timeClip(makeDateTime(year, month, date, hours, minutes, seconds, ms))
	}),
	now: unconstructable(function now() {
		return support.getCurrentTime();
	})
	});
	defineProperties(Date.prototype, { dontEnum: true }, {
	constructor: Date,
	toISOString: unconstructable(function toISOString() {
	var s;
	if ((s = isoDate(this)) === null) throw rangeError("Invalid time value");	// Dont ask my why, but this is how V8 does it
	return s;
	}),
	toUTCString: unconstructable(function toUTCString() {
	var z;
	if ($isNaN(z = getDateValue(this))) return "Invalid Date";
	return (epochToDateString(z) + ' ' + epochToTimeString(z))
	}),
	toString: unconstructable(function toString() { return localDateTimeToString(getDateValue(this)); }),
	toDateString: unconstructable(function toDateString() {
	var l;
	if ($isNaN(l = getLocalDateValue(this))) return "Invalid Date";
	return epochToDateString(l)
	}),
	toTimeString: unconstructable(function toTimeString() {
	var l;
	if ($isNaN(l = getLocalDateValue(this))) return "Invalid Date";
	return epochToTimeString(l)
	}),
	toLocaleString: Object.prototype.toLocaleString,
	toLocaleDateString: unconstructable(function toLocaleDateString() { return this.toDateString() }),
	toLocaleTimeString: unconstructable(function toLocaleTimeString() { return this.toTimeString() }),
	valueOf: unconstructable(function valueOf() { return getDateValue(this) }),
	getTime: unconstructable(function getTime() { return getDateValue(this) }),
	getFullYear: unconstructable(function getFullYear() { return dateFromEpoch(getLocalDateValue(this))[0] }),
	getUTCFullYear: unconstructable(function getUTCFullYear() { return dateFromEpoch(getDateValue(this))[0] }),
	getMonth: unconstructable(function getMonth() { return dateFromEpoch(getLocalDateValue(this))[1] }),
	getUTCMonth: unconstructable(function getUTCMonth() { return dateFromEpoch(getDateValue(this))[1] }),
	getDate: unconstructable(function getDate() { return dateFromEpoch(getLocalDateValue(this))[2] }),
	getUTCDate: unconstructable(function getUTCDate() { return dateFromEpoch(getDateValue(this))[2] }),
	getDay: unconstructable(function getDay() { return weekdayFromTime(getLocalDateValue(this)) }),
	getUTCDay: unconstructable(function getUTCDay() { return weekdayFromTime(getDateValue(this)) }),
	getHours: unconstructable(function getHours() { return hourFromTime(getLocalDateValue(this)) }),
	getUTCHours: unconstructable(function getUTCHours() { return hourFromTime(getDateValue(this)) }),
	getMinutes: unconstructable(function getMinutes() { return minFromTime(getLocalDateValue(this)) }),
	getUTCMinutes: unconstructable(function getUTCMinutes() { return minFromTime(getDateValue(this)) }),
	getSeconds: unconstructable(function getSeconds() { return secFromTime(getLocalDateValue(this)) }),
	getUTCSeconds: unconstructable(function getUTCSeconds() { return secFromTime(getDateValue(this)) }),
	getMilliseconds: unconstructable(function getMilliseconds() { return msFromTime(getLocalDateValue(this)) }),
	getUTCMilliseconds: unconstructable(function getUTCMilliseconds() { return msFromTime(getDateValue(this)) }),
	getTimezoneOffset: unconstructable(function getTimezoneOffset() { var v = getDateValue(this); return (v - toLocalTime(v)) / 6e4 }),
	setTime: unconstructable(function setTime(time) { return setDateValue(timeClip(+time)) }),
	setMilliseconds: unconstructable(function setMilliseconds(ms) { return setDateValue(this, timeClipLocal(setTimeParts(getLocalDateValue(this), 3, arguments))) }),
	setUTCMilliseconds: unconstructable(function setUTCMilliseconds(ms) { return setDateValue(this, timeClip(setTimeParts(getDateValue(this), 3, arguments))) }),
	setSeconds: unconstructable(function setSeconds(s, ms) { return setDateValue(this, timeClipLocal(setTimeParts(getLocalDateValue(this), 2, arguments))) }),
	setUTCSeconds: unconstructable(function setUTCSeconds(s, ms) { return setDateValue(this, timeClip(setTimeParts(getDateValue(this), 2, arguments))) }),
	setMinutes: unconstructable(function setMinutes(m, s, ms) { return setDateValue(this, timeClipLocal(setTimeParts(getLocalDateValue(this), 1, arguments))) }),
	setUTCMinutes: unconstructable(function setUTCMinutes(m, s, ms) { return setDateValue(this, timeClip(setTimeParts(getDateValue(this), 1, arguments))) }),
	setHours: unconstructable(function setHours(h, m, s, ms) { return setDateValue(this, timeClipLocal(setTimeParts(getLocalDateValue(this), 0, arguments))) }),
	setUTCHours: unconstructable(function setUTCHours(h, m, s, ms) { return setDateValue(this, timeClip(setTimeParts(getDateValue(this), 0, arguments))) }),
	setDate: unconstructable(function setDate(date) { return setDateValue(this, timeClipLocal(setDateParts(getLocalDateValue(this), 2, arguments))) }),
	setUTCDate: unconstructable(function setUTCDate(date) { return setDateValue(this, timeClip(setDateParts(getDateValue(this), 2, arguments))) }),
	setMonth: unconstructable(function setMonth(month, date) { return setDateValue(this, timeClipLocal(setDateParts(getLocalDateValue(this), 1, arguments))) }),
	setUTCMonth: unconstructable(function setUTCMonth(month, date) { return setDateValue(this, timeClip(setDateParts(getDateValue(this), 1, arguments))) }),
	setFullYear: unconstructable(function setFullYear(year, month, date) { var v; return setDateValue(this, timeClipLocal(setDateParts($isNaN(v = getDateValue(this)) ? 0 : toLocalTime(v), 0, arguments))) }),
	setUTCFullYear: unconstructable(function setUTCFullYear(year, month, date) { var v; return setDateValue(this, timeClip(setDateParts($isNaN(v = getDateValue(this)) ? 0 : v, 0, arguments))) }),
	// TODO: this isn't as generic as in the ES5 spec, e.g. not converting this to object, not going via the objects reassignable `toISOString`.
	toJSON: unconstructable(function toJSON() { return isoDate(this); })
	});
	/* --- RegExp --- */
	var v = 1;
	var EMPTY_CHAR = v, NEWLINE_CHAR = (v <<= 1), SPACE_CHAR = (v <<= 1), WORD_CHAR = (v <<= 1), DECIMAL_CHAR = (v <<= 1)
	, LETTER_CHAR = (v <<= 1), HEX_CHAR = (v <<= 1), ESCAPE_CHAR = (v <<= 1), SPECIAL_CHAR = (v <<= 1)
	, OK_IN_STRING_LITERAL = (v <<= 1), IDENTITY_ESCAPE_CHAR = (v <<= 1);
	var CC = { }; // "CC" is used from within regexps, so the name has to be preserved
	(function() {
	function setupCharClass(mask, chars) { for (var i in chars) CC[chars[i]] |= mask }
	setupCharClass(SPECIAL_CHAR, "^$.*+?()[]{}|");
	setupCharClass(DECIMAL_CHAR | HEX_CHAR | WORD_CHAR, "0123456789");
	setupCharClass(HEX_CHAR | LETTER_CHAR | WORD_CHAR, "abcdefABCDEF");
	setupCharClass(LETTER_CHAR | WORD_CHAR, "ghijklmnopqrstuvwxyzGHIJKLMNOPQRSTUVWXYZ");
	setupCharClass(NEWLINE_CHAR | SPACE_CHAR, "\n\r\u2028\u2029");
	setupCharClass(SPACE_CHAR, " \t\v\f\xA0");
	CC['_'] |= WORD_CHAR;
	CC["undefined"] |= EMPTY_CHAR;
	CC[''] |= EMPTY_CHAR;
	setupCharClass(ESCAPE_CHAR, "fnrtv");
	for (var i = 32; i <= 126; ++i) {
	var c = support.fromCharCode(i);
	if (c !== '"' && c !== '\\') CC[support.fromCharCode(i)] |= OK_IN_STRING_LITERAL;
	}
	var IDENTITY_ESCAPE_RANGES = [ 0, 48, 58, 65, 91, 95, 96, 97, 123, 128 ];
	for (var i = IDENTITY_ESCAPE_RANGES.length - 2; i >= 0; i -= 2)
	for (var j = IDENTITY_ESCAPE_RANGES[i], k = IDENTITY_ESCAPE_RANGES[i + 1]; j < k; ++j)
	CC[support.fromCharCode(j)] |= IDENTITY_ESCAPE_CHAR;
	})();
	// "regExpCanonicalize" is used from within regexps, so the name has to be preserved
	function regExpCanonicalize(s) {
	var t = '', c, d;
	if (!lowerToUpper) createCaseTables();
	for (var i = 0, len = s.length; i < len; ++i)
	t += ((d = lowerToUpper[c = s[i]]) && d.length === 1 && (c < '\x80' || d >= '\x80') ? d : c);
	return t
	}
	// FIX : all charCodeAt etc need to be stowed away so that we won't destroy regexp if changing global objects. This is true for all the code in here actually.
	function compileRegExp(s, caseInsensitive, multiLine) {
	var p = 0, functions = '', functionCounter = 0, captureCounter = 0, closureVars = '', maxBackReference = 0;
	function isClass(char, mask) { return ((CC[char] & mask) !== 0); }
	function areClass(s, mask) { // FIX : only used once
	for (var i = s.length - 1; i >= 0; --i) if ((CC[s[i]] & mask) === 0) return false;
	return true;
	}
	var CHAR_CLASS_RULES = {
	'D': [ DECIMAL_CHAR, true ], 'd': [ DECIMAL_CHAR, false ],
	'S': [ SPACE_CHAR, true ], 's': [ SPACE_CHAR, false ],
	'W': [ WORD_CHAR, true ], 'w': [ WORD_CHAR, false ],
	'.': [ NEWLINE_CHAR, true ]
	};
	function parseNumber(defaultValue) {
	var n = defaultValue;
	if (isClass(s[p], DECIMAL_CHAR)) {
	n = 0;
	do {
	n = n * 10 + ($charCodeAt(s, p) - 48); // FIX : +s[p] faster?
	++p;
	} while (isClass(s[p], DECIMAL_CHAR))
	}
	return n;
	}
	function parseQuantifier() {
	var mini = 0, maxi = $Infinity, greedy = true;
	switch (s[p]) {
	case '*': ++p; break;
	case '+': ++p; mini = 1; break;
	case '?': ++p; maxi = 1; break;
	case '{': {
	var b = p;
	++p;
	if ((mini = maxi = parseNumber(-1)) < 0) {
	p = b;
	return null;
	}
	if (s[p] === ',') {
	++p;
	maxi = parseNumber($Infinity);
	}
	if (s[p] !== '}') {
	p = b;
	return null;
	}
	if (mini > maxi) {
	throw syntaxError("Min greater than max in regular expression quantifier"); // FIX
	}
	++p;
	break;
	}
	default: return null;
	}
	if (s[p] === '?') {
	++p;
	greedy = false;
	}
	return { mini: mini, maxi: maxi, greedy: greedy };
	}
	function escapeCharacter(c) {
	if (isClass(c, OK_IN_STRING_LITERAL)) return c;
	// TODO : shorter escapes for \n etc
	return (c <= '~' ? "\\x" : "\\u") + leftPad(numberToRadix($charCodeAt(c, 0), 16), (c <= '~' ? 2 : 4));
	}
	function canonicalizeAndEscape(c) {
	return escapeCharacter(caseInsensitive ? regExpCanonicalize(c) : c);
	}
	function parseLiteralCharacter() {
	var c0, c1, sub;
	if ((c0 = s[p]) === '\\') {
	switch (c1 = s[p + 1]) {
	case '0': {
	if (!isClass(s[p + 2], DECIMAL_CHAR)) {
	p += 2;
	return '\0';
	}
	break;
	}
	case 'c': {
	if (isClass(s[p + 2], LETTER_CHAR)) {
	p += 3;
	return support.fromCharCode($charCodeAt(s, p - 1) & 31);
	}
	break;
	}
	case 'x':
	case 'u': {
	var n = (c1 === 'x' ? 2 : 4);
	if (areClass(sub = $sub(s, p + 2, p + 2 + n), HEX_CHAR)) {
	p += 2 + n;
	return support.fromCharCode(parseInt(sub, 16));
	}
	break;
	}
	default: {
	if (isClass(c1, ESCAPE_CHAR)) {
	p += 2;
	return eval('"\\' + c1 + '"');
	} else if (isClass(c1, IDENTITY_ESCAPE_CHAR)) {
	p += 2;
	return c1;
	}
	break;
	}
	}
	} else if (c0) {
	++p;
	return c0;
	}
	}
	function parseLiteralSequence() {
	var literalSequence = [ ], v, n = 0;
	while (!isClass(s[p], SPECIAL_CHAR) && (v = parseLiteralCharacter()))
	literalSequence[n++] = canonicalizeAndEscape(v);
	return (literalSequence.length ? literalSequence : null);
	}
	function parseClassAtom() {
	var v, rule, c;
	if ((c = s[p]) !== ']' && (v = parseLiteralCharacter())) return v;
	if (c === '\\') {
	if ((c = s[p + 1]) === 'b') {
	p += 2;
	return '\b';
	}
	if (rule = CHAR_CLASS_RULES[c]) {
	p += 2;
	return rule;
	}
	}
	}
	function positionToCode(offset) { return (offset === 0 ? 'p' : ((offset < 0 ? 'p' : 'p+') + offset)); }
	function literalSequenceToCode(literalSequence, offset) {
	if (literalSequence.length === 0) return "true";
	else if (literalSequence.length === 1)
	return "s[" + positionToCode(offset) + ']==="' + literalSequence[0] + '"';
	else if (literalSequence.length === 2)
	return "s[" + positionToCode(offset) + ']==="' + literalSequence[0] + '" && s[' + positionToCode(offset + 1)
	+ ']==="' + literalSequence[1] + '"';
	else {
	for (var i = 0, s = '', l = literalSequence.length; i < l; ++i) s += literalSequence[i];
	return "$match(s," + positionToCode(offset) + ',"' + s + '")';
	}
	}
	function and(a, b) {
	switch (a) {
	case "false": return "false";
	case "true": return b;
	default: return (b === "true" ? a : a + " && " + b);
	}
	}
	function or(a, b) {
	switch (a) {
	case "false": return b;
	case "true": return "true";
	default: return (b === "false" ? a : a + " || " + b);
	}
	}
	function addFunction(name, definition) {
	// TODO : sometimes functions are identical (e.g. class-tests), reuse here or in '[' parsing directly?
	functions += "\tfunction " + name + "(p) { " + definition + " }\n";
	}
	function quantify(code, offset, repeatCode, tail, quantity, stepSize) {
	// TODO : eliminate unnecessary b=p+0,e=p+Infinity and stuff
	var functionName = 'q' + (++functionCounter)
	, head = (stepSize ? "var h=" + stepSize + "," : "var ")
	+ (quantity.mini ? "b=p+" + quantity.mini + (stepSize ? "*h" : "") : "b=p")
	+ (quantity.maxi < $Infinity ? ",e=p+" + quantity.maxi + (stepSize ? "*h" : "") : "") + "; ";
	if (stepSize) head += "if (h<=0 || h!==h) return " + tail + "; ";
	if (quantity.greedy) {
	addFunction(functionName, head + "while (" + and((quantity.maxi < $Infinity ? "p<e" : "true"), repeatCode) + ") "
	+ (stepSize ? "p+=h" : "++p") + "; while (" + and("p>=b", "!(" + tail + ")") + ") " + (stepSize ? "p-=h" : "--p")
	+ "; return p>=b");
	} else {
	addFunction(functionName, head + "while (" + or((quantity.mini ? "p<b" : "false"), "!(" + tail + ")")
	+ ") { if (" + or((quantity.maxi < $Infinity ? "p>=e" : "false"), "!(" + repeatCode + ")") + ") return false; " + (stepSize ? "p+=h" : "++p")
	+ " }; return true");
	}
	return and(code, functionName + "(" + positionToCode(offset) + ")");
	}
	function captureWrap(code, capture, resetCaptureFrom, resetCaptureTo) {
	if (capture === null && resetCaptureFrom === resetCaptureTo) {
	return "return " + code;
	} else {
	var declares = '', captures = '', rollbacks = '';
	if (capture !== null) {
	declares += 'r' + capture + "=c" + capture;
	captures = 'c' + capture + "=p";
	rollbacks = 'c' + capture + "=r" + capture;
	}
	if (resetCaptureTo !== void 0) {
	for (var i = resetCaptureFrom; i < resetCaptureTo; ++i) {
	var j = i * 2;
	if (capture !== null || i > resetCaptureFrom) {
	declares += ',';
	rollbacks += ',';
	if (i === resetCaptureFrom) {
	captures += ',';
	}
	}
	declares += 'r' + j + "=c" + j;
	captures += 'c' + j + '=';
	rollbacks += 'c' + j + "=r" + j;
	if (i === resetCaptureTo - 1) {
	captures += "void 0";
	}
	}
	}
	code = captures + ", " + or(code, '(' + rollbacks + ",false)");
	return "var " + declares + "; return " + code;
	}
	}
	function charClassToCode(ch, rule) {
	return (rule[1] ? '!' : "!!") + "(CC[" + ch + "]&" + (rule[0] | (rule[1] ? EMPTY_CHAR : 0)) + ')';
	}
	function compileTerms(offset, junction) {
	var literalSequence, quantity, code = "true";
	termLoop: for (;;) {
	if (literalSequence = parseLiteralSequence()) {
	if (quantity = parseQuantifier()) {
	var repeatLiteral = literalSequence[literalSequence.length - 1];
	--literalSequence.length;
	return quantify(and(code, literalSequenceToCode(literalSequence, offset))
	, offset + literalSequence.length, literalSequenceToCode(repeatLiteral, 0)
	, compileTerms(0, junction)
	, quantity);
	}
	code = and(code, literalSequenceToCode(literalSequence, offset));
	offset += literalSequence.length;
	} else { // TODO: make subs of these
	var c, condition, tail, useCall, inner;
	switch (c = s[p]) {
	case '^': {
	++p;
	condition = positionToCode(offset) + "===0";
	if (multiLine) condition = '(' + or(condition, "!!(CC[s[" + positionToCode(offset - 1) + "]]&" + NEWLINE_CHAR + ')') + ')';
	code = and(code, condition);
	break;
	}
	case '$': {
	++p;
	condition = positionToCode(offset) + "===l";
	if (multiLine) condition = '(' + or(condition, "!!(CC[s[" + positionToCode(offset) + "]]&" + NEWLINE_CHAR + ')') + ')';
	code = and(code, condition);
	break;
	}
	case '[': {
	var negative = false, v0, v1, classCode = "false";
	if (s[++p] === '^') {
	negative = true;
	++p;
	}
	while (v0 = parseClassAtom()) {
	var b = p;
	if (s[p] === '-' && (++p, v1 = parseClassAtom())) {
	if (typeof v0 === "string" && typeof v1 === "string" && v0 <= v1) {
	if (caseInsensitive && (v0 > '~' || v1 > '~' || (regExpCanonicalize(v0) !== v0) !== (regExpCanonicalize(v1) !== v1))) {
	v0 = escapeCharacter(v0);
	v1 = escapeCharacter(v1);
	classCode = or(classCode, and('upperToLower[c]>="' + v0 + '"', 'upperToLower[c]<="' + v1 + '"'));
	} else {
	v0 = canonicalizeAndEscape(v0);
	v1 = canonicalizeAndEscape(v1);
	}
	classCode = or(classCode, and('c>="' + v0 + '"', 'c<="' + v1 + '"'));
	} else {
	throw syntaxError("Invalid character class syntax in regular expression");
	}
	} else if (typeof v0 === "string") {
	p = b;
	classCode = or(classCode, 'c==="' + canonicalizeAndEscape(v0) + '"');
	} else {
	classCode = or(classCode, charClassToCode('c', v0));
	}
	}
	if (s[p] !== ']') {
	throw syntaxError("Invalid character class syntax in regular expression");
	}
	++p;
	var functionName = 'k' + (++functionCounter);
	addFunction(functionName, "var c=s[p]; return " + (negative ? "p!==l && !(" + classCode + ')' : classCode));
	if (quantity = parseQuantifier()) {
	return quantify(code, offset, functionName + '(' + positionToCode(0) + ')', compileTerms(0, junction), quantity);
	}
	code = and(code, functionName + '(' + positionToCode(offset) + ')');
	++offset;
	break;
	}
	case '\\': {
	var n;
	++p;
	if ((n = parseNumber(-1)) >= 0) {
	if (n > maxBackReference) maxBackReference = n;
	n = (n - 1) * 2;
	// TODO: $match should take two additional optional params: start, end in match-string, thus eliminating need for substring here
	quantity = parseQuantifier();
	var stepSize = 'c' + (n + 1) + "-c" + n
	, backMatchCode = "$match(s,"
	+ positionToCode(offset) + ",$sub(s, c" + n + ",c" + (n + 1) + "))";
	tail = compileTerms(0, junction);
	var tailName = 't' + (++functionCounter);
	addFunction(tailName, "return " + tail);
	return quantity ? quantify(code, offset, backMatchCode, tailName + '(' + positionToCode(0) + ')', quantity, stepSize)
	: and(code, '(c' + n + "<c" + (n + 1) + " ? " + and(backMatchCode, tailName + '(' + positionToCode(offset) + '+' + stepSize + ')') + " : " + tailName + '(' + positionToCode(offset) + "))");
	} else if ((c = s[p]) === 'b' || c === 'B') {
	++p;
	code = and(code, (c === 'b' ? "!!((CC[s[" : "!((CC[s[") + positionToCode(offset - 1) + "]]^CC[s[" + positionToCode(offset) + "]])&" + WORD_CHAR + ')');
	break;
	}
	// fall-through
	}
	case '.': {
	var rule;
	if (!(rule = CHAR_CLASS_RULES[c])) throw syntaxError("Invalid escape in regular expression");
	++p;
	if (quantity = parseQuantifier()) {
	return quantify(code, offset, charClassToCode("s[" + positionToCode(0) + ']', rule), compileTerms(0, junction), quantity);
	}
	code = and(code, charClassToCode("s[" + positionToCode(offset) + ']', rule));
	++offset;
	break;
	}
	case '(': {
	var functionNumber = ++functionCounter
	, groupName = 'g' + functionNumber
	, groupCall = groupName + '(' + positionToCode(offset) + ')'
	, junctionName = 'j' + functionNumber
	, junctionCall = junctionName + '(' + positionToCode(offset) + ')'
	, doCapture = true, lookAhead = false, negativeLookAhead = false;
	++p;
	if (s[p] === '?') {
	switch (s[p + 1]) {
	case '!': negativeLookAhead = true;
	case '=': lookAhead = true;
	case ':': doCapture = false; p += 2;
	}
	}
	var openCapture = null, closeCapture = null;
	if (doCapture) {
	(closeCapture = (openCapture = (captureCounter++) * 2) + 1);
	closureVars += ",c" + openCapture + ",c" + closeCapture;
	}
	var innerCapturesStart = captureCounter // FIX : these two are only used for negative lookAhead, use for open/close captures too?
	, disjunction = compileDisjunction(0, (lookAhead ? void 0 : junctionName))
	, innerCapturesEnd = captureCounter;
	if ((c = s[p]) !== ')') {
	throw syntaxError(c ? "Unterminated group in regular expression" : "Invalid regular expression");
	}
	++p;
	quantity = (lookAhead ? null : parseQuantifier());
	tail = compileTerms(0, junction);
	inner = disjunction;
	var extraEndlessCheck = '', looping = (quantity && quantity.maxi > 1);
	if (looping && (quantity.maxi < $Infinity || quantity.mini > 1)) {
	closureVars += ",n" + functionNumber + "=0";
	inner = ((quantity.maxi < $Infinity)
	? and("++n" + functionNumber + "<=" + quantity.maxi, inner)
	: "++n" + functionNumber + ", " + inner);
	if (quantity.mini > 1) {
	inner = and(inner, 'n' + functionNumber + ">=" + quantity.mini);
	extraEndlessCheck = 'n' + functionNumber + '<' + quantity.mini;
	}
	inner = or(inner, "(--n" + functionNumber + ",false)");
	}
	if (lookAhead) {
	useCall = junctionName + '(' + positionToCode(0) + ')';
	if (negativeLookAhead) {
	inner = "!(" + inner + ')';
	if (innerCapturesStart < innerCapturesEnd) {
	var captureResets = '';
	for (var i = innerCapturesStart; i < innerCapturesEnd; ++i)
	captureResets += 'c' + i * 2 + '=';
	useCall = '(' + captureResets + "void 0, " + useCall + ')';
	}
	}
	inner = and(inner, useCall);
	}
	if (looping) {
	closureVars += ",p" + functionNumber;
	var endlessCheck = 'p' + functionNumber + "!=p";
	inner = and(extraEndlessCheck ? '(' + or(endlessCheck, extraEndlessCheck) + ')' : endlessCheck, "(p" + functionNumber + "=p, " + inner + ')');
	}
	addFunction(groupName, captureWrap(inner, openCapture, innerCapturesStart, innerCapturesEnd));
	if (looping) {
	var recursionCall = groupName + '(' + positionToCode(0) + ')';
	inner = (quantity.greedy ? or(recursionCall, tail) : or(tail, recursionCall));
	addFunction(junctionName, captureWrap(inner, closeCapture));
	useCall = (quantity.mini === 0 ? junctionCall : groupCall);
	code = and(code, '(p' + functionNumber + "=void 0," + useCall + ')');
	} else {
	addFunction(junctionName, captureWrap(tail, closeCapture));
	code = ((quantity && quantity.mini === 0)
	? and(code, (quantity.maxi === 0 ? junctionCall : '(' + (quantity.greedy ? or(groupCall, junctionCall) : or(junctionCall, groupCall)) + ')'))
	: and(code, groupCall));
	}
	return code;
	}
	default: break termLoop;
	}
	}
	}
	switch (junction) {
	case void 0: return code;
	case '': return and(code, "(q=" + positionToCode(offset) + ",true)");
	default: return and(code, junction + '(' + positionToCode(offset) + ')');
	}
	}
	function compileDisjunction(offset, junction) { // junction = function name, undefined (for none for lookahead) or '' (for end of pattern)
	var code = compileTerms(offset, junction);
	if (s[p] === '|') {
	do {
	++p;
	code = or(code, compileTerms(offset, junction));
	} while (s[p] === '|');
	code = '(' + code + ')';
	}
	return code;
	}
	var disjunction = compileDisjunction(0, ''); 
	if (p < s.length) throw syntaxError("Invalid regular expression");
	if (maxBackReference > captureCounter) throw syntaxError("Invalid back reference in regular expression");
	var code = "(function(s, p) {\n";
	if (caseInsensitive) code += "\ts=regExpCanonicalize(s)\n";
	code += "\tvar l=s.length,q";
	code += closureVars + ";\n" + functions + "\tif (" + disjunction + ") return [p,q";
	for (var i = 0; i < captureCounter * 2; ++i) code += ",c" + i;
	code += "];\n})";
	return code
	}
	var REG_EXP_FLAG_TO_PROPERTY = { 'g': "global", 'i': "ignoreCase", 'm': "multiline" }, regExpCache = { }, regExpPrototype;
	function execRegExp(re, string) {
	string = str(string);
	var i;
	if ((i = (re.global ? int(re.lastIndex) : 0)) >= 0) {
	var f = $getInternalProperty(re, "value"), len = string.length, m;
	for (; i <= len; ++i)
	if (m = f(string, i)) {
	if (re.global) re.lastIndex = m[1];
	return m;
	}
	}
	re.lastIndex = 0
	}
	function regExpExecMethod(re, string) {
	var m, a = null;
	if (m = execRegExp(re, string)) {
	(a = [ ]).input = string;
	a.index = m[0];
	for (var j = 0; j < m.length; j += 2)
	a[a.length] = ((m[j] === void 0) ? void 0 : $sub(string, m[j], m[j + 1]));
	}
	return a;
	}
	function convertFlagsToText(re) { return (re.global ? 'g' : '') + (re.ignoreCase ? 'i' : '') + (re.multiline ? 'm' : ''); }
	var RegExp = support.distinctConstructor(function RegExp(pattern, flags) {
	return ($getInternalProperty(pattern, "class") === "RegExp" && flags === void 0 ? pattern : new support.createRegExp(pattern, flags));
	}, support.createRegExp = function RegExp(pattern, flags) {
	if ($getInternalProperty(pattern, "class") === "RegExp") {
	if (flags !== void 0) throw typeError("Cannot supply flags when constructing one RegExp from another");
	flags = convertFlagsToText(pattern);
	pattern = pattern.source;
	}
	// TODO : short-cut most of this through cache instead of only the func def.
	// TODO : limit number of entries in cache
	pattern = (pattern === void 0 ? '' : str(pattern));
	flags = (flags === void 0 ? '' : str(flags));
	var template = { global: false, ignoreCase: false, multiline: false, source: pattern };
	for (var i = flags.length - 1; i >= 0; --i) {
	var p;
	if (!(p = REG_EXP_FLAG_TO_PROPERTY[flags[i]]) || template[p])
	throw syntaxError("Invalid regular expression flags");
	template[p] = true;
	}
	var key, func;
	if (!(func = regExpCache[key = pattern + ',' + template.ignoreCase + ',' + template.multiline]))
	regExpCache[key] = func = evalThere(compileRegExp(pattern, template.ignoreCase, template.multiline));
	var re = support.createWrapper("RegExp", func, regExpPrototype);
	defineProperties(re, { dontEnum: true, readOnly: true, dontDelete: true }, template);
	defineProperties(re, { dontEnum: true, dontDelete: true }, { lastIndex: 0 });
	return re;
	});
	defineProperties(RegExp, { dontEnum: true, readOnly: true, dontDelete: true }, { prototype: regExpPrototype = RegExp.prototype });
	defineProperties(RegExp.prototype, { dontEnum: true }, {
	exec: unconstructable(function exec(string) { checkClass(this, "RegExp", "exec"); return regExpExecMethod(this, string); }),
	test: unconstructable(function test(string) { checkClass(this, "RegExp", "test"); return execRegExp(this, string) !== void 0; }),
	toString: unconstructable(function toString() {
	checkClass(this, "RegExp", "toString");
	return '/' + this.source + '/' + convertFlagsToText(this);
	})
	});
	/* --- Set up globals --- */
	defineProperties(globals, { dontEnum: true }, {
	Array: Array,
	Boolean: Boolean,
	Date: Date,
	Function: Function,
	Math: support.createWrapper("Math", void 0),
	Number: Number,
	Object: Object,
	RegExp: RegExp,
	String: String,
	isFinite: unconstructable(function isFinite(v) { return $isFinite(+v) }),
	isNaN: unconstructable(function isNaN(v) { return $isNaN(+v) }),
	JSON: support.createWrapper("JSON", void 0),
	eval: support.evalFunction = unconstructable(function eval(x) { return support.eval(x) }),
	parseFloat: unconstructable(function parseFloat(string) { return support.parseFloat(str(string)) }),
	parseInt: unconstructable(function parseInt(string, radix) {
	string = str(string);
	var pic = PARSE_INT_CHARS, i = -1, sign = 1;
	while (pic[string[++i]] === null) ;
	switch (string[i]) {
	case '-': sign = -1;
	case '+': ++i;
	}
	if (((radix = int32(radix)) === 0 || radix === 16) && (string[i] === '0' && string[i + 1] === 'x')) {
	i += 2;
	radix = 16;
	}
	if (radix === 0) radix = 10;
	else if (radix < 2 || radix > 36) return $NaN;
	var v = 0, b, e = string.length, n;
	for (b = i; i < e && (n = pic[string[i]]) != null && n < radix; ++i) v = v * radix + n;
	return (b === i ? $NaN : v * sign);
	})
	});
	defineProperties(globals, { dontEnum: true, dontDelete: true }, {
	NaN: $NaN, Infinity: $Infinity, undefined: support.undefined
	});
	/* --- Math --- */
	defineProperties(Math, { readOnly: true, dontEnum: true, dontDelete: true }, {
	E: 2.718281828459045235360,
	LN10: 2.302585092994045684018,
	LN2: 0.6931471805599453094172,
	LOG10E: 0.43429448190325182765113,
	LOG2E: 1.442695040888963407360,
	PI: 3.1415926535897932,
	SQRT1_2: 0.7071067811865475244008,
	SQRT2: 1.414213562373095048802
	});
	defineProperties(Math, { dontEnum: true }, {
	abs: unconstructable(abs = function abs(v) { return ((v = +v) < 0 ? -v : v) }),
	acos: unconstructable(function acos(v) { return support.acos(+v) }),
	asin: unconstructable(function asin(v) { return support.asin(+v) }),
	atan: unconstructable(function atan(v) { return support.atan(+v) }),
	atan2: unconstructable(function atan2(y, x) { return support.atan2(+y, +x) }),
	ceil: unconstructable(function ceil(v) { return -$floor(-v) }),
	cos: unconstructable(function cos(v) { return support.cos(+v) }),
	exp: unconstructable(function exp(v) { return support.exp(+v) }),
	floor: unconstructable(function floor(v) { return $floor(+v) }),
	log: unconstructable(function log(v) { return support.log(+v) }),
	max: unconstructable(function max(x, y) { var m = -$Infinity, v, argv; for (var i = (argv = arguments).length - 1; i >= 0; --i) if ((v = +argv[i]) > m || $isNaN(v)) m = v; return m }),
	min: unconstructable(function min(x, y) { var m = $Infinity, v, argv; for (var i = (argv = arguments).length - 1; i >= 0; --i) if ((v = +argv[i]) < m || $isNaN(v)) m = v; return m }),
	pow: unconstructable(function pow(x, y) { return support.pow(+x, +y) }),
	random: unconstructable(function random() { return support.random() }),
	round: unconstructable(function round(v) { return (v === 0.0 ? v : (v >= -0.5 && v < 0.0 ? -0.0 : $floor(v + 0.5))) }),
	sin: unconstructable(function sin(v) { return support.sin(+v) }),
	sqrt: unconstructable(function sqrt(v) { return support.sqrt(+v) }),
	tan: unconstructable(function tan(v) { return support.tan(+v) })
	});
	/* --- Errors --- */
	function createErrorConstructor(name, prototype) {
	return function(message) {
	var e;
	support.defineProperty(e = support.createWrapper("Error", name, prototype), "message"
	, (message !== void 0 ? str(message) : ''), false, true, false);
	return e
	}
	};
	(function() {
	var ERROR_NAMES = [ "Error", "EvalError", "RangeError", "ReferenceError", "SyntaxError", "TypeError", "URIError" ];
	for (var i = ERROR_NAMES.length; --i >= 0;) {
	var n, c, p;
	support.defineProperty(globals, n = ERROR_NAMES[i], c = createErrorConstructor(n, p = support.prototypes[n])
	, false, true, false);
	c.name = n;	// Notice: from ES6 and upwards "name" is read-only (and you would have to delete it to modify here), but it isn't in this implementation
	defineProperties(c, { dontEnum: true, readOnly: true, dontDelete: true }, { prototype: p });
	defineProperties(p, { dontEnum: true }, { constructor: c });
	p.name = n;
	}
	defineProperties(Error.prototype, { dontEnum: true }, {
	message: '',
	toString: unconstructable(function toString() {
	return (this.name === void 0 ? "Error" : this.name) + (this.message ? (": " + this.message) : '');
	})
	});
	syntaxError = SyntaxError;
	rangeError = RangeError;
	typeError = TypeError;
	})();
	/* --- ES >3 polyfills --- */
	// These are not guaranteed to be 100% compatible
	var JSON_ESCAPE_SEQUENCES = { '\\': "\\\\", '"': "\\\"", '\b': "\\b", '\f': "\\f", '\n': "\\n", '\r': "\\r", '\t': "\\t" };
	var MAX_JSON_DEPTH = 61;	// compiler internal recursion limit is 64 (as of 20180610), we must stick under this for eval() to work and 61 gives us enough margin
	// TODO : use StringBuilder?
	defineProperties(JSON, { dontEnum: true }, {
	stringify: unconstructable(function stringify(val, replacer, space) {
	var stack = [ ], replacerFunction = (typeof replacer === "function" ? replacer : null), gap = '', includeProps;
	if ($getInternalProperty(replacer, "class") === "Array") {
	includeProps = { };
	for (var i = replacer.length; --i >= 0;) includeProps[replacer[i]] = true;
	}
	if (typeof space === "number" || (typeof space === "object" && $getInternalProperty(space, "class") === "Number")) {
	space = +space;
	for (var i = (space > 10 ? 10 : space); --i >= 0;) gap += ' ';
	} else if (typeof space === "string" || (typeof space === "object" && $getInternalProperty(space, "class") === "String")) {
	gap = $sub(str(space), 0, 10);
	}
	function quote(s) {
	var t = '"', len = s.length;
	for (var i = 0; i < len; ++i) {
	var ch = s[i], seq;
	t += ((seq = JSON_ESCAPE_SEQUENCES[ch])
	? seq : ((ch >= ' ' && ch <= '~')
	? ch : "\\u" + leftPad(numberToRadix($charCodeAt(ch, 0), 16), 4)));
	}
	return t + '"';
	}
	function string(key, holder, indent) {
	var val;
	if ((val = holder[key]) && typeof val === "object" && typeof val.toJSON === "function") val = val.toJSON(key);
	if (replacerFunction) val = $callWithArgs(replacerFunction, holder, [ key, val ]);
	var lineEnd = (gap ? '\n' + indent : '');
	if (typeof val === "object") {
	switch ($getInternalProperty(val, "class")) {
	case "Number": val = +val; break;
	case "String": val = str(val); break;
	case "Boolean": val = $getInternalProperty(val, "value"); break;
	}
	}
	switch (typeof val) {
	case "object": {
	if (!val) return "null";
	var len, s = new StringBuilder, v;
	for (var i = (len = stack.length); --i >= 0; ) {
	if (stack[i] === val) throw typeError("Cannot convert circular structure to JSON");
	}
	if (len > MAX_JSON_DEPTH) throw typeError("Structure too deeply nested for JSON conversion");
	stack[len] = val;
	if ($getInternalProperty(val, "class") === "Array") {
	len = val.length;
	for (var i = 0; i < len; ++i) {
	s.append((i == 0 ? '[' : ',') + lineEnd + gap + (string(i, val, indent + gap) || "null"));
	}
	s.append(len == 0 ? "[]" : lineEnd + ']');
	} else {
	var gotSomething = false;
	for (var k in (includeProps ? includeProps : val)) {
	if (support.hasOwnProperty(val, k)) {
	if (v = string(k, val, indent + gap)) {
	s.append((gotSomething ? ',' : '{') + lineEnd + gap + quote(k)
	+ (gap ? ": " : ':') + v);
	gotSomething = true;
	}
	}
	}
	s.append(gotSomething ? lineEnd + '}' : "{}");
	}
	--stack.length;
	return s.build();
	}
	case "string": return quote(val);
	case "number": return ($isFinite(val) ? str(val) : "null");
	case "boolean": return str(val);
	}
	}
	return string('', { '': val }, '');
	}),
	parse: unconstructable(function parse(text, reviver) {
	var nest = 0;
	function space(t, p) {
	var ch;
	while ((ch = t[p]) === ' ' || ch === '\t' || ch === '\r' || ch === '\n') ++p;
	return p;
	}
	function number(t, p) {
	var ch;
	if (t[p] === '-') ++p;
	if ((ch = t[p]) === '0') ch = t[++p];
	else if (ch >= '1' && ch <= '9') do { ch = t[++p]; } while (ch >= '0' && ch <= '9');
	else return;
	if (ch === '.') {
	if ((ch = t[++p]) < '0' || ch > '9') return;
	while ((ch = t[++p]) >= '0' && ch <= '9') ;
	}
	if (ch === 'e' || ch === 'E') {
	if ((ch = t[++p]) === '-' || ch === '+') ch = t[++p];
	if (ch < '0' || ch > '9') return;
	while ((ch = t[++p]) >= '0' && ch <= '9') ;
	}
	return p;
	}
	function string(t, p) {
	var ch;
	if (t[p] !== '"') return;
	++p;
	while ((ch = t[p]) !== '"' && ch >= ' ') {
	if (ch === '\\') {
	switch (t[++p]) {
	default: return;
	case '"': case '/': case '\\': case 'b': case 'f': case 'n': case 'r': case 't': break;
	case 'u':
	for (var i = 4; --i >= 0; )
	if (!(((ch = t[++p]) >= '0' && ch <= '9')
	|| (ch >= 'a' && ch <= 'f') || (ch >= 'A' && ch <= 'F'))) return;
	break;
	}
	}
	++p;
	}
	if (ch === '"') return ++p;
	}
	function literal(t, p) {
	if ($match(t, p, "true") || $match(t, p, "null")) return p + 4;
	else if ($match(t, p, "false")) return p + 5;
	}
	function object(t, p) {
	if (nest > MAX_JSON_DEPTH) throw typeError("Structure too deeply nested for JSON conversion");
	++nest;
	try {
	var ch, expectComma = false, open = t[p], close = (open === '[' ? ']' : '}');
	p = space(t, ++p);
	while ((ch = t[p]) !== close && ch) {
	if (expectComma) {
	if (ch !== ',') return;
	p = space(t, ++p);
	}
	if (open === '{') {
	if (!(p = string(t, p)) || t[p = space(t, p)] !== ':') return;
	p = space(t, ++p);
	}
	if (!(parser = PARSERS[t[p]]) || !(p = parser(t, p))) return;
	p = space(t, p);
	expectComma = true;
	}
	if (ch === close) return ++p;
	}
	finally {
	--nest;
	}
	}
	var PARSERS = {
	'{': object, '[': object, '"': string, 't': literal, 'f': literal, 'n': literal
	, '-': number, '0': number, '1': number, '2': number, '3': number, '4': number
	, '5': number, '6': number, '7': number, '8': number, '9': number
	};
	text = str(text);
	var p, parser;
	if ((parser = PARSERS[text[p = space(text, 0)]]) && (p = parser(text, p))
	&& space(text, p) === text.length) {
	var val = eval('(' + text + ')');
	if (typeof reviver === "function") {
	function walk(holder, key) {
	var k, v, o;
	if (typeof (o = holder[key]) === "object" && o) {
	for (k in o) {
	if (support.hasOwnProperty(o, k)) {
	if ((v = walk(o, k)) !== void 0) o[k] = v;
	else delete o[k];
	}
	}
	}
	return $callWithArgs(reviver, holder, [ key, o ]);
	}
	val = walk({ "": val }, "");
	}
	return val;
	}
	throw syntaxError("Error parsing JSON");
	})
	});
	defineProperties(Array, { dontEnum: true }, {
	isArray: unconstructable(function isArray(o) { return $getInternalProperty(o, "class") === "Array"; })
	});
	defineProperties(Object, {dontEnum : true}, {
	defineProperty : unconstructable(function defineProperty(o, p, d) {
	var k = str(p);
	var ro = !d.writable, de = !d.enumerable, dd = !d.configurable;
	if ("get" in d || "set" in d) {
	if ("value" in d || "writable" in d)
	throw TypeError();
	var g = d.get;
	var s = d.set;
	if (g !== undefined && typeof g !== "function")
	throw TypeError();
	if (s !== undefined && typeof s !== "function")
	throw TypeError();
	support.defineProperty(o, k, undefined, ro, de, dd, g, s);
	} else {
	support.defineProperty(o, k, d.value, ro, de, dd);
	}
	}),
	getPrototypeOf : unconstructable(function getPrototypeOf(o) {
	return $getInternalProperty(o, "prototype");
	})
	});
	if ($NaN.toString() !== "NaN") throw Error("Internal self test failed. Check C++ compiler options concerning IEEE 754 compliance.");
	})
