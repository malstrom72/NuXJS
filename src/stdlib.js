/*
	@preserve: Array,Boolean,Date,E,Error,Function,Infinity,LN10,LN2,LOG10E,LOG2E,MAX_VALUE,MIN_VALUE,Math
	@preserve: NEGATIVE_INFINITY,NaN,Number,Object,PI,POSITIVE_INFINITY,RangeError,RegExp,SQRT1_2,SQRT2,String
	@preserve: SyntaxError,TypeError,UTC,abs,acos,apply,arguments,asin,atan,atan2,break,call,callWithArgs,case,ceil
	@preserve: charAt,charCodeAt,configurable,concat,cos,default,defineProperty,delete,do,dontDelete,dontEnum
	@preserve: else,enumerable,eval,exec,exp,false,finally,floor,for,fromCharCode,function,getCurrentTime
	@preserve: getDate,getDay,getFullYear,getHours,getInternalProperty,getMilliseconds,getMinutes,getMonth
	@preserve: getPrototypeOf,getSeconds,getTime,getTimezoneOffset,getUTCDate,getUTCDay,getUTCFullYear,getUTCHours
	@preserve: getUTCMilliseconds,getUTCMinutes,getUTCMonth,getUTCSeconds,hasOwnProperty,if,ignoreCase,in,index,indexOf
	@preserve: input,isArray,isFinite,isNaN,isPropertyEnumerable,join,lastIndex,lastIndexOf,length,localeCompare,log
	@preserve: match,max,maxNumber,message,min,minNumber,multiline,name,new,null,parseFloat,parseInt,pow
	@preserve: propertyIsEnumerable,prototype,push,readOnly,regExpCanonicalize,return,reverse,round,setDate
	@preserve: setFullYear,setHours,setMilliseconds,setMinutes,setMonth,setSeconds,setTime,setUTCDate
	@preserve: setUTCFullYear,setUTCHours,setUTCMilliseconds,setUTCMinutes,setUTCMonth,setUTCSeconds,shift,sin,slice
	@preserve: sort,distinctConstructor,sqrt,submatch,substr,substring,switch,tan,this,throw,time,toExponential
	@preserve: toFixed,toISOString,toLocaleDateString,toLocaleLowerCase,toLocaleString,toLocaleTimeString
	@preserve: toLocaleUpperCase,toLowerCase,toPrecision,toString,toTimeString,toUTCString,toUpperCase,true,try,typeof
	@preserve: undefined,upperToLower,value,valueOf,var,void,while,writable,pop,parse,toDateString,instanceof,test
	@preserve: toPrimitiveNumber,toPrimitiveString,constructor,isPrototypeOf,prototypes,createWrapper,$match
	@preserve: $sub,createRegExp,CC,global,source,JSON,stringify,toJSON,unshift,compileFunction,localTimeDifference
	@preserve: splice,split,search,replace,random,evalFunction,updateDateValue,toPrimitive
//#if ES5
	@preserve: trim,preventExtensions,isExtensible,defineOwnProperty,get,set,keys,create,now,seal,freeze,isSealed
	@preserve: getOwnPropertyDescriptor,getOwnPropertyNames,createObject,isFrozen,bind,bindFunction,forEach,map
	@preserve: filter,some,every,reduce,reduceRight,getYear,setYear,toGMTString,setArrayLength
	@preserve: decodeURI,decodeURIComponent,encodeURI,encodeURIComponent,URIError
//#endif

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
		callWithArgs(func: function, [this: object], [args: array], [offset: number], [length: number]): any
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
//#if ES5
		, uriError
//#endif
		, ALPHA_DIGITS_LOWER = "0123456789abcdefghijklmnopqrstuvwxyz", ALPHA_DIGITS_UPPER = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"
// generated: white space (tools/work/generateUnicodeTables.js), do not edit by hand
//#if !ES5
		, WHITE_SPACES = "\t\n\v\f\r \xa0\u1680\u2000\u2001\u2002\u2003\u2004\u2005\u2006\u2007\u2008\u2009\u200a\u200b\u2028\u2029\u202f\u3000"; // 7.2 WhiteSpace and 7.3 LineTerminator, <USP> being Zs of Unicode 3.0.0
//#else
		, WHITE_SPACES = "\t\n\v\f\r \xa0\u1680\u2000\u2001\u2002\u2003\u2004\u2005\u2006\u2007\u2008\u2009\u200a\u200b\u2028\u2029\u202f\u3000\ufeff"; // 7.2 WhiteSpace and 7.3 LineTerminator, <USP> being Zs of Unicode 3.0.0
//#endif
// end generated: white space

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
	var t;
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
//#if ES5
/*
	15.4.5.1 (3.c) runs ToUint32 over the assigned value, which for an object means its valueOf, and the array's
	store path may not run script. The VM hands such a store here instead, entering it exactly as it enters a
	setter, so the receiver is the array and the value is the only argument. `+v` yields a primitive, so the store
	below takes the ordinary path and this cannot re-enter.
*/
support.setArrayLength = function setArrayLength(v) { this.length = +v };
//#endif

// 9.4 ToInteger. Infinities need no special case: floor leaves them as they are.
function int(v) { return ($isNaN(v = +v) || v === 0) ? 0 : (v < 0 ? -$floor(-v) : $floor(v)); }
// 9.5 ToInt32 and 9.6 ToUint32 are exactly what these operators do, so neither needs to truncate first.
function int32(v) { return v | 0; }
function uint32(v) { return v >>> 0; }
//#if ES5

/*
	9.9 ToObject for the Array.prototype methods, which reject null and undefined where the Object constructor
	makes fresh objects of them. Its sibling 9.10 CheckObjectCoercible is spelled out inline at each String and
	Object method instead: they do so little else that a call frame for the test measured 2.2% on a charCodeAt
	loop. Either way the callers must be strict code, 10.4.3 otherwise substituting the global object for a null
	this and making the step unreachable.
*/
function toObject(v, what) {
	var t;
	if (v == null) throw typeError("Array.prototype." + what + " called on null or undefined");
	return ((t = typeof v) === "object" || t === "function" ? v : Object(v))	// null is out, so an object or function is already the result, no second frame
}
//#endif

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
//#if ES5
/*
	15.5.4.2-3 take a String value as readily as a String object, and the String.prototype table being strict, a
	primitive receiver now arrives unboxed (10.4.3) where the class test alone would reject the very value the
	clause is about. Testing typeof rather than boxing keeps `"s".toString()` from allocating at all.
*/
function thisStringValue(v, forFunction) {
	if (typeof v === "string") return v;
	checkClass(v, "String", forFunction);
	return $getInternalProperty(v, "value")
}
//#endif

function leftPad(s, l) { var n = (s = "00000000000000000000" + s).length; return $sub(s, n - l, n); }

// Exact decimal expansion, little-endian, `fraction` digits below the point. 15.7.4.5-7 round on this and not on
// double arithmetic, which cannot see that 0.35 is really 0.34999999999999997779 and so must round DOWN.
var ELEMENT_DIGITS = 8, POW10 = [1, 10, 100, 1e3, 1e4, 1e5, 1e6, 1e7, 1e8], ELEMENT_BASE = POW10[ELEMENT_DIGITS];

function carryDigits(digits, factor, carry, from) {
	var d, b = ELEMENT_BASE, i = from, n = digits.length;
	for (; i < n; ++i) {
		digits[i] = d = (carry += digits[i] * factor) % b;
		carry = (carry - d) / b;
	}
	for (; carry; ++i) {
		digits[i] = d = carry % b;
		carry = (carry - d) / b;
	}
}

function exactDigits(val) {
	var shift = 0, i, base, cap, full, digits = [];
	for (; val % 1; shift -= 32) val *= 4294967296;	// 32 bits a time, the loop below divides the overshoot back out
	for (; val > 9007199254740991; ++shift) val /= 2;	// carryDigits is only exact under 2^53
	carryDigits(digits, 0, val, 0);
	base = (shift < 0 ? 5 : 2);
	cap = (shift < 0 ? 11 : 26);	// 1e8 * 5^11 and 1e8 * 2^26 stay under 2^53; widen ELEMENT_DIGITS and these must drop
	full = support.pow(base, cap);
	for (i = abs(shift); i > cap; i -= cap) carryDigits(digits, full, 0, 0);
	if (i > 0) carryDigits(digits, support.pow(base, i), 0, 0);
	digits.fraction = (shift < 0 ? -shift : 0);
	return digits;
}

// CONSUMES `digits`: cuts by reading from `from`, slice being user-overridable. `place` counts digits and not
// elements, so the cut usually lands inside one and the probe and its carry sit at 10^off.
function digitString(digits, place) {
	var i, n, v, from = (place > 0 ? place : 0), s = '';
	var at = $floor(from / ELEMENT_DIGITS), off = from % ELEMENT_DIGITS;
	if (from > 0 && $floor(digits[$floor((from - 1) / ELEMENT_DIGITS)] / POW10[(from - 1) % ELEMENT_DIGITS]) % 10 >= 5)
		carryDigits(digits, 1, POW10[off], at);
	if (at < (n = digits.length)) {	// after the bump, which can have grown the array by one
		for (i = n; --i > at; ) s += (i === n - 1 ? digits[i] : leftPad(digits[i], ELEMENT_DIGITS));
		v = $floor(digits[at] / POW10[off]);
		s += (at === n - 1 ? v : leftPad(v, ELEMENT_DIGITS - off));
	}
	while (place++ < 0) s += '0';
	return s;
}

// leftPad's run is 20 zeros, which covers the 15.7.4.5-7 maximum of 20 fraction digits.
function placePoint(s, exponent) {
	return (exponent < 0 ? '0.' + leftPad('', -exponent - 1) + s
			: exponent + 1 >= s.length ? s
			: $sub(s, 0, exponent + 1) + '.' + $sub(s, exponent + 1, s.length));
}

