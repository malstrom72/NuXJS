/*
	ES5.1 additions to the standard library.

	Compiled into STDLIB_ES5_JS and run only in NUXJS_ES5 builds, as a standalone module that receives the same
	native `support` bridge as stdlib.js and runs with `this` bound to the global object. The ES3 stdlib.js is
	never touched, so the ES3 embedding stays byte-for-byte identical. This module may use the native `support`
	hooks and the globals stdlib.js has already installed, but not stdlib.js's private (closure-local) helpers.

	@preserve: trim,preventExtensions,isExtensible,defineProperties,defineOwnProperty,get,set
	@preserve: getOwnPropertyDescriptor,keys,getOwnPropertyNames,createObject,create
	@preserve: seal,freeze,isSealed,isFrozen,now,toPrimitiveNumber,push,forEach,map,filter,some,every,reduce,reduceRight,bind,bindFunction
*/
(function (support) {

var $defineProperty = support.defineProperty, unconstructable = support.distinctConstructor
		, $getInternalProperty = support.getInternalProperty, typeError = TypeError;

// Presence bitmask for a property descriptor; must match PropertyDescriptor::HAS_* in NuXJS.h.
var HAS_VALUE = 1, HAS_WRITABLE = 2, HAS_GET = 4, HAS_SET = 8, HAS_ENUMERABLE = 16, HAS_CONFIGURABLE = 32;

// Built-in methods are writable, non-enumerable, configurable, and (like all standard built-ins) not constructors.
function method(target, name, fn) { $defineProperty(target, name, unconstructable(fn), false, true, false); }

// 9.9 / many 15.2.3.x steps: "If Type(O) is not Object, throw a TypeError exception."
function requireObject(o, name) {
	if (o === null || (typeof o !== "object" && typeof o !== "function")) {
		throw typeError("Object." + name + " called on non-object");
	}
	return o;
}

// 8.10.5 ToPropertyDescriptor. Reads the attributes object (via [[Get]], so getters run) and packs it into the
// present / value / get / set / attribs form the native support.defineOwnProperty consumes.
function toPropertyDescriptor(attrs) {
	if (attrs === null || (typeof attrs !== "object" && typeof attrs !== "function")) {
		throw typeError("Property description must be an object");
	}
	var present = 0, value, get, set, writable = false, enumerable = false, configurable = false;
	if ("enumerable" in attrs) { present |= HAS_ENUMERABLE; enumerable = !!attrs.enumerable; }
	if ("configurable" in attrs) { present |= HAS_CONFIGURABLE; configurable = !!attrs.configurable; }
	if ("value" in attrs) { present |= HAS_VALUE; value = attrs.value; }
	if ("writable" in attrs) { present |= HAS_WRITABLE; writable = !!attrs.writable; }
	if ("get" in attrs) {
		get = attrs.get;
		if (get !== undefined && typeof get !== "function") throw typeError("Getter must be a function");
		present |= HAS_GET;
	}
	if ("set" in attrs) {
		set = attrs.set;
		if (set !== undefined && typeof set !== "function") throw typeError("Setter must be a function");
		present |= HAS_SET;
	}
	if ((present & (HAS_GET | HAS_SET)) !== 0 && (present & (HAS_VALUE | HAS_WRITABLE)) !== 0) {
		throw typeError("A property descriptor cannot specify both accessors and a value or writable");
	}
	return { present: present, value: value, get: get, set: set
			, attribs: (writable ? 1 : 0) | (enumerable ? 2 : 0) | (configurable ? 4 : 0) };
}

function define(o, key, attributes) {
	var d = toPropertyDescriptor(attributes);
	support.defineOwnProperty(o, "" + key, d.present, d.value, d.get, d.set, d.attribs);
}

/*
	Prototype methods whose first step is CheckObjectCoercible or ToObject on the this value. They must be strict:
	a non-strict function has a null or undefined this substituted with the global object (10.4.3), which would
	make the required TypeError unreachable. Strict mode also makes `arguments` unmapped, which is what the
	"was the argument supplied?" tests below want.
*/
(function () {
"use strict";

// 9.4 ToInteger, restated verbatim from stdlib.js, which keeps its copy closure-local. 9.6 ToUint32 needs no
// helper: `>>> 0` is that conversion, so `length` is normalised inline below.
var $floor = Math.floor, $isNaN = isNaN, $isFinite = isFinite;
function int(v) { return ($isNaN(v = +v) || v === 0) ? 0 : (!$isFinite(v) ? v : (v < 0 ? -$floor(-v) : $floor(v))); }

// Step 1 of every array method below: ToObject(this), which throws for null and undefined (9.9).
function toObject(v, name) {
	if (v == null) throw typeError("Array.prototype." + name + " called on null or undefined");
	return Object(v);
}

// "If IsCallable(callbackfn) is false, throw a TypeError exception." Runs after length is read, never before.
function checkCallback(f, name) {
	if (typeof f !== "function") throw typeError("Array.prototype." + name + " callback is not a function");
	return f;
}

// 15.5.4.20: strips WhiteSpace (7.2) and LineTerminator (7.3) from both ends of the string.
function isSpace(c) {
	return c === 0x20 || (c >= 0x09 && c <= 0x0D) || c === 0xA0 || c === 0xFEFF
			|| c === 0x1680 || (c >= 0x2000 && c <= 0x200A)
			|| c === 0x2028 || c === 0x2029 || c === 0x202F || c === 0x205F || c === 0x3000;
}

method(String.prototype, "trim", function trim() {
	if (this == null) throw typeError("String.prototype.trim called on null or undefined");
	var s = "" + this, i = 0, j = s.length;
	while (i < j && isSpace(s.charCodeAt(i))) ++i;
	while (j > i && isSpace(s.charCodeAt(j - 1))) --j;
	return s.substring(i, j);
});

// 15.3.4.5: the native side builds the bound function, since it needs internal methods JS cannot express (no
// `prototype`, a [[Construct]] that constructs the target, and a [[HasInstance]] that defers to it).
method(Function.prototype, "bind", function bind(thisArg) {
	return support.bindFunction(this, thisArg, arguments, 1);
});

/*
	15.2.4.2 gained explicit undefined and null cases, and 10.6 gave the arguments object the class "Arguments"
	where ES3 10.1.8 gave it "Object" (which is why stdlib.js maps that class back to "Object").
	DEVIATION: `this` reaches a callee as an object reference, so a null receiver is indistinguishable from an
	undefined one and reports "[object Undefined]". Fixing that needs the `this`-as-a-Value change deferred in
	docs/notes/ECMAScript Compatibility Notes.md.
*/
method(Object.prototype, "toString", function toString() {
	if (this == null) return "[object Undefined]";
	return "[object " + $getInternalProperty(Object(this), "class") + "]";
});

// 15.9.5.44: fully generic. ES3 had no toJSON at all, and stdlib.js's version reads the receiver's own date value
// rather than going through ToPrimitive and the receiver's own (reassignable) toISOString.
method(Date.prototype, "toJSON", function toJSON(key) {
	var o = Object(this), tv = support.toPrimitiveNumber(o), toISO;
	if (typeof tv === "number" && !isFinite(tv)) return null;
	if (typeof (toISO = o.toISOString) !== "function") throw typeError("toISOString is not callable");
	return toISO.call(o);
});

// 15.4.4.7: ES5 passes Throw = true to every [[Put]] push makes, where ES3 15.4.4.7 had no Throw flag at all. Being
// strict is what turns a refused store into the required TypeError, and it also stops `length` from running ahead of
// an element that was never stored, on a non-extensible array or past a read-only length.
method(Array.prototype, "push", function push(item) {
	var o = toObject(this, "push"), n = o.length >>> 0, argv = arguments;
	for (var i = 0; i < argv.length; ++i) {
		o[n] = argv[i];
		++n;
	}
	o.length = n;
	return n;
});

/*
	15.4.4.14-22. All nine are generic over array-likes, read length once up front, and visit only indices that
	are actually present, so holes are skipped rather than passed as undefined. Each declares exactly one formal
	parameter because the spec fixes its `length` at 1; the optional second argument comes from `arguments`.
*/
method(Array.prototype, "indexOf", function indexOf(searchElement) {
	var o = toObject(this, "indexOf"), len = o.length >>> 0, k;
	if (len === 0) return -1;	// 4: returns before fromIndex is read, so a throwing valueOf is never reached
	k = (arguments.length > 1 ? int(arguments[1]) : 0);
	if (k < 0 && (k += len) < 0) k = 0;	// 8.b: a negative fromIndex is an offset from the end, clamped to 0
	for (; k < len; ++k) if (k in o && o[k] === searchElement) return k;
	return -1;
});

method(Array.prototype, "lastIndexOf", function lastIndexOf(searchElement) {
	var o = toObject(this, "lastIndexOf"), len = o.length >>> 0, k;
	if (len === 0) return -1;	// 4: as above, an empty array never reads fromIndex
	k = (arguments.length > 1 ? int(arguments[1]) : len - 1);
	if (k < 0) k += len; else if (k >= len) k = len - 1;	// 7: a negative result just ends the search
	for (; k >= 0; --k) if (k in o && o[k] === searchElement) return k;
	return -1;
});

method(Array.prototype, "every", function every(callbackfn) {
	var o = toObject(this, "every"), len = o.length >>> 0, f = checkCallback(callbackfn, "every"), t = arguments[1];
	for (var k = 0; k < len; ++k) if (k in o && !f.call(t, o[k], k, o)) return false;
	return true;
});

method(Array.prototype, "some", function some(callbackfn) {
	var o = toObject(this, "some"), len = o.length >>> 0, f = checkCallback(callbackfn, "some"), t = arguments[1];
	for (var k = 0; k < len; ++k) if (k in o && f.call(t, o[k], k, o)) return true;
	return false;
});

method(Array.prototype, "forEach", function forEach(callbackfn) {
	var o = toObject(this, "forEach"), len = o.length >>> 0, f = checkCallback(callbackfn, "forEach"), t = arguments[1];
	for (var k = 0; k < len; ++k) if (k in o) f.call(t, o[k], k, o);
});

method(Array.prototype, "map", function map(callbackfn) {
	var o = toObject(this, "map"), len = o.length >>> 0, f = checkCallback(callbackfn, "map"), t = arguments[1]
			, a = new Array(len);	// 6: length is fixed up front, so a hole in the source stays a hole in the result
	for (var k = 0; k < len; ++k) if (k in o) a[k] = f.call(t, o[k], k, o);
	return a;
});

method(Array.prototype, "filter", function filter(callbackfn) {
	var o = toObject(this, "filter"), len = o.length >>> 0, f = checkCallback(callbackfn, "filter"), t = arguments[1]
			, a = [ ], to = 0, v;	// 8: `to` packs the result densely, unlike map
	for (var k = 0; k < len; ++k) if (k in o && f.call(t, v = o[k], k, o)) a[to++] = v;
	return a;
});

/*
	reduce / reduceRight take four callback arguments and no thisArg, so the callback is called as a function.
	With no initialValue the first present element seeds the accumulator; if there is none, that is a TypeError,
	which also covers step 5 (empty and unseeded) without a second test.
*/
method(Array.prototype, "reduce", function reduce(callbackfn) {
	var o = toObject(this, "reduce"), len = o.length >>> 0, f = checkCallback(callbackfn, "reduce")
			, k = 0, seeded = (arguments.length > 1), acc = arguments[1];
	while (!seeded && k < len) { if (seeded = (k in o)) acc = o[k]; ++k; }
	if (!seeded) throw typeError("Reduce of empty array with no initial value");
	for (; k < len; ++k) if (k in o) acc = f(acc, o[k], k, o);
	return acc;
});

method(Array.prototype, "reduceRight", function reduceRight(callbackfn) {
	var o = toObject(this, "reduceRight"), len = o.length >>> 0, f = checkCallback(callbackfn, "reduceRight")
			, k = len - 1, seeded = (arguments.length > 1), acc = arguments[1];
	while (!seeded && k >= 0) { if (seeded = (k in o)) acc = o[k]; --k; }
	if (!seeded) throw typeError("Reduce of empty array with no initial value");
	for (; k >= 0; --k) if (k in o) acc = f(acc, o[k], k, o);
	return acc;
});

})();

// 15.2.3.10 Object.preventExtensions / 15.2.3.13 Object.isExtensible
method(Object, "preventExtensions", function preventExtensions(o) {
	return support.preventExtensions(requireObject(o, "preventExtensions"));
});

method(Object, "isExtensible", function isExtensible(o) {
	return support.isExtensible(requireObject(o, "isExtensible"));
});

// 15.2.3.6 Object.defineProperty (overrides the partial data-only shim in stdlib.js with the full 8.12.9 form)
method(Object, "defineProperty", function defineProperty(o, p, attributes) {
	requireObject(o, "defineProperty");
	define(o, p, attributes);
	return o;
});

// 15.2.3.7 Object.defineProperties
method(Object, "defineProperties", function defineProperties(o, properties) {
	requireObject(o, "defineProperties");
	var props = Object(properties);
	for (var name in props) {
		if (support.hasOwnProperty(props, name)) define(o, name, props[name]);
	}
	return o;
});

// 15.2.3.2 Object.getPrototypeOf (stdlib.js has a version without the non-object check; override for strictness)
method(Object, "getPrototypeOf", function getPrototypeOf(o) {
	requireObject(o, "getPrototypeOf");
	return $getInternalProperty(o, "prototype");
});

// 15.2.3.3 Object.getOwnPropertyDescriptor
method(Object, "getOwnPropertyDescriptor", function getOwnPropertyDescriptor(o, p) {
	requireObject(o, "getOwnPropertyDescriptor");
	return support.getOwnPropertyDescriptor(o, "" + p);
});

// 15.2.3.4 Object.getOwnPropertyNames: all own string-keyed names, including non-enumerable ones.
method(Object, "getOwnPropertyNames", function getOwnPropertyNames(o) {
	requireObject(o, "getOwnPropertyNames");
	return support.getOwnPropertyNames(o);
});

// 15.2.3.14 Object.keys: own enumerable string-keyed property names, in for-in order.
method(Object, "keys", function keys(o) {
	requireObject(o, "keys");
	var result = [], k;
	for (k in o) {
		if (support.hasOwnProperty(o, k)) result.push(k);
	}
	return result;
});

// 15.2.3.5 Object.create
method(Object, "create", function create(o, properties) {
	if (o !== null && typeof o !== "object" && typeof o !== "function") {
		throw typeError("Object.create: prototype must be an object or null");
	}
	var obj = support.createObject(o);
	if (properties !== undefined) Object.defineProperties(obj, properties);
	return obj;
});

// 15.2.3.8 Object.seal: make every own property non-configurable, then prevent extensions. The full current
// descriptor is re-supplied (value/enumerable kept) so the deferred array-index path does not clobber elements.
method(Object, "seal", function seal(o) {
	requireObject(o, "seal");
	var names = Object.getOwnPropertyNames(o);
	for (var i = 0; i < names.length; ++i) {
		var d = Object.getOwnPropertyDescriptor(o, names[i]);
		if (d.configurable) { d.configurable = false; Object.defineProperty(o, names[i], d); }
	}
	return Object.preventExtensions(o);
});

// 15.2.3.9 Object.freeze: seal, and additionally make data properties non-writable.
method(Object, "freeze", function freeze(o) {
	requireObject(o, "freeze");
	var names = Object.getOwnPropertyNames(o);
	for (var i = 0; i < names.length; ++i) {
		var d = Object.getOwnPropertyDescriptor(o, names[i]);
		if ("value" in d) d.writable = false;
		d.configurable = false;
		Object.defineProperty(o, names[i], d);
	}
	return Object.preventExtensions(o);
});

// 15.2.3.11 Object.isSealed
method(Object, "isSealed", function isSealed(o) {
	requireObject(o, "isSealed");
	var names = Object.getOwnPropertyNames(o);
	for (var i = 0; i < names.length; ++i) {
		if (Object.getOwnPropertyDescriptor(o, names[i]).configurable) return false;
	}
	return !Object.isExtensible(o);
});

// 15.2.3.12 Object.isFrozen
method(Object, "isFrozen", function isFrozen(o) {
	requireObject(o, "isFrozen");
	var names = Object.getOwnPropertyNames(o);
	for (var i = 0; i < names.length; ++i) {
		var d = Object.getOwnPropertyDescriptor(o, names[i]);
		if (d.configurable || (("value" in d) && d.writable)) return false;
	}
	return !Object.isExtensible(o);
});

// 15.9.4.4 Date.now: the time value at the moment of the call, which ES3 had no equivalent of.
method(Date, "now", function now() { return support.getCurrentTime(); });

// 15.1.1.1-3: ES5 made the global NaN, Infinity and undefined non-writable. ES3 15.1.1 left them writable, so
// stdlib.js installs them with dontEnum + dontDelete only; re-define them here with readOnly added.
$defineProperty(this, "NaN", this.NaN, true, true, true);
$defineProperty(this, "Infinity", this.Infinity, true, true, true);
$defineProperty(this, "undefined", this.undefined, true, true, true);

})