function numberToString(num, digits, eNotationBelow) {
	// String.prototype.indexOf is user-overridable so is out; indexing is an own-property read.
	function findChar(s, ch) {
		for (var i = 0, n = s.length; i < n; ++i) if (s[i] === ch) return i;
		return n;
	}
	var sign = '', expansion, exponent, i, n, s;
	if (num < 0) { num = -num; sign = '-'; }
	if (digits === void 0) {
		exponent = +$sub(s = '' + num, (i = findChar(s, 'e')) + 1, s.length);
		exponent += (i = findChar(s = $sub(s, 0, i), '.')) - 1;
		s = $sub(s, 0, i) + $sub(s, i + 1, s.length);
		n = s.length;
		for (i = 0; i < n - 1 && s[i] === '0'; ++i) --exponent;	// "0.000001" carries its exponent as zeros
		while (n > i + 1 && s[n - 1] === '0') --n;	// 15.7.4.6: n is not divisible by 10
		s = $sub(s, i, n);
	} else {	// zero expands to no digits at all, and its exponent is 0
		// n counts digits, not elements, and must be read before digitString consumes the expansion
		i = (expansion = exactDigits(num)).length;
		n = (i ? (i - 1) * ELEMENT_DIGITS + ('' + expansion[i - 1]).length : 0);
		exponent = (n ? n - 1 - expansion.fraction : 0);
		s = digitString(expansion, n - digits - 1);
		if (s.length > digits + 1) { s = $sub(s, 0, digits + 1); ++exponent; }	// 9.99 -> 1.00e+1, carry grew the count
	}
	if (exponent >= eNotationBelow && exponent <= digits) return sign + placePoint(s, exponent);
	return sign + placePoint(s, 0) + (exponent >= 0 ? 'e+' : 'e') + exponent;
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
//#if ES5
// 15.2.4: step 1 of every method below is ToObject(this), which only strict code can ever fail. The entries keep
// their indentation, this wrapper being invisible to the ES3 source.
(function() {
"use strict";
//#endif
defineProperties(Object.prototype, { dontEnum: true }, {
	constructor: Object,
//#if !ES5
	valueOf: unconstructable(function valueOf() { return this }),
//#else
	// 15.2.4.4 returns ToObject(this), which for a boxed receiver is the receiver itself; the conversion matters
	// only for null and undefined, and for the day `this` reaches a callee as a Value rather than as an object.
	valueOf: unconstructable(function valueOf() {
		if (this == null) throw typeError("Object.prototype.valueOf called on null or undefined");
		return Object(this);
	}),
//#endif
//#if !ES5
	toLocaleString: unconstructable(function toLocaleString() { return this.toString() }),
//#else
	toLocaleString: unconstructable(function toLocaleString() {	// 15.2.4.3 step 1
		if (this == null) throw typeError("Object.prototype.toLocaleString called on null or undefined");
		return this.toString();
	}),
//#endif
//#if !ES5
	toString: unconstructable(function toString() {
		var s;
		return "[object " + (((s = $getInternalProperty(this, "class")) === "Arguments") ? "Object" : s) + ']'
	}),
//#else
	/*
		15.2.4.2 gained explicit undefined and null cases ahead of ToObject, and 10.6 gave the arguments object the
		class "Arguments" where ES3 10.1.8 gave it "Object", which is what the entry above maps back. Steps 1 and 2
		can tell the two apart only because a strict callee now receives the this value verbatim (10.4.3).
	*/
	toString: unconstructable(function toString() {
		if (this === void 0) return "[object Undefined]";
		if (this === null) return "[object Null]";
		return "[object " + $getInternalProperty(Object(this), "class") + ']';
	}),
//#endif
//#if !ES5
	hasOwnProperty: unconstructable(function hasOwnProperty(name) { return support.hasOwnProperty(this, str(name)) }),
	propertyIsEnumerable: unconstructable(function propertyIsEnumerable(name) { return support.isPropertyEnumerable(this, str(name)) }),
//#else
	// 15.2.4.5 and 15.2.4.7 take ToObject(this) as step 2, after ToString(P); the natives answer false rather than
	// throwing for a non-object, so the step has to be spelled out here.
	hasOwnProperty: unconstructable(function hasOwnProperty(name) {
		if (this == null) throw typeError("Object.prototype.hasOwnProperty called on null or undefined");
		return support.hasOwnProperty(this, str(name));
	}),
	propertyIsEnumerable: unconstructable(function propertyIsEnumerable(name) {
		if (this == null) throw typeError("Object.prototype.propertyIsEnumerable called on null or undefined");
		return support.isPropertyEnumerable(this, str(name));
	}),
//#endif
	isPrototypeOf: unconstructable(function isPrototypeOf(v) {
//#if ES5
		if (isPrimitive(v)) return false;	// 15.2.4.6 tests V before step 2, so a primitive V never reaches ToObject
		if (this == null) throw typeError("Object.prototype.isPrototypeOf called on null or undefined");
//#endif
		while (v = $getInternalProperty(v, "prototype")) {
			if (v === this) return true;
		}
		return false;
	})
});
//#if ES5
})();
//#endif

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
//#if !ES5
		else if ((theClass = $getInternalProperty(argArray, "class")) !== "Array" && theClass !== "Arguments") {
			throw typeError("Argument list has wrong type");
		};
//#else
		else if (isPrimitive(argArray)) throw typeError("Argument list has wrong type");	// 15.3.4.3 (3): any object serves as the list
		// 15.3.4.3 (6) takes ToUint32 of the length, which for an object runs valueOf. The native cannot run script
		// on its own, so the conversion happens here and it reads the length only once, as [[Get]] is observable.
		else return $callWithArgs(this, thisArg, argArray, 0, +argArray.length);
//#endif
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
		else if (radix === 10) return '' + val; // 15.7.4.2: radix 10 must use ToString (shortest decimal), not numberToRadix
		else return numberToRadix(val, radix);
	}),
	toExponential: unconstructable(function toExponential(fractionDigits) {
		var val, digits;
		// 15.7.4.6 returns a String throughout, so the non-finites are converted rather than passed back raw
		if (!$isFinite(val = getInternalNumber(this, "toExponential"))) return '' + val;
		else if (fractionDigits === void 0) return numberToString(val, void 0, $Infinity);
		else {
			if ((digits = int(fractionDigits)) < 0 || digits > 20) {
				throw rangeError("Illegal fractionDigits argument for toExponential()");
			}
			return numberToString(val, digits, $Infinity);
		}
	}),
	// 15.7.4.5 step 10 wants the integer nearest val * 10^f, ties upward: see exactDigits. The cut is at an absolute
	// decimal place, not a significant-digit count, so unlike 15.7.4.6 and .7 this does not go through numberToString.
	toFixed: unconstructable(function toFixed(fractionDigits) {
		var val, digits, sign = '', s, expansion;
		if ((digits = int(fractionDigits)) < 0 || digits > 20) {
			throw rangeError("Illegal fractionDigits argument for toFixed()");
		}
		if ($isNaN(val = getInternalNumber(this, "toFixed")) || val <= -1e21 || val >= 1e21) return '' + val;
		if (val < 0) { val = -val; sign = '-'; }
		// under 5e-21 every legal f rounds to zeros, so all that is left is the padding leftPad already spells
		s = (val >= 5e-21 ? digitString(expansion = exactDigits(val), expansion.fraction - digits)
				: leftPad('', digits)) || '0';	// empty only when f is 0 and val rounds away
		return sign + placePoint(s, s.length - 1 - digits);
	}),
	toPrecision: unconstructable(function toPrecision(precision) {
		var val = getInternalNumber(this, "toPrecision"), digits;
		if (precision === void 0 || !$isFinite(val)) return '' + val;	// 15.7.4.7 step 2 is ToString, so a String
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
// generated: case tables (tools/work/generateUnicodeTables.js), do not edit by hand
	lowerToUpper = {
		"\xb5":"\u039c","\xdf":"SS",
		"\u0131":"I","\u0149":"\u02bcN","\u017f":"S","\u01c5":"\u01c4","\u01c8":"\u01c7","\u01cb":"\u01ca","\u01f0":"J\u030c","\u01f2":"\u01f1","\u0345":"\u0399","\u0390":"\u0399\u0308\u0301","\u03b0":"\u03a5\u0308\u0301","\u03c2":"\u03a3","\u03d0":"\u0392","\u03d1":"\u0398","\u03d5":"\u03a6","\u03d6":"\u03a0","\u03f0":"\u039a","\u03f1":"\u03a1","\u03f2":"\u03a3","\u0587":"\u0535\u0552","\u1e96":"H\u0331","\u1e97":"T\u0308","\u1e98":"W\u030a","\u1e99":"Y\u030a","\u1e9a":"A\u02be","\u1e9b":"\u1e60","\u1f50":"\u03a5\u0313","\u1f52":"\u03a5\u0313\u0300",
		"\u1f54":"\u03a5\u0313\u0301","\u1f56":"\u03a5\u0313\u0342","\u1f80":"\u1f08\u0399","\u1f81":"\u1f09\u0399","\u1f82":"\u1f0a\u0399","\u1f83":"\u1f0b\u0399","\u1f84":"\u1f0c\u0399","\u1f85":"\u1f0d\u0399","\u1f86":"\u1f0e\u0399","\u1f87":"\u1f0f\u0399","\u1f88":"\u1f08\u0399","\u1f89":"\u1f09\u0399","\u1f8a":"\u1f0a\u0399","\u1f8b":"\u1f0b\u0399","\u1f8c":"\u1f0c\u0399","\u1f8d":"\u1f0d\u0399","\u1f8e":"\u1f0e\u0399","\u1f8f":"\u1f0f\u0399","\u1f90":"\u1f28\u0399","\u1f91":"\u1f29\u0399","\u1f92":"\u1f2a\u0399","\u1f93":"\u1f2b\u0399","\u1f94":"\u1f2c\u0399",
		"\u1f95":"\u1f2d\u0399","\u1f96":"\u1f2e\u0399","\u1f97":"\u1f2f\u0399","\u1f98":"\u1f28\u0399","\u1f99":"\u1f29\u0399","\u1f9a":"\u1f2a\u0399","\u1f9b":"\u1f2b\u0399","\u1f9c":"\u1f2c\u0399","\u1f9d":"\u1f2d\u0399","\u1f9e":"\u1f2e\u0399","\u1f9f":"\u1f2f\u0399","\u1fa0":"\u1f68\u0399","\u1fa1":"\u1f69\u0399","\u1fa2":"\u1f6a\u0399","\u1fa3":"\u1f6b\u0399","\u1fa4":"\u1f6c\u0399","\u1fa5":"\u1f6d\u0399","\u1fa6":"\u1f6e\u0399","\u1fa7":"\u1f6f\u0399","\u1fa8":"\u1f68\u0399","\u1fa9":"\u1f69\u0399","\u1faa":"\u1f6a\u0399","\u1fab":"\u1f6b\u0399","\u1fac":"\u1f6c\u0399",
		"\u1fad":"\u1f6d\u0399","\u1fae":"\u1f6e\u0399","\u1faf":"\u1f6f\u0399","\u1fb2":"\u1fba\u0399","\u1fb3":"\u0391\u0399","\u1fb4":"\u0386\u0399","\u1fb6":"\u0391\u0342","\u1fb7":"\u0391\u0342\u0399","\u1fbc":"\u0391\u0399","\u1fbe":"\u0399","\u1fc2":"\u1fca\u0399","\u1fc3":"\u0397\u0399","\u1fc4":"\u0389\u0399","\u1fc6":"\u0397\u0342","\u1fc7":"\u0397\u0342\u0399","\u1fcc":"\u0397\u0399","\u1fd2":"\u0399\u0308\u0300","\u1fd3":"\u0399\u0308\u0301","\u1fd6":"\u0399\u0342","\u1fd7":"\u0399\u0308\u0342","\u1fe2":"\u03a5\u0308\u0300","\u1fe3":"\u03a5\u0308\u0301",
		"\u1fe4":"\u03a1\u0313","\u1fe6":"\u03a5\u0342","\u1fe7":"\u03a5\u0308\u0342","\u1ff2":"\u1ffa\u0399","\u1ff3":"\u03a9\u0399","\u1ff4":"\u038f\u0399","\u1ff6":"\u03a9\u0342","\u1ff7":"\u03a9\u0342\u0399","\u1ffc":"\u03a9\u0399","\ufb00":"FF","\ufb01":"FI","\ufb02":"FL","\ufb03":"FFI","\ufb04":"FFL","\ufb05":"ST","\ufb06":"ST","\ufb13":"\u0544\u0546","\ufb14":"\u0544\u0535","\ufb15":"\u0544\u053b","\ufb16":"\u054e\u0546","\ufb17":"\u0544\u053d"
	};
	upperToLower = {
		"\u0130":"i","\u01c5":"\u01c6","\u01c8":"\u01c9","\u01cb":"\u01cc","\u01f2":"\u01f3","\u1f88":"\u1f80","\u1f89":"\u1f81","\u1f8a":"\u1f82","\u1f8b":"\u1f83","\u1f8c":"\u1f84","\u1f8d":"\u1f85","\u1f8e":"\u1f86","\u1f8f":"\u1f87","\u1f98":"\u1f90","\u1f99":"\u1f91","\u1f9a":"\u1f92","\u1f9b":"\u1f93","\u1f9c":"\u1f94","\u1f9d":"\u1f95","\u1f9e":"\u1f96","\u1f9f":"\u1f97","\u1fa8":"\u1fa0","\u1fa9":"\u1fa1","\u1faa":"\u1fa2","\u1fab":"\u1fa3","\u1fac":"\u1fa4","\u1fad":"\u1fa5","\u1fae":"\u1fa6","\u1faf":"\u1fa7","\u1fbc":"\u1fb3","\u1fcc":"\u1fc3","\u1ffc":"\u1ff3",
		"\u2126":"\u03c9","\u212a":"k","\u212b":"\xe5"
	};
	var c, BIDIRECTIONAL = {
		'A':"a",'B':"b",'C':"c",'D':"d",'E':"e",'F':"f",'G':"g",'H':"h",'I':"i",'J':"j",'K':"k",'L':"l",'M':"m",'N':"n",'O':"o",'P':"p",'Q':"q",'R':"r",'S':"s",'T':"t",'U':"u",'V':"v",'W':"w",'X':"x",'Y':"y",'Z':"z",
		"\xc0":"\xe0","\xc1":"\xe1","\xc2":"\xe2","\xc3":"\xe3","\xc4":"\xe4","\xc5":"\xe5","\xc6":"\xe6","\xc7":"\xe7","\xc8":"\xe8","\xc9":"\xe9","\xca":"\xea","\xcb":"\xeb","\xcc":"\xec","\xcd":"\xed","\xce":"\xee","\xcf":"\xef","\xd0":"\xf0","\xd1":"\xf1","\xd2":"\xf2","\xd3":"\xf3","\xd4":"\xf4","\xd5":"\xf5","\xd6":"\xf6","\xd8":"\xf8","\xd9":"\xf9","\xda":"\xfa","\xdb":"\xfb","\xdc":"\xfc","\xdd":"\xfd","\xde":"\xfe",
		"\u0100":"\u0101","\u0102":"\u0103","\u0104":"\u0105","\u0106":"\u0107","\u0108":"\u0109","\u010a":"\u010b","\u010c":"\u010d","\u010e":"\u010f","\u0110":"\u0111","\u0112":"\u0113","\u0114":"\u0115","\u0116":"\u0117","\u0118":"\u0119","\u011a":"\u011b","\u011c":"\u011d","\u011e":"\u011f","\u0120":"\u0121","\u0122":"\u0123","\u0124":"\u0125","\u0126":"\u0127","\u0128":"\u0129","\u012a":"\u012b","\u012c":"\u012d","\u012e":"\u012f","\u0132":"\u0133","\u0134":"\u0135","\u0136":"\u0137","\u0139":"\u013a","\u013b":"\u013c","\u013d":"\u013e","\u013f":"\u0140","\u0141":"\u0142",
		"\u0143":"\u0144","\u0145":"\u0146","\u0147":"\u0148","\u014a":"\u014b","\u014c":"\u014d","\u014e":"\u014f","\u0150":"\u0151","\u0152":"\u0153","\u0154":"\u0155","\u0156":"\u0157","\u0158":"\u0159","\u015a":"\u015b","\u015c":"\u015d","\u015e":"\u015f","\u0160":"\u0161","\u0162":"\u0163","\u0164":"\u0165","\u0166":"\u0167","\u0168":"\u0169","\u016a":"\u016b","\u016c":"\u016d","\u016e":"\u016f","\u0170":"\u0171","\u0172":"\u0173","\u0174":"\u0175","\u0176":"\u0177","\u0178":"\xff","\u0179":"\u017a","\u017b":"\u017c","\u017d":"\u017e","\u0181":"\u0253","\u0182":"\u0183",
		"\u0184":"\u0185","\u0186":"\u0254","\u0187":"\u0188","\u0189":"\u0256","\u018a":"\u0257","\u018b":"\u018c","\u018e":"\u01dd","\u018f":"\u0259","\u0190":"\u025b","\u0191":"\u0192","\u0193":"\u0260","\u0194":"\u0263","\u0196":"\u0269","\u0197":"\u0268","\u0198":"\u0199","\u019c":"\u026f","\u019d":"\u0272","\u019f":"\u0275","\u01a0":"\u01a1","\u01a2":"\u01a3","\u01a4":"\u01a5","\u01a6":"\u0280","\u01a7":"\u01a8","\u01a9":"\u0283","\u01ac":"\u01ad","\u01ae":"\u0288","\u01af":"\u01b0","\u01b1":"\u028a","\u01b2":"\u028b","\u01b3":"\u01b4","\u01b5":"\u01b6","\u01b7":"\u0292",
		"\u01b8":"\u01b9","\u01bc":"\u01bd","\u01c4":"\u01c6","\u01c7":"\u01c9","\u01ca":"\u01cc","\u01cd":"\u01ce","\u01cf":"\u01d0","\u01d1":"\u01d2","\u01d3":"\u01d4","\u01d5":"\u01d6","\u01d7":"\u01d8","\u01d9":"\u01da","\u01db":"\u01dc","\u01de":"\u01df","\u01e0":"\u01e1","\u01e2":"\u01e3","\u01e4":"\u01e5","\u01e6":"\u01e7","\u01e8":"\u01e9","\u01ea":"\u01eb","\u01ec":"\u01ed","\u01ee":"\u01ef","\u01f1":"\u01f3","\u01f4":"\u01f5","\u01f6":"\u0195","\u01f7":"\u01bf","\u01f8":"\u01f9","\u01fa":"\u01fb","\u01fc":"\u01fd","\u01fe":"\u01ff","\u0200":"\u0201","\u0202":"\u0203",
		"\u0204":"\u0205","\u0206":"\u0207","\u0208":"\u0209","\u020a":"\u020b","\u020c":"\u020d","\u020e":"\u020f","\u0210":"\u0211","\u0212":"\u0213","\u0214":"\u0215","\u0216":"\u0217","\u0218":"\u0219","\u021a":"\u021b","\u021c":"\u021d","\u021e":"\u021f","\u0222":"\u0223","\u0224":"\u0225","\u0226":"\u0227","\u0228":"\u0229","\u022a":"\u022b","\u022c":"\u022d","\u022e":"\u022f","\u0230":"\u0231","\u0232":"\u0233","\u0386":"\u03ac","\u0388":"\u03ad","\u0389":"\u03ae","\u038a":"\u03af","\u038c":"\u03cc","\u038e":"\u03cd","\u038f":"\u03ce","\u0391":"\u03b1","\u0392":"\u03b2",
		"\u0393":"\u03b3","\u0394":"\u03b4","\u0395":"\u03b5","\u0396":"\u03b6","\u0397":"\u03b7","\u0398":"\u03b8","\u0399":"\u03b9","\u039a":"\u03ba","\u039b":"\u03bb","\u039c":"\u03bc","\u039d":"\u03bd","\u039e":"\u03be","\u039f":"\u03bf","\u03a0":"\u03c0","\u03a1":"\u03c1","\u03a3":"\u03c3","\u03a4":"\u03c4","\u03a5":"\u03c5","\u03a6":"\u03c6","\u03a7":"\u03c7","\u03a8":"\u03c8","\u03a9":"\u03c9","\u03aa":"\u03ca","\u03ab":"\u03cb","\u03da":"\u03db","\u03dc":"\u03dd","\u03de":"\u03df","\u03e0":"\u03e1","\u03e2":"\u03e3","\u03e4":"\u03e5","\u03e6":"\u03e7","\u03e8":"\u03e9",
		"\u03ea":"\u03eb","\u03ec":"\u03ed","\u03ee":"\u03ef","\u0400":"\u0450","\u0401":"\u0451","\u0402":"\u0452","\u0403":"\u0453","\u0404":"\u0454","\u0405":"\u0455","\u0406":"\u0456","\u0407":"\u0457","\u0408":"\u0458","\u0409":"\u0459","\u040a":"\u045a","\u040b":"\u045b","\u040c":"\u045c","\u040d":"\u045d","\u040e":"\u045e","\u040f":"\u045f","\u0410":"\u0430","\u0411":"\u0431","\u0412":"\u0432","\u0413":"\u0433","\u0414":"\u0434","\u0415":"\u0435","\u0416":"\u0436","\u0417":"\u0437","\u0418":"\u0438","\u0419":"\u0439","\u041a":"\u043a","\u041b":"\u043b","\u041c":"\u043c",
		"\u041d":"\u043d","\u041e":"\u043e","\u041f":"\u043f","\u0420":"\u0440","\u0421":"\u0441","\u0422":"\u0442","\u0423":"\u0443","\u0424":"\u0444","\u0425":"\u0445","\u0426":"\u0446","\u0427":"\u0447","\u0428":"\u0448","\u0429":"\u0449","\u042a":"\u044a","\u042b":"\u044b","\u042c":"\u044c","\u042d":"\u044d","\u042e":"\u044e","\u042f":"\u044f","\u0460":"\u0461","\u0462":"\u0463","\u0464":"\u0465","\u0466":"\u0467","\u0468":"\u0469","\u046a":"\u046b","\u046c":"\u046d","\u046e":"\u046f","\u0470":"\u0471","\u0472":"\u0473","\u0474":"\u0475","\u0476":"\u0477","\u0478":"\u0479",
		"\u047a":"\u047b","\u047c":"\u047d","\u047e":"\u047f","\u0480":"\u0481","\u048c":"\u048d","\u048e":"\u048f","\u0490":"\u0491","\u0492":"\u0493","\u0494":"\u0495","\u0496":"\u0497","\u0498":"\u0499","\u049a":"\u049b","\u049c":"\u049d","\u049e":"\u049f","\u04a0":"\u04a1","\u04a2":"\u04a3","\u04a4":"\u04a5","\u04a6":"\u04a7","\u04a8":"\u04a9","\u04aa":"\u04ab","\u04ac":"\u04ad","\u04ae":"\u04af","\u04b0":"\u04b1","\u04b2":"\u04b3","\u04b4":"\u04b5","\u04b6":"\u04b7","\u04b8":"\u04b9","\u04ba":"\u04bb","\u04bc":"\u04bd","\u04be":"\u04bf","\u04c1":"\u04c2","\u04c3":"\u04c4",
		"\u04c7":"\u04c8","\u04cb":"\u04cc","\u04d0":"\u04d1","\u04d2":"\u04d3","\u04d4":"\u04d5","\u04d6":"\u04d7","\u04d8":"\u04d9","\u04da":"\u04db","\u04dc":"\u04dd","\u04de":"\u04df","\u04e0":"\u04e1","\u04e2":"\u04e3","\u04e4":"\u04e5","\u04e6":"\u04e7","\u04e8":"\u04e9","\u04ea":"\u04eb","\u04ec":"\u04ed","\u04ee":"\u04ef","\u04f0":"\u04f1","\u04f2":"\u04f3","\u04f4":"\u04f5","\u04f8":"\u04f9","\u0531":"\u0561","\u0532":"\u0562","\u0533":"\u0563","\u0534":"\u0564","\u0535":"\u0565","\u0536":"\u0566","\u0537":"\u0567","\u0538":"\u0568","\u0539":"\u0569","\u053a":"\u056a",
		"\u053b":"\u056b","\u053c":"\u056c","\u053d":"\u056d","\u053e":"\u056e","\u053f":"\u056f","\u0540":"\u0570","\u0541":"\u0571","\u0542":"\u0572","\u0543":"\u0573","\u0544":"\u0574","\u0545":"\u0575","\u0546":"\u0576","\u0547":"\u0577","\u0548":"\u0578","\u0549":"\u0579","\u054a":"\u057a","\u054b":"\u057b","\u054c":"\u057c","\u054d":"\u057d","\u054e":"\u057e","\u054f":"\u057f","\u0550":"\u0580","\u0551":"\u0581","\u0552":"\u0582","\u0553":"\u0583","\u0554":"\u0584","\u0555":"\u0585","\u0556":"\u0586","\u1e00":"\u1e01","\u1e02":"\u1e03","\u1e04":"\u1e05","\u1e06":"\u1e07",
		"\u1e08":"\u1e09","\u1e0a":"\u1e0b","\u1e0c":"\u1e0d","\u1e0e":"\u1e0f","\u1e10":"\u1e11","\u1e12":"\u1e13","\u1e14":"\u1e15","\u1e16":"\u1e17","\u1e18":"\u1e19","\u1e1a":"\u1e1b","\u1e1c":"\u1e1d","\u1e1e":"\u1e1f","\u1e20":"\u1e21","\u1e22":"\u1e23","\u1e24":"\u1e25","\u1e26":"\u1e27","\u1e28":"\u1e29","\u1e2a":"\u1e2b","\u1e2c":"\u1e2d","\u1e2e":"\u1e2f","\u1e30":"\u1e31","\u1e32":"\u1e33","\u1e34":"\u1e35","\u1e36":"\u1e37","\u1e38":"\u1e39","\u1e3a":"\u1e3b","\u1e3c":"\u1e3d","\u1e3e":"\u1e3f","\u1e40":"\u1e41","\u1e42":"\u1e43","\u1e44":"\u1e45","\u1e46":"\u1e47",
		"\u1e48":"\u1e49","\u1e4a":"\u1e4b","\u1e4c":"\u1e4d","\u1e4e":"\u1e4f","\u1e50":"\u1e51","\u1e52":"\u1e53","\u1e54":"\u1e55","\u1e56":"\u1e57","\u1e58":"\u1e59","\u1e5a":"\u1e5b","\u1e5c":"\u1e5d","\u1e5e":"\u1e5f","\u1e60":"\u1e61","\u1e62":"\u1e63","\u1e64":"\u1e65","\u1e66":"\u1e67","\u1e68":"\u1e69","\u1e6a":"\u1e6b","\u1e6c":"\u1e6d","\u1e6e":"\u1e6f","\u1e70":"\u1e71","\u1e72":"\u1e73","\u1e74":"\u1e75","\u1e76":"\u1e77","\u1e78":"\u1e79","\u1e7a":"\u1e7b","\u1e7c":"\u1e7d","\u1e7e":"\u1e7f","\u1e80":"\u1e81","\u1e82":"\u1e83","\u1e84":"\u1e85","\u1e86":"\u1e87",
		"\u1e88":"\u1e89","\u1e8a":"\u1e8b","\u1e8c":"\u1e8d","\u1e8e":"\u1e8f","\u1e90":"\u1e91","\u1e92":"\u1e93","\u1e94":"\u1e95","\u1ea0":"\u1ea1","\u1ea2":"\u1ea3","\u1ea4":"\u1ea5","\u1ea6":"\u1ea7","\u1ea8":"\u1ea9","\u1eaa":"\u1eab","\u1eac":"\u1ead","\u1eae":"\u1eaf","\u1eb0":"\u1eb1","\u1eb2":"\u1eb3","\u1eb4":"\u1eb5","\u1eb6":"\u1eb7","\u1eb8":"\u1eb9","\u1eba":"\u1ebb","\u1ebc":"\u1ebd","\u1ebe":"\u1ebf","\u1ec0":"\u1ec1","\u1ec2":"\u1ec3","\u1ec4":"\u1ec5","\u1ec6":"\u1ec7","\u1ec8":"\u1ec9","\u1eca":"\u1ecb","\u1ecc":"\u1ecd","\u1ece":"\u1ecf","\u1ed0":"\u1ed1",
		"\u1ed2":"\u1ed3","\u1ed4":"\u1ed5","\u1ed6":"\u1ed7","\u1ed8":"\u1ed9","\u1eda":"\u1edb","\u1edc":"\u1edd","\u1ede":"\u1edf","\u1ee0":"\u1ee1","\u1ee2":"\u1ee3","\u1ee4":"\u1ee5","\u1ee6":"\u1ee7","\u1ee8":"\u1ee9","\u1eea":"\u1eeb","\u1eec":"\u1eed","\u1eee":"\u1eef","\u1ef0":"\u1ef1","\u1ef2":"\u1ef3","\u1ef4":"\u1ef5","\u1ef6":"\u1ef7","\u1ef8":"\u1ef9","\u1f08":"\u1f00","\u1f09":"\u1f01","\u1f0a":"\u1f02","\u1f0b":"\u1f03","\u1f0c":"\u1f04","\u1f0d":"\u1f05","\u1f0e":"\u1f06","\u1f0f":"\u1f07","\u1f18":"\u1f10","\u1f19":"\u1f11","\u1f1a":"\u1f12","\u1f1b":"\u1f13",
		"\u1f1c":"\u1f14","\u1f1d":"\u1f15","\u1f28":"\u1f20","\u1f29":"\u1f21","\u1f2a":"\u1f22","\u1f2b":"\u1f23","\u1f2c":"\u1f24","\u1f2d":"\u1f25","\u1f2e":"\u1f26","\u1f2f":"\u1f27","\u1f38":"\u1f30","\u1f39":"\u1f31","\u1f3a":"\u1f32","\u1f3b":"\u1f33","\u1f3c":"\u1f34","\u1f3d":"\u1f35","\u1f3e":"\u1f36","\u1f3f":"\u1f37","\u1f48":"\u1f40","\u1f49":"\u1f41","\u1f4a":"\u1f42","\u1f4b":"\u1f43","\u1f4c":"\u1f44","\u1f4d":"\u1f45","\u1f59":"\u1f51","\u1f5b":"\u1f53","\u1f5d":"\u1f55","\u1f5f":"\u1f57","\u1f68":"\u1f60","\u1f69":"\u1f61","\u1f6a":"\u1f62","\u1f6b":"\u1f63",
		"\u1f6c":"\u1f64","\u1f6d":"\u1f65","\u1f6e":"\u1f66","\u1f6f":"\u1f67","\u1fb8":"\u1fb0","\u1fb9":"\u1fb1","\u1fba":"\u1f70","\u1fbb":"\u1f71","\u1fc8":"\u1f72","\u1fc9":"\u1f73","\u1fca":"\u1f74","\u1fcb":"\u1f75","\u1fd8":"\u1fd0","\u1fd9":"\u1fd1","\u1fda":"\u1f76","\u1fdb":"\u1f77","\u1fe8":"\u1fe0","\u1fe9":"\u1fe1","\u1fea":"\u1f7a","\u1feb":"\u1f7b","\u1fec":"\u1fe5","\u1ff8":"\u1f78","\u1ff9":"\u1f79","\u1ffa":"\u1f7c","\u1ffb":"\u1f7d","\u2160":"\u2170","\u2161":"\u2171","\u2162":"\u2172","\u2163":"\u2173","\u2164":"\u2174","\u2165":"\u2175","\u2166":"\u2176",
		"\u2167":"\u2177","\u2168":"\u2178","\u2169":"\u2179","\u216a":"\u217a","\u216b":"\u217b","\u216c":"\u217c","\u216d":"\u217d","\u216e":"\u217e","\u216f":"\u217f","\u24b6":"\u24d0","\u24b7":"\u24d1","\u24b8":"\u24d2","\u24b9":"\u24d3","\u24ba":"\u24d4","\u24bb":"\u24d5","\u24bc":"\u24d6","\u24bd":"\u24d7","\u24be":"\u24d8","\u24bf":"\u24d9","\u24c0":"\u24da","\u24c1":"\u24db","\u24c2":"\u24dc","\u24c3":"\u24dd","\u24c4":"\u24de","\u24c5":"\u24df","\u24c6":"\u24e0","\u24c7":"\u24e1","\u24c8":"\u24e2","\u24c9":"\u24e3","\u24ca":"\u24e4","\u24cb":"\u24e5","\u24cc":"\u24e6",
		"\u24cd":"\u24e7","\u24ce":"\u24e8","\u24cf":"\u24e9","\uff21":"\uff41","\uff22":"\uff42","\uff23":"\uff43","\uff24":"\uff44","\uff25":"\uff45","\uff26":"\uff46","\uff27":"\uff47","\uff28":"\uff48","\uff29":"\uff49","\uff2a":"\uff4a","\uff2b":"\uff4b","\uff2c":"\uff4c","\uff2d":"\uff4d","\uff2e":"\uff4e","\uff2f":"\uff4f","\uff30":"\uff50","\uff31":"\uff51","\uff32":"\uff52","\uff33":"\uff53","\uff34":"\uff54","\uff35":"\uff55","\uff36":"\uff56","\uff37":"\uff57","\uff38":"\uff58","\uff39":"\uff59","\uff3a":"\uff5a"
	};
// end generated: case tables
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
//#if ES5
// 15.5.4: step 1 of every method below is CheckObjectCoercible(this), which only strict code can ever fail,
// so the whole table is strict. The entries keep their indentation, this wrapper being invisible to the ES3 source.
(function() {
"use strict";
//#endif
defineProperties(String.prototype, { dontEnum: true }, {
	constructor: String,
	charAt: unconstructable(function charAt(pos) {
//#if ES5
		if (this == null) throw typeError("String.prototype.charAt called on null or undefined");
//#endif
		var s;
		return (((pos = int(pos)) < 0 || pos >= (s = str(this)).length) ? '' : s[pos]);
	}),
	charCodeAt: unconstructable(function charCodeAt(pos) {
//#if ES5
		if (this == null) throw typeError("String.prototype.charCodeAt called on null or undefined");
//#endif
		return $charCodeAt(str(this), +pos);
	}),
	concat: unconstructable(function concat(string1) {
//#if ES5
		if (this == null) throw typeError("String.prototype.concat called on null or undefined");
//#endif
		var args, n = (args = arguments).length, s = str(this);
		for (var i = 0; i < n; ++i) s += str(args[i]);
		return s;
	}),
	indexOf: unconstructable(function indexOf(searchString) { // .length should be 1
//#if ES5
		if (this == null) throw typeError("String.prototype.indexOf called on null or undefined");
//#endif
		var s, i, e = (s = str(this)).length - (searchString = str(searchString)).length, pos = arguments[1];
		if ((i = int(pos)) < 0) i = 0;
		for (; i <= e; ++i) if ($match(s, i, searchString)) return i;
		return -1;
	}),
	lastIndexOf: unconstructable(function lastIndexOf(searchString) { // .length should be 1
//#if ES5
		if (this == null) throw typeError("String.prototype.lastIndexOf called on null or undefined");
//#endif
		var s, i, e = (s = str(this)).length - (searchString = str(searchString)).length, pos = arguments[1];
		if ($isNaN(pos = +pos) || (i = int(pos)) > e) i = e;
		for (; i >= 0; --i) if ($match(s, i, searchString)) return i;
		return -1;
	}),
	localeCompare: unconstructable(function localeCompare(that) {
//#if ES5
		if (this == null) throw typeError("String.prototype.localeCompare called on null or undefined");
//#endif
		var me, him;
		return ((me = str(this)) === (him = str(that)) ? 0 : (me < him ? -1 : 1));
	}),
	match: unconstructable(function match(regexp) {
//#if ES5
		if (this == null) throw typeError("String.prototype.match called on null or undefined");
//#endif
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
//#if ES5
		if (this == null) throw typeError("String.prototype.replace called on null or undefined");
//#endif
		var s, sLength = (s = str(this)).length, matches, i, p, t, l, e, replaceFunction = replaceValue, replacementValue;
		function makeStringReplacer(r) {
			for (var scan = r.length; --scan >= 0 && r[scan] != '$';);
			return (scan < 0 ? function() { return r; } : function(m) {
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
								n = ch - '0';
								if ((ch2 = r[p + 1]) && ch2 >= '0' && ch2 <= '9') {
									var twoDigit = n * 10 + (ch2 - '0');
									if (twoDigit >= 1 && twoDigit < arguments.length - 2) {
										t += ((c = arguments[twoDigit]) === void 0 ? '' : c);
										++p;
										break;
									}
								}
								if (n >= 1 && n < arguments.length - 2) {
									t += ((c = arguments[n]) === void 0 ? '' : c);
									break;
								}
							}
							t += '$' + ch;
							break;
						}
					}
				}
				return t;
			});
		}
		if (typeof replaceFunction !== "function") {
			replacementValue = replaceValue;
			replaceFunction = null;
		}
		if ($getInternalProperty(searchValue, "class") === "RegExp") {
			if (!replaceFunction) replaceFunction = makeStringReplacer(str(replacementValue));
			p = 0;
			t = new StringBuilder;
			if (searchValue.global) searchValue.lastIndex = 0;
			while (matches = regExpExecMethod(searchValue, s)) {
				matches[i = matches.length] = matches.index;
				matches[i + 1] = s;
				t.append($sub(s, p, matches.index) + str($callWithArgs(replaceFunction, void 0, matches)));
				p = matches.index + (l = matches[0].length);
				if (!searchValue.global) break;
				if (l === 0) ++searchValue.lastIndex;
			}
			return (t.append($sub(s, p, sLength))).build();
		} else {
			t = str(searchValue);
			if (!replaceFunction) replaceFunction = makeStringReplacer(str(replacementValue));
			e = sLength - (l = t.length);
			for (var p = 0; !$match(s, p, t); ++p) if (p >= e) return s;
			return $sub(s, 0, p) + str($callWithArgs(replaceFunction, void 0, [ t, p, s ])) + $sub(s, p + l, sLength);
		}
	}),
	search: unconstructable(function search(regexp) {
//#if ES5
		if (this == null) throw typeError("String.prototype.search called on null or undefined");
//#endif
		if ($getInternalProperty(regexp, "class") !== "RegExp") regexp = new RegExp(regexp);
		var s, len = (s = str(this)).length, f = $getInternalProperty(regexp, "value");
		for (var i = 0; i <= len; ++i) if (f(s, i)) return i;
		return -1;
	}),
	slice: unconstructable(function slice(start, end) {
//#if ES5
		if (this == null) throw typeError("String.prototype.slice called on null or undefined");
//#endif
		var s = str(this);
		if ((start = int(start)) < 0) start += s.length;
		if (end === void 0) end = $Infinity;
		else if ((end = int(end)) < 0) end += s.length;
		return $sub(s, start, end);
	}),
	split: unconstructable(function split(separator, limit) {
//#if ES5
		if (this == null) throw typeError("String.prototype.split called on null or undefined");
//#endif
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
//#if ES5
		if (this == null) throw typeError("String.prototype.substr called on null or undefined");
//#endif
		var s = str(this);
		if ((start = int(start)) < 0) start = s.length + start;
		return $sub(s, start, (length === void 0 ? $Infinity : start + int(length)));
	}),
	substring: unconstructable(function substring(start, end) {
//#if ES5
		if (this == null) throw typeError("String.prototype.substring called on null or undefined");
//#endif
		start = int(start);
		if (end === void 0) end = $Infinity;
		else if ((end = int(end)) < start) {
			var swap = start;
			start = end;
			end = swap;
		}
		return $sub(str(this), start, end);
	}),
//#if !ES5
	toUpperCase: unconstructable(function toUpperCase() { return toUpper(this) }),
	toLocaleUpperCase: unconstructable(function toLocaleUpperCase() { return toUpper(this) }),
	toLowerCase: unconstructable(function toLowerCase() { return toLower(this) }),
	toLocaleLowerCase: unconstructable(function toLocaleLowerCase() { return toLower(this) }),
//#else
	// 15.5.4.16-19. The check goes on the receiver rather than inside toUpper / toLower, so that each of the four
	// names itself in the message; they are two pairs of synonyms, the locale forms deferring to the same tables.
	toUpperCase: unconstructable(function toUpperCase() {
		if (this == null) throw typeError("String.prototype.toUpperCase called on null or undefined");
		return toUpper(this);
	}),
	toLocaleUpperCase: unconstructable(function toLocaleUpperCase() {
		if (this == null) throw typeError("String.prototype.toLocaleUpperCase called on null or undefined");
		return toUpper(this);
	}),
	toLowerCase: unconstructable(function toLowerCase() {
		if (this == null) throw typeError("String.prototype.toLowerCase called on null or undefined");
		return toLower(this);
	}),
	toLocaleLowerCase: unconstructable(function toLocaleLowerCase() {
		if (this == null) throw typeError("String.prototype.toLocaleLowerCase called on null or undefined");
		return toLower(this);
	}),
//#endif
//#if !ES5
	valueOf: unconstructable(function valueOf() {
		checkClass(this, "String", "valueOf");
		return $getInternalProperty(this, "value");
	}),
	toString: unconstructable(function toString() {
		checkClass(this, "String", "toString");
		return $getInternalProperty(this, "value");
	})
//#else
	valueOf: unconstructable(function valueOf() { return thisStringValue(this, "valueOf") }),
	toString: unconstructable(function toString() { return thisStringValue(this, "toString") })
//#endif
});
//#if ES5
})();
//#endif

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
//#if ES5
// 15.4.4: the generic methods take ToObject(this) as step 1 and the ES5 mutators store with Throw = true, both
// of which need strict code. The entries keep their indentation, this wrapper being invisible to the ES3 source.
(function() {
"use strict";
//#endif
defineProperties(Array.prototype, { dontEnum: true }, {
	constructor: Array,
//#if !ES5
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
//#else
	/*
		15.4.4.4-5, .10 and .3: ToObject(this) is step 1 and the algorithm reads *that* object, not the this value.
		A strict caller passes a primitive receiver verbatim (10.4.3), so concat would otherwise push the primitive
		where 15.4.4.4 step 5.b wants the object, and slice's `i in o` would reject it outright. Same split, same
		reason, for join and toLocaleString below.
	*/
	concat: unconstructable(function concat(item1) {
		var a = [ ], argv, argc = (argv = arguments).length, n = 0, v = toObject(this, "concat");
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
//#endif
//#if !ES5
	join: unconstructable(function join(separator) {
		var s = new StringBuilder, s2, len = uint32(this.length);
		separator = (separator === void 0 ? ',' : str(separator));
		for (var i = 0; i < len; ++i) {
			if (i > 0) s.append(separator);
			if ((s2 = this[i]) != null) s.append(str(s2));
		}
		return s.build();
	}),
//#else
	join: unconstructable(function join(separator) {
		var o = toObject(this, "join"), s = new StringBuilder, s2, len = uint32(o.length);
		separator = (separator === void 0 ? ',' : str(separator));
		for (var i = 0; i < len; ++i) {
			if (i > 0) s.append(separator);
			if ((s2 = o[i]) != null) s.append(str(s2));
		}
		return s.build();
	}),
//#endif
//#if !ES5
	pop: unconstructable(function pop() {
		var len, result = void 0;
		if (len = uint32(this.length)) {
			result = this[--len];
			delete this[len];
		}
		this.length = len;
		return result;
	}),
	push: unconstructable(function push(item) {
		var len, argv, offset, argc = (argv = arguments).length, end = (offset = uint32(len = +this.length)) + argc;
		for (var i = 0; i < argc; ++i) this[offset + i] = argv[i];
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
		var len, elementZero = void 0;
		if (len = uint32(this.length)) {
			elementZero = this[0];
			for (var i = 1; i < len; ++i) {
				if (i in this) this[i - 1] = this[i];
				else delete this[i - 1];
			}
			delete this[--len];
		}
		this.length = len;
		return elementZero;
	}),
//#else
	/*
		15.4.4.6-13, the mutators, restated for ES5. The algorithms are the ones above; what the ES5 editions add is
		Throw = true on every [[Put]] and [[Delete]], and being strict IS that flag, 8.7.2 and 11.4.1 raising a refused
		store into the TypeError the spec asks for. The bodies differ beyond that, which is why these are whole
		alternative entries: an empty array still gets its length store, and splice reads deleteCount through
		`arguments` rather than as a parameter.
	*/
	// 4.a in both pop and shift: an empty array still gets the length store, so a read-only length throws there too.
	pop: unconstructable(function pop() {
		var o = toObject(this, "pop"), len = o.length >>> 0, element;
		if (len !== 0) {
			element = o[--len];
			delete o[len];
		}
		o.length = len;
		return element;
	}),
	push: unconstructable(function push(item) {
		var o = toObject(this, "push"), n = o.length >>> 0, argv = arguments;
		for (var i = 0; i < argv.length; ++i) {
			o[n] = argv[i];
			++n;
		}
		o.length = n;
		return n;
	}),
	reverse: unconstructable(function reverse() {
		var o = toObject(this, "reverse"), len = o.length >>> 0, middle = $floor(len / 2), last = len - 1, lower = 0;
		for (; lower !== middle; ++lower) {
			var upper = last - lower;
			var lowerValue = o[lower], upperValue = o[upper];			// 6.4 and 6.5 read both before either is stored
			var lowerExists = lower in o, upperExists = upper in o;
			if (lowerExists || upperExists) {							// 6.11: with neither there is nothing to do
				if (upperExists) o[lower] = upperValue; else delete o[lower];
				if (lowerExists) o[upper] = lowerValue; else delete o[upper];
			}
		}
		return o;
	}),
	shift: unconstructable(function shift() {
		var o = toObject(this, "shift"), len = o.length >>> 0, first, k;
		if (len !== 0) {
			first = o[0];
			for (k = 1; k < len; ++k) {
				if (k in o) o[k - 1] = o[k];
				else delete o[k - 1];
			}
			delete o[--len];
		}
		o.length = len;
		return first;
	}),
//#endif
//#if !ES5
	slice: unconstructable(function slice(start, end) {
		var a = [ ], len = uint32(this.length);
		if ((start = int(start)) < 0) { start += len; if (start < 0) start = 0; }
		if (end === void 0 || (end = int(end)) > len) end = len;
		else if (end < 0) end += len;
		for (var i = start, j = 0; i < end; ++i, ++j) if (i in this) a[j] = this[i];
		a.length = j;
		return a;
	}),
//#else
	slice: unconstructable(function slice(start, end) {
		var o = toObject(this, "slice"), a = [ ], len = uint32(o.length);
		if ((start = int(start)) < 0) { start += len; if (start < 0) start = 0; }
		if (end === void 0 || (end = int(end)) > len) end = len;
		else if (end < 0) end += len;
		for (var i = start, j = 0; i < end; ++i, ++j) if (i in o) a[j] = o[i];
		a.length = j;
		return a;
	}),
//#endif
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
				else { var v = +comparefn(a, b); return (v === v ? v : 0); } // NaN result must be treated as +0 (else qsort can loop forever)
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
//#if !ES5
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
//#else
	// The `length` of splice is 2, so both are formal parameters even though deleteCount is read through
	// `arguments`.
	splice: unconstructable(function splice(start, deleteCount) {
		var o = toObject(this, "splice"), a = [ ], len = o.length >>> 0, argv = arguments, argc = argv.length, k, n, to;
		if ((start = int(start)) < 0) { if ((start += len) < 0) start = 0; }
		else if (start > len) start = len;
		/*
			7: min(max(ToInteger(deleteCount), 0), len - start). Taken literally that makes a.splice(i) delete
			nothing, since ToInteger(undefined) is 0; no engine has ever done that and ES2015 rewrote the step to
			say len - start, which is what the entry above does too, so es5 keeps it. With no arguments at all
			nothing is deleted either.
		*/
		var count = (argc === 0 ? 0 : argc === 1 ? len - start : int(deleteCount));
		if (count < 0) count = 0;
		else if (count > len - start) count = len - start;
		for (k = 0; k < count; ++k) if (start + k in o) a[k] = o[start + k];
		a.length = count;	// 15.4.4.12 omits this step, but every edition since sets it, and so does the entry above
		// 12 and 13 are one loop: the tail shifts by `move`, walked away from the direction it is overwriting. Only a
		// shrink leaves a stale tail above the new length, and only then is the trailing delete loop non-empty.
		var itemCount = (argc > 2 ? argc - 2 : 0), move = itemCount - count, tail = len - count, step = (move < 0 ? 1 : -1);
		if (move !== 0) {
			for (n = tail - start, k = (move < 0 ? start : tail - 1); n-- > 0; k += step) {
				to = k + itemCount;
				if (k + count in o) o[to] = o[k + count]; else delete o[to];
			}
			for (k = len; k > len + move; --k) delete o[k - 1];
		}
		for (k = 0; k < itemCount; ++k) o[start + k] = argv[k + 2];
		o.length = len + move;
		return a;
	}),
//#endif
//#if !ES5
	toLocaleString: unconstructable(function toLocaleString() {
		var len = uint32(this.length), builder = new StringBuilder, element;
		for (var k = 0; k < len; ++k) {
			if (k > 0) builder.append(',');
			if ((element = this[k]) != null) builder.append(str(Object(element).toLocaleString()));
		}
		return builder.build();
	}),
//#else
	toLocaleString: unconstructable(function toLocaleString() {
		var o = toObject(this, "toLocaleString"), len = uint32(o.length), builder = new StringBuilder, element;
		for (var k = 0; k < len; ++k) {
			if (k > 0) builder.append(',');
			if ((element = o[k]) != null) builder.append(str(Object(element).toLocaleString()));
		}
		return builder.build();
	}),
//#endif
	toString: unconstructable(function toString() {
		checkClass(this, "Array", "toString");
		return this.join();
	}),
//#if !ES5
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
//#else
	unshift: unconstructable(function unshift(item) {
		var o = toObject(this, "unshift"), len = o.length >>> 0, argv = arguments, argc = argv.length, k, to;
		for (k = len; k-- > 0; ) {
			to = k + argc;
			if (k in o) o[to] = o[k]; else delete o[to];
		}
		for (k = 0; k < argc; ++k) o[k] = argv[k];
		return (o.length = len + argc);
	})
//#endif
});
//#if ES5
})();
//#endif

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
	if ($getInternalProperty(object, "class") !== "Date" || object === support.prototypes.Date) {
		throw typeError("this is not a Date object");
	}
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
function timeClipLocal(z) { return timeClip(fromLocalTime(z)); }	// 15.9.3.1 (12): TimeClip(UTC(t)) - convert first, so a local value past the edge whose UTC lands inside survives

function dateFromEpoch(z) {
	// The era arithmetic below runs through int(), and ToInteger(NaN) is 0 by 9.4, so an invalid date came out of
	// here as year 0 and month 2 where 15.9.5.10 and 15.9.5.12 step 2 want NaN. The day already fell out NaN.
	if ($isNaN(z)) return [ z, z, z ];
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
	var argc = arguments.length, y, m, d, h, M, s, milli;
	return (!$isFinite(y = +year)
			|| !$isFinite(m = +month)
			|| !$isFinite(d = (argc > 2 ? +date : 1))
			|| !$isFinite(h = (argc > 3 ? +hours : 0))
			|| !$isFinite(M = (argc > 4 ? +minutes : 0))
			|| !$isFinite(s = (argc > 5 ? +seconds : 0))
			|| !$isFinite(milli = (argc > 6 ? +ms : 0)))
			? $NaN : epochFromDate(int(y) + (0 <= y && y <= 99 ? 1900 : 0), int(m), int(d))
			+ epochFromTime(int(h), int(M), int(s), int(milli));
}

function isoDate(d) {
	var z;
	return $isNaN(z = getDateValue(d)) ? null : epochToDateString(z) + "T" + epochToTimeString(z, true) + "Z";
}

//#if ES5
/*
	15.9.4.2 wants NaN for a String that is not a valid instance of the 15.9.1.15 format, out of bounds values
	counting as illegal alongside syntax errors. The permitted fall back to implementation specific formats is not
	taken, bar the space and lowercase t separators toString and toUTCString print. parse runs this first and then
	only ever sees a well formed string, which is why it can go on swallowing a failed readPart. ES3 dictates no
	format at all, so the es3 build keeps its tolerant scan; see tests/es3only/dateFormatsLoose.io.
*/
function isDateTimeString(s) {
	var i = 0, c;
	function field(len, lo, hi) {
		var v = 0, e = i + len;
		for (; i < e; ++i) if ("0" <= (c = s[i]) && c <= "9") v = v * 10 + (+c); else return false;
		return (lo <= v && v <= hi);
	}
	if ((c = s[0]) === "+" || c === "-") { if (++i, !field(6, 0, 999999)) return false }
	else if (!field(4, 0, 9999)) return false;
	if (s[i] === "-") {
		if (++i, !field(2, 1, 12)) return false;
		if (s[i] === "-" && (++i, !field(2, 1, 31))) return false;
	}
	if ((c = s[i]) === "T" || c === "t" || c === ' ') {
		if (++i, !field(2, 0, 24) || s[i] !== ":" || (++i, !field(2, 0, 59))) return false;
		if (s[i] === ":") {
			if (++i, !field(2, 0, 59)) return false;
			if (s[i] === "." && (++i, !field(3, 0, 999))) return false;
		}
		if ((c = s[i]) === "Z" || c === "z") ++i;
		else if ((c === "+" || c === "-")
				&& (++i, !field(2, 0, 24) || s[i] !== ":" || (++i, !field(2, 0, 59)))) return false;
	}
	return s[i] === void 0;
}
//#endif

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
		// 15.9.4.2 opens by applying ToString, and reading s a character at a time only looks like it: a String
		// object indexes the same way, but anything else silently misses, and undefined and null threw outright.
		s = str(s);
//#if ES5
		if (!isDateTimeString(s)) return $NaN;
//#endif
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

//#if ES5
		// 15.9.1.15 makes an absent offset "Z": pinning tz defaults to UTC and suppresses the local shift below. The
		// space form is ours, is what toString prints, and stays local. docs/specs/ES5.1 vs modern divergences.md.
		if (ch !== ' ') tz = 0;
//#endif
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
		return timeClip($callWithArgs(makeDateTime, null, arguments));
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
		// 15.9.4.2 wants Date.parse(x.toUTCString()) back at x.valueOf(), and without the Z this reads as local.
		return (epochToDateString(z) + ' ' + epochToTimeString(z) + 'Z')
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
//#if ES5
	// B.2.4, informative. Its step 2 NaN now falls out of dateFromEpoch, as it does for the getters either side.
	getYear: unconstructable(function getYear() { return dateFromEpoch(getLocalDateValue(this))[0] - 1900 }),
//#endif
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
	setTime: unconstructable(function setTime(time) { return setDateValue(this, timeClip(+time)) }),
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
//#if ES5
	// B.2.5, informative. Step 1 reads the time value before step 2 converts `year`, so the class check comes first.
	// Steps 5 and 6 are setFullYear's, the only difference being step 4 folding 0..99 into the 1900s.
	setYear: unconstructable(function setYear(year) {
		var t = getDateValue(this), y = +year, v;
		if ($isNaN(y)) return setDateValue(this, $NaN);		// 3: an unusable year clears the date rather than clipping
		if (0 <= (v = int(y)) && v <= 99) y = v + 1900;
		return setDateValue(this, timeClipLocal(setDateParts($isNaN(t) ? 0 : toLocalTime(t), 0, [ y ])));
	})
//#endif
//#if !ES5
	// TODO: this isn't as generic as in the ES5 spec, e.g. not converting this to object, not going via the objects reassignable `toISOString`.
	toJSON: unconstructable(function toJSON() { return isoDate(this); })
//#endif
});
//#if ES5

// B.2.6, informative: "the same Function object that is the initial value of Date.prototype.toUTCString", so it is
// a second define rather than a table entry, the table having no name for a property it is itself creating.
defineProperties(Date.prototype, { dontEnum: true }, { toGMTString: Date.prototype.toUTCString });
//#endif

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
	setupCharClass(NEWLINE_CHAR, "\n\r\u2028\u2029");
	setupCharClass(SPACE_CHAR, WHITE_SPACES);
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
									, backMatchCode = "$match(s," + positionToCode(quantity ? 0 : offset) + ",$sub(s, c" + n + ",c" + (n + 1) + "))";
							tail = compileTerms(0, junction);
							var tailName = 't' + (++functionCounter);
							addFunction(tailName, "return " + tail);
							return quantity ? quantify(code, offset, backMatchCode, tailName + '(' + positionToCode(0) + ')', quantity, stepSize)
									: and(code, '(c' + n + "<c" + (n + 1) + " ? " + and(backMatchCode, tailName + '(' + positionToCode(offset) + '+'
									+ stepSize + ')') + " : " + tailName + '(' + positionToCode(offset) + "))");
						} else if ((c = s[p]) === 'b' || c === 'B') {
							++p;
							code = and(code, (c === 'b' ? "!!((CC[s[" : "!((CC[s[") + positionToCode(offset - 1) + "]]^CC[s[" + positionToCode(offset)
									+ "]])&" + WORD_CHAR + ')');
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
	string = str(string);
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

//#if !ES5
defineProperties(RegExp, { dontEnum: true, readOnly: true, dontDelete: true }, { prototype: regExpPrototype = RegExp.prototype });
//#else
/*
	15.10.6: the prototype is itself a regular expression object, its [[Class]] "RegExp" and its data properties
	those of `new RegExp()`, where distinctConstructor hands out a plain object. Its matcher is written out rather
	than compiled, compileRegExp going through evalThere and the globals table binding `eval` further down. `[p, p]`
	is what compileRegExp emits for the empty pattern, so exec and test answer as 15.10.6.2 and .3 require.
*/
regExpPrototype = support.createWrapper("RegExp", function (s, p) { return [p, p] }
		, support.prototypes.Object);
defineProperties(regExpPrototype, { dontEnum: true, readOnly: true, dontDelete: true }
		, { global: false, ignoreCase: false, multiline: false, source: '' });
defineProperties(regExpPrototype, { dontEnum: true, dontDelete: true }, { lastIndex: 0 });
defineProperties(regExpPrototype, { dontEnum: true }, { constructor: RegExp });
defineProperties(RegExp, { dontEnum: true, readOnly: true, dontDelete: true }, { prototype: regExpPrototype });
//#endif
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
		if (((radix = int32(radix)) === 0 || radix === 16) && string[i] === '0'
				&& (string[i + 1] === 'x' || string[i + 1] === 'X')) {
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

//#if ES5
(function () {	// 15.1.3: URI handling - Encode and Decode as written, over the exact UTF-8 table.
	var pic = PARSE_INT_CHARS, $fromCharCode = support.fromCharCode;
	function memberSet(chars) {
		for (var t = { }, i = chars.length - 1; i >= 0; --i) t[chars[i]] = true;
		return t;
	}
	var RESERVED, UNESCAPED, FULL_URI, NONE = { };
	function createUriTables() {	// 162 interpreted inserts, so deferred to first use the way createCaseTables is
		var RESERVED_CHARS = ";/?:@&=+$,#", UNESCAPED_CHARS =
				"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-_.!~*'()";
		RESERVED = memberSet(RESERVED_CHARS);
		UNESCAPED = memberSet(UNESCAPED_CHARS);
		FULL_URI = memberSet(UNESCAPED_CHARS + RESERVED_CHARS);
	}
	function hex(b) { return '%' + ALPHA_DIGITS_UPPER[b >> 4] + ALPHA_DIGITS_UPPER[b & 15]; }
	function octet(s, i) {	// the byte spelled by the two hex digits after a '%', or -1
		var h = pic[s[i + 1]], l = pic[s[i + 2]];	// null for white space, undefined past the end: != null takes both
		return (h != null && l != null && h < 16 && l < 16 ? (h << 4) | l : -1);
	}
	function encode(s, keep) {	// unescaped characters pass in runs; everything else UTF-8s into %XX triplets
		s = str(s);
		for (var r = null, i = 0, j = 0, n = s.length; i < n; ++i) {
			if (!keep[s[i]]) {
				if (r === null) r = new StringBuilder;	// only once an escape is due: an unescaped string returns untouched
				r.append($sub(s, j, i));
				var v = $charCodeAt(s, i);
				if (v >= 0xDC00 && v <= 0xDFFF) throw uriError("URI malformed");
				if (v >= 0xD800 && v <= 0xDBFF) {	// a pair encodes as one code point, a lone half never (step 4.d-e)
					var w = (++i < n ? $charCodeAt(s, i) : 0);
					if (w < 0xDC00 || w > 0xDFFF) throw uriError("URI malformed");
					v = (v - 0xD800) * 0x400 + w - 0xDC00 + 0x10000;
				}
				r.append(v < 0x80 ? hex(v)
						: v < 0x800 ? hex(0xC0 | (v >> 6)) + hex(0x80 | (v & 63))
						: v < 0x10000 ? hex(0xE0 | (v >> 12)) + hex(0x80 | ((v >> 6) & 63)) + hex(0x80 | (v & 63))
						: hex(0xF0 | (v >> 18)) + hex(0x80 | ((v >> 12) & 63)) + hex(0x80 | ((v >> 6) & 63)) + hex(0x80 | (v & 63)));
				j = i + 1;
			}
		}
		return (r === null ? s : r.append($sub(s, j, n)).build());
	}
	function decode(s, keep) {	// an escaped character in `keep` stays escaped (15.1.3.1 reservedURISet)
		s = str(s);
		for (var r = null, i = 0, j = 0, n = s.length; i < n; ++i) {
			if (s[i] === '%') {
				if (r === null) r = new StringBuilder;
				r.append($sub(s, j, i));
				var start = i, b = octet(s, i), c;
				if (b < 0) throw uriError("URI malformed");
				i += 2;
				if (b < 0x80) {
					c = $fromCharCode(b);
					r.append(keep[c] ? $sub(s, start, i + 1) : c);
				} else {
					var extra = (b < 0xC0 ? -1 : b < 0xE0 ? 1 : b < 0xF0 ? 2 : b < 0xF8 ? 3 : -1);
					if (extra < 0) throw uriError("URI malformed");
					for (var v = b & (0x3F >> extra), k = 0; k < extra; ++k) {
						if (s[++i] !== '%' || ((b = octet(s, i)) & 0xC0) !== 0x80) throw uriError("URI malformed");	// -1 fails the mask too
						i += 2;
						v = (v << 6) | (b & 0x3F);
					}
					// the one rejection site, straight off the spec's table: overlong, the surrogate gap, past 0x10FFFF
					if (v < (extra === 1 ? 0x80 : extra === 2 ? 0x800 : 0x10000) || (v >= 0xD800 && v <= 0xDFFF) || v > 0x10FFFF) {
						throw uriError("URI malformed");
					}
					// a decoded multi-byte char is never in `keep` (those are ASCII), so no check here
					r.append(v < 0x10000 ? $fromCharCode(v)
							: $fromCharCode(((v -= 0x10000) >> 10) + 0xD800) + $fromCharCode((v & 0x3FF) + 0xDC00));
				}
				j = i + 1;
			}
		}
		return (r === null ? s : r.append($sub(s, j, n)).build());
	}
	defineProperties(globals, { dontEnum: true }, {
		decodeURI: unconstructable(function decodeURI(encodedURI) { if (!RESERVED) createUriTables(); return decode(encodedURI, RESERVED) }),
		decodeURIComponent: unconstructable(function decodeURIComponent(encodedURIComponent) { return decode(encodedURIComponent, NONE) }),
		encodeURI: unconstructable(function encodeURI(uri) { if (!RESERVED) createUriTables(); return encode(uri, FULL_URI) }),
		encodeURIComponent: unconstructable(function encodeURIComponent(uriComponent) { if (!RESERVED) createUriTables(); return encode(uriComponent, UNESCAPED) })
	});
})();
//#endif

//#if !ES5
defineProperties(globals, { dontEnum: true, dontDelete: true }, {
	NaN: $NaN, Infinity: $Infinity, undefined: support.undefined
});
//#else
// 15.1.1.1-3 made the global NaN, Infinity and undefined non-writable; ES3 15.1.1 left them writable.
defineProperties(globals, { readOnly: true, dontEnum: true, dontDelete: true }, {
	NaN: $NaN, Infinity: $Infinity, undefined: support.undefined
});
//#endif

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
	pow: unconstructable(function pow(x, y) { x = +x; y = +y; return (!$isFinite(y) && abs(x) === 1 ? $NaN : support.pow(x, y)) }),
	random: unconstructable(function random() { return support.random() }),
	round: unconstructable(function round(v) { var f; return ((v = +v) === 0.0 ? v : (v >= -0.5 && v < 0.0 ? -0.0 : (v - (f = $floor(v)) >= 0.5 ? f + 1 : f))) }),	// 15.8.2.15: v - floor(v) is exact, so the tie test sees the true fraction where floor(v + 0.5) could double-round
	sin: unconstructable(function sin(v) { return support.sin(+v) }),
	sqrt: unconstructable(function sqrt(v) { return support.sqrt(+v) }),
	tan: unconstructable(function tan(v) { return support.tan(+v) })
});

/* --- Errors --- */

function createErrorConstructor(name, prototype) {
	return function(message) {
		var e = support.createWrapper("Error", name, prototype);
		if (message !== void 0) {
			support.defineProperty(e, "message", str(message), false, true, false);
		}
		return e
	}
};

(function() {
	var ERROR_NAMES = [ "Error", "EvalError", "RangeError", "ReferenceError", "SyntaxError", "TypeError", "URIError" ];

	for (var i = ERROR_NAMES.length; --i >= 0;) {
		var n, c, p;
		support.defineProperty(globals, n = ERROR_NAMES[i], c = createErrorConstructor(n, p = support.prototypes[n])
				, false, true, false);
		c.name = n; // Notice: from ES6 and upwards "name" is read-only (and you would have to delete it to modify here), but it isn't in this implementation
		defineProperties(c, { dontEnum: true, readOnly: true, dontDelete: true }, { prototype: p });
		defineProperties(p, { dontEnum: true }, { constructor: c, name: n });
	}

	defineProperties(Error.prototype, { dontEnum: true }, {
		message: '',
//#if ES5
		toString: unconstructable(function toString() {	// 15.11.4.4 (8-10): an empty name or message drops its side and the colon
			var name = (this.name === void 0 ? "Error" : str(this.name)), msg = (this.message === void 0 ? '' : str(this.message));
			return (name && msg ? name + ": " + msg : name + msg);
		}),
//#endif
//#if !ES5
		toString: unconstructable(function toString() {
			return (this.name === void 0 ? "Error" : this.name) + (this.message ? (": " + this.message) : '');
		})
//#endif
	});

	syntaxError = SyntaxError;
	rangeError = RangeError;
	typeError = TypeError;
//#if ES5
	uriError = URIError;
//#endif
})();

/* --- ES >3 polyfills --- */

// These are not guaranteed to be 100% compatible

var JSON_ESCAPE_SEQUENCES = { '\\': "\\\\", '"': "\\\"", '\b': "\\b", '\f': "\\f", '\n': "\\n", '\r': "\\r", '\t': "\\t" };
var MAX_JSON_DEPTH = 61;	// compiler internal recursion limit is 64 (as of 20240219); keeping this walker far below the ceiling ensures eval() stays safe

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

//#if !ES5
defineProperties(Object, { dontEnum: true }, {
	defineProperty: unconstructable(function defineProperty(o, p, d) {
		support.defineProperty(o, str(p), d.value, !d.writable, !d.enumerable, !d.configurable);
	}),
	getPrototypeOf: unconstructable(function getPrototypeOf(o) { return $getInternalProperty(o, "prototype"); })
});
//#endif
//#if ES5

/* --- ES5.1 additions --- */

/*
	Everything ES5.1 adds to the library, guarded so the ES3 build sees none of it. It lives here rather than in a
	module of its own so that it can reach the helpers above (isPrimitive, int, str, defineProperties, unconstructable,
	typeError and the captured support hooks) instead of restating them, and so the pure ES3 library stays recoverable
	from this one source. It comes last because it supersedes entries defined above.
*/

// Presence bitmask for a property descriptor; must match PropertyDescriptor::HAS_* in NuXJS.h.
var HAS_VALUE = 1, HAS_WRITABLE = 2, HAS_GET = 4, HAS_SET = 8, HAS_ENUMERABLE = 16, HAS_CONFIGURABLE = 32;

// 9.9 / many 15.2.3.x steps: "If Type(O) is not Object, throw a TypeError exception."
function requireObject(o, what) {
	if (isPrimitive(o)) throw typeError("Object." + what + " called on non-object");
	return o
}

/*
	8.10.5 ToPropertyDescriptor, packed positionally as [present, value, get, set, attribs] for the native
	defineOwnProperty that `define` hands it to. The attributes object is read through [[Get]], so accessors on it
	run. 15.2.3.7 converts every descriptor before defining any of them, so the packed form has to outlive the
	conversion; a named object would spend preserved names on `value`, `get` and `set`.
*/
function toPropertyDescriptor(attrs) {
	if (isPrimitive(attrs)) throw typeError("Property description must be an object");
	var present = 0, attribs = 0, v, g, s;
	if ("enumerable" in attrs) { present |= HAS_ENUMERABLE; if (attrs.enumerable) attribs |= 2; }
	if ("configurable" in attrs) { present |= HAS_CONFIGURABLE; if (attrs.configurable) attribs |= 4; }
	if ("value" in attrs) { present |= HAS_VALUE; v = attrs.value; }
	if ("writable" in attrs) { present |= HAS_WRITABLE; if (attrs.writable) attribs |= 1; }
	if ("get" in attrs) {
		if ((g = attrs.get) !== void 0 && typeof g !== "function") throw typeError("Getter must be a function");
		present |= HAS_GET;
	}
	if ("set" in attrs) {
		if ((s = attrs.set) !== void 0 && typeof s !== "function") throw typeError("Setter must be a function");
		present |= HAS_SET;
	}
	if ((present & (HAS_GET | HAS_SET)) !== 0 && (present & (HAS_VALUE | HAS_WRITABLE)) !== 0) {
		throw typeError("A property descriptor cannot specify both accessors and a value or writable");
	}
	return [ present, v, g, s, attribs ]
}

/*
	`key` is already a String at all three call sites, ToString(P) being an earlier and separately ordered step.
	15.4.5.1 (3.c) runs ToUint32 over an array length's new value, which for an object means its valueOf, and the
	native defineOwnProperty may not run script. Doing the ToNumber here leaves the native the pure range check it
	already had, and 3.c comes before every reject in that algorithm, so it is right that nothing gates it.
*/
function define(o, key, d) {
	if ((d[0] & HAS_VALUE) !== 0 && key === "length" && $getInternalProperty(o, "class") === "Array") d[1] = +d[1];
	support.defineOwnProperty(o, key, d[0], d[1], d[2], d[3], d[4]);
}

/*
	15.2.3.7 steps 3-6. Every descriptor is converted before any of them is defined, so a malformed one later in the
	list leaves the properties ahead of it untouched. `pairs` holds name and packed descriptor in alternating slots,
	the enumeration order of step 3 being for-in order by the note under the algorithm.
*/
function defineAll(o, properties) {
	if (properties == null) throw typeError("Cannot convert undefined or null to object");	// 15.2.3.7 (1): ToObject, which Object() would paper over with a fresh object
	var props = Object(properties), pairs = [ ], p, i, n;
	for (p in props) {
		if (support.hasOwnProperty(props, p)) {
			pairs[pairs.length] = p;
			pairs[pairs.length] = toPropertyDescriptor(props[p]);
		}
	}
	for (i = 0, n = pairs.length; i < n; i += 2) define(o, pairs[i], pairs[i + 1]);
	return o
}

/*
	15.2.3.8 seal and 15.2.3.9 freeze, which differ only in freeze additionally clearing [[Writable]] on a data
	property. Step 2 defines unconditionally, which the full current descriptor makes a no-op by 8.12.9 step 6 when
	nothing changed; re-supplying value and enumerable also keeps the deferred array-index path from clobbering
	elements. isSealed / isFrozen (15.2.3.11, 15.2.3.12) are the same walk asking instead of setting.
*/
function lockDown(o, what, freezing) {
	var names = support.getOwnPropertyNames(requireObject(o, what)), i, d;
	for (i = names.length; --i >= 0; ) {
		d = support.getOwnPropertyDescriptor(o, names[i]);
		if (freezing && ("value" in d)) d.writable = false;
		d.configurable = false;
		define(o, names[i], toPropertyDescriptor(d));
	}
	return support.preventExtensions(o)
}

function isLockedDown(o, what, frozen) {
	var names = support.getOwnPropertyNames(requireObject(o, what)), i, d;
	for (i = names.length; --i >= 0; ) {
		d = support.getOwnPropertyDescriptor(o, names[i]);
		if (d.configurable || (frozen && ("value" in d) && d.writable)) return false;
	}
	return !support.isExtensible(o)
}

defineProperties(Object, { dontEnum: true }, {
	preventExtensions: unconstructable(function preventExtensions(o) {	// 15.2.3.10
		return support.preventExtensions(requireObject(o, "preventExtensions"));
	}),
	isExtensible: unconstructable(function isExtensible(o) {	// 15.2.3.13
		return support.isExtensible(requireObject(o, "isExtensible"));
	}),
	// 15.2.3.6, the full 8.12.9 form, superseding the data-only shim above
	defineProperty: unconstructable(function defineProperty(o, p, attributes) {
		requireObject(o, "defineProperty");
		define(o, str(p), toPropertyDescriptor(attributes));	// 2 before 3: ToString(P) runs before ToPropertyDescriptor
		return o;
	}),
	// 15.2.3.7. The key is quoted because the minifier keeps one flat rename map for the whole file: @preserve-ing
	// this name to publish it would also spell out all 33 uses of the local helper this very table is built with.
	"defineProperties": unconstructable(function defineProperties(o, properties) {
		return defineAll(requireObject(o, "defineProperties"), properties);
	}),
	// 15.2.3.2, superseding the shim above, which skipped the non-object check
	getPrototypeOf: unconstructable(function getPrototypeOf(o) {
		return $getInternalProperty(requireObject(o, "getPrototypeOf"), "prototype");
	}),
	getOwnPropertyDescriptor: unconstructable(function getOwnPropertyDescriptor(o, p) {	// 15.2.3.3
		return support.getOwnPropertyDescriptor(requireObject(o, "getOwnPropertyDescriptor"), str(p));
	}),
	// 15.2.3.4: all own string-keyed names, including the non-enumerable ones
	getOwnPropertyNames: unconstructable(function getOwnPropertyNames(o) {
		return support.getOwnPropertyNames(requireObject(o, "getOwnPropertyNames"));
	}),
	keys: unconstructable(function keys(o) {	// 15.2.3.14: own enumerable string-keyed names, in for-in order
		requireObject(o, "keys");
		var a = [ ], k;
		for (k in o) if (support.hasOwnProperty(o, k)) a[a.length] = k;
		return a;
	}),
	create: unconstructable(function create(o, properties) {	// 15.2.3.5
		if (o !== null && isPrimitive(o)) throw typeError("Object.create: prototype must be an object or null");
		var obj = support.createObject(o);
		return (properties === void 0 ? obj : defineAll(obj, properties));
	}),
	seal: unconstructable(function seal(o) { return lockDown(o, "seal", false) }),
	freeze: unconstructable(function freeze(o) { return lockDown(o, "freeze", true) }),
	isSealed: unconstructable(function isSealed(o) { return isLockedDown(o, "isSealed", false) }),
	isFrozen: unconstructable(function isFrozen(o) { return isLockedDown(o, "isFrozen", true) })
});

// 15.9.4.4: the time value at the moment of the call, which ES3 had no equivalent of.
defineProperties(Date, { dontEnum: true }, {
	now: unconstructable(function now() { return support.getCurrentTime() })
});

var $sort = Array.prototype.sort;	// captured before the entry below replaces it

/*
	Everything left whose first step is CheckObjectCoercible or ToObject on the this value, or that stores with
	Throw = true. One IIFE rather than a directive prologue for each of the twelve: 10.4.3 would substitute the
	global object for a null this and make the required TypeError unreachable, and 8.7.2 and 11.4.1 only raise a
	refused store into one in strict code. Strict mode also leaves `arguments` unmapped, which the "was the
	argument supplied?" tests below want. The file as a whole cannot be strict: evalThere assigns to `eval`.
*/
(function() {
"use strict";

// "If IsCallable(callbackfn) is false, throw a TypeError exception." Runs after length is read, never before.
function checkCallback(f, what) {
	if (typeof f !== "function") throw typeError("Array.prototype." + what + " callback is not a function");
	return f
}

defineProperties(String.prototype, { dontEnum: true }, {
	/*
		15.5.4.20: strips WhiteSpace (7.2) and LineTerminator (7.3) from both ends, which is exactly the set 15.1.2.2
		parseInt skips, so it reads the one table above. Whitespace is the only key that maps to null there: a digit
		maps to its value and anything else is absent.
	*/
	trim: unconstructable(function trim() {
		if (this == null) throw typeError("String.prototype.trim called on null or undefined");
		var pic = PARSE_INT_CHARS, s = str(this), i = 0, j = s.length;
		while (i < j && pic[s[i]] === null) ++i;
		while (j > i && pic[s[j - 1]] === null) --j;
		return $sub(s, i, j);
	})
});

defineProperties(Function.prototype, { dontEnum: true }, {
	// 15.3.4.5: the native side builds the bound function, since it needs internal methods JS cannot express (no
	// `prototype`, a [[Construct]] that constructs the target, and a [[HasInstance]] that defers to it).
	bind: unconstructable(function bind(thisArg) { return support.bindFunction(this, thisArg, arguments, 1) })
});

defineProperties(Date.prototype, { dontEnum: true }, {
	// 15.9.5.44: fully generic, where the entry it supersedes reads the receiver's own date value rather than going
	// through ToPrimitive and the receiver's own (reassignable) toISOString. ES3 had no toJSON at all.
	toJSON: unconstructable(function toJSON(key) {
		var o = Object(this), tv = objectToPrimitive(o, "valueOf", "toString"), toISO;
		if (typeof tv === "number" && !$isFinite(tv)) return null;
		if (typeof (toISO = o.toISOString) !== "function") throw typeError("toISOString is not callable");
		return $callWithArgs(toISO, o);
	})
});

defineProperties(Array.prototype, { dontEnum: true }, {
	/*
		15.4.4.11 hands the present elements to the base sort and then writes the permutation back strictly, which is
		what supplies the Throw flag; the ordering itself is unchanged. SortCompare's ranking falls out of that: the
		base comparator already sorts undefined last, and lifting the holes out puts them after even those. This is the
		one place the ES3 entry is still needed under ES5, which is why sort above is not a guarded alternative like the
		other six mutators.
	*/
	sort: unconstructable(function sort(comparefn) {
		var o = toObject(this, "sort"), len = o.length >>> 0, v = [ ], k;
		if (len < 2) return o;	// nothing can move, so nothing is stored: a frozen empty or single array must not throw
		for (k = 0; k < len; ++k) if (k in o) v[v.length] = o[k];
		$callWithArgs($sort, v, arguments);
		for (k = 0; k < v.length; ++k) o[k] = v[k];
		for (; k < len; ++k) delete o[k];
		return o;
	}),
	/*
		15.4.4.14-22. All nine are generic over array-likes, read length once up front, and visit only indices that are
		present, so holes are skipped rather than passed as undefined. Each declares one formal parameter because the
		spec fixes its `length` at 1, the optional second coming from `arguments`. `args` below is one scratch argument
		list per call rather than per element, callWithArgs copying it into the callee's frame before invoking.
	*/
	indexOf: unconstructable(function indexOf(searchElement) {
		var o = toObject(this, "indexOf"), len = o.length >>> 0, k;
		if (len === 0) return -1;	// 4: returns before fromIndex is read, so a throwing valueOf is never reached
		k = (arguments.length > 1 ? int(arguments[1]) : 0);
		if (k < 0 && (k += len) < 0) k = 0;	// 8.b: a negative fromIndex is an offset from the end, clamped to 0
		for (; k < len; ++k) if (k in o && o[k] === searchElement) return k;
		return -1;
	}),
	lastIndexOf: unconstructable(function lastIndexOf(searchElement) {
		var o = toObject(this, "lastIndexOf"), len = o.length >>> 0, k;
		if (len === 0) return -1;	// 4: as above, an empty array never reads fromIndex
		k = (arguments.length > 1 ? int(arguments[1]) : len - 1);
		if (k < 0) k += len; else if (k >= len) k = len - 1;	// 7: a negative result just ends the search
		for (; k >= 0; --k) if (k in o && o[k] === searchElement) return k;
		return -1;
	}),
	every: unconstructable(function every(callbackfn) {
		var o = toObject(this, "every"), len = o.length >>> 0, f = checkCallback(callbackfn, "every"), t = arguments[1]
				, args = [ 0, 0, o ];
		for (var k = 0; k < len; ++k) {
			if (k in o) { args[0] = o[k]; args[1] = k; if (!$callWithArgs(f, t, args)) return false; }
		}
		return true;
	}),
	some: unconstructable(function some(callbackfn) {
		var o = toObject(this, "some"), len = o.length >>> 0, f = checkCallback(callbackfn, "some"), t = arguments[1]
				, args = [ 0, 0, o ];
		for (var k = 0; k < len; ++k) {
			if (k in o) { args[0] = o[k]; args[1] = k; if ($callWithArgs(f, t, args)) return true; }
		}
		return false;
	}),
	forEach: unconstructable(function forEach(callbackfn) {
		var o = toObject(this, "forEach"), len = o.length >>> 0, f = checkCallback(callbackfn, "forEach")
				, t = arguments[1], args = [ 0, 0, o ];
		for (var k = 0; k < len; ++k) if (k in o) { args[0] = o[k]; args[1] = k; $callWithArgs(f, t, args); }
	}),
	map: unconstructable(function map(callbackfn) {
		var o = toObject(this, "map"), len = o.length >>> 0, f = checkCallback(callbackfn, "map"), t = arguments[1]
				, args = [ 0, 0, o ], a = [ ];
		a.length = len;	// 6: length is fixed up front, so a hole in the source stays a hole in the result
		for (var k = 0; k < len; ++k) if (k in o) { args[0] = o[k]; args[1] = k; a[k] = $callWithArgs(f, t, args); }
		return a;
	}),
	filter: unconstructable(function filter(callbackfn) {
		var o = toObject(this, "filter"), len = o.length >>> 0, f = checkCallback(callbackfn, "filter")
				, t = arguments[1], args = [ 0, 0, o ], a = [ ], to = 0, v;	// 8: `to` packs the result densely, unlike map
		for (var k = 0; k < len; ++k) {
			if (k in o) { args[0] = v = o[k]; args[1] = k; if ($callWithArgs(f, t, args)) a[to++] = v; }
		}
		return a;
	}),
	/*
		reduce / reduceRight take four callback arguments and no thisArg, so the callback is called as a function.
		With no initialValue the first present element seeds the accumulator; if there is none, that is a TypeError,
		which also covers step 5 (empty and unseeded) without a second test.
	*/
	reduce: unconstructable(function reduce(callbackfn) {
		var o = toObject(this, "reduce"), len = o.length >>> 0, f = checkCallback(callbackfn, "reduce")
				, k = 0, seeded = (arguments.length > 1), acc = arguments[1], args = [ 0, 0, 0, o ];
		while (!seeded && k < len) { if (seeded = (k in o)) acc = o[k]; ++k; }
		if (!seeded) throw typeError("Reduce of empty array with no initial value");
		for (; k < len; ++k) {
			if (k in o) { args[0] = acc; args[1] = o[k]; args[2] = k; acc = $callWithArgs(f, void 0, args); }
		}
		return acc;
	}),
	reduceRight: unconstructable(function reduceRight(callbackfn) {
		var o = toObject(this, "reduceRight"), len = o.length >>> 0, f = checkCallback(callbackfn, "reduceRight")
				, k = len - 1, seeded = (arguments.length > 1), acc = arguments[1], args = [ 0, 0, 0, o ];
		while (!seeded && k >= 0) { if (seeded = (k in o)) acc = o[k]; --k; }
		if (!seeded) throw typeError("Reduce of empty array with no initial value");
		for (; k >= 0; --k) {
			if (k in o) { args[0] = acc; args[1] = o[k]; args[2] = k; acc = $callWithArgs(f, void 0, args); }
		}
		return acc;
	})
});

})();
//#endif

if ($NaN.toString() !== "NaN") throw Error("Internal self test failed. Check C++ compiler options concerning IEEE 754 compliance.");

})
