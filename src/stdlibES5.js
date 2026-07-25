/*
	ES5.1 additions to the standard library.

	Compiled into STDLIB_ES5_JS and run only in NUXJS_ES5 builds, as a standalone module that receives the same
	native `support` bridge as stdlib.js and runs with `this` bound to the global object. The ES3 stdlib.js is
	never touched, so the ES3 embedding stays byte-for-byte identical. This module may use the native `support`
	hooks and the globals stdlib.js has already installed, but not stdlib.js's private (closure-local) helpers.

	@preserve: trim,preventExtensions,isExtensible,defineProperties,defineOwnProperty,get,set
	@preserve: getOwnPropertyDescriptor,keys,getOwnPropertyNames,createObject,create
	@preserve: seal,freeze,isSealed,isFrozen
*/
(function (support) {

var $defineProperty = support.defineProperty, unconstructable = support.distinctConstructor
		, $getInternalProperty = support.getInternalProperty;

// Presence bitmask for a property descriptor; must match PropertyDescriptor::HAS_* in NuXJS.h.
var HAS_VALUE = 1, HAS_WRITABLE = 2, HAS_GET = 4, HAS_SET = 8, HAS_ENUMERABLE = 16, HAS_CONFIGURABLE = 32;

// Built-in methods are writable, non-enumerable, configurable, and (like all standard built-ins) not constructors.
function method(target, name, fn) { $defineProperty(target, name, unconstructable(fn), false, true, false); }

// 9.9 / many 15.2.3.x steps: "If Type(O) is not Object, throw a TypeError exception."
function requireObject(o, name) {
	if (o === null || (typeof o !== "object" && typeof o !== "function")) {
		throw new TypeError("Object." + name + " called on non-object");
	}
	return o;
}

// 8.10.5 ToPropertyDescriptor. Reads the attributes object (via [[Get]], so getters run) and packs it into the
// present / value / get / set / attribs form the native support.defineOwnProperty consumes.
function toPropertyDescriptor(attrs) {
	if (attrs === null || (typeof attrs !== "object" && typeof attrs !== "function")) {
		throw new TypeError("Property description must be an object");
	}
	var present = 0, value, get, set, writable = false, enumerable = false, configurable = false;
	if ("enumerable" in attrs) { present |= HAS_ENUMERABLE; enumerable = !!attrs.enumerable; }
	if ("configurable" in attrs) { present |= HAS_CONFIGURABLE; configurable = !!attrs.configurable; }
	if ("value" in attrs) { present |= HAS_VALUE; value = attrs.value; }
	if ("writable" in attrs) { present |= HAS_WRITABLE; writable = !!attrs.writable; }
	if ("get" in attrs) {
		get = attrs.get;
		if (get !== undefined && typeof get !== "function") throw new TypeError("Getter must be a function");
		present |= HAS_GET;
	}
	if ("set" in attrs) {
		set = attrs.set;
		if (set !== undefined && typeof set !== "function") throw new TypeError("Setter must be a function");
		present |= HAS_SET;
	}
	if ((present & (HAS_GET | HAS_SET)) !== 0 && (present & (HAS_VALUE | HAS_WRITABLE)) !== 0) {
		throw new TypeError("A property descriptor cannot specify both accessors and a value or writable");
	}
	return { present: present, value: value, get: get, set: set
			, attribs: (writable ? 1 : 0) | (enumerable ? 2 : 0) | (configurable ? 4 : 0) };
}

function define(o, key, attributes) {
	var d = toPropertyDescriptor(attributes);
	support.defineOwnProperty(o, "" + key, d.present, d.value, d.get, d.set, d.attribs);
}

// ES5.1 15.5.4.20: strips WhiteSpace (7.2) and LineTerminator (7.3) from both ends of the string.
function isSpace(c) {
	return c === 0x20 || (c >= 0x09 && c <= 0x0D) || c === 0xA0 || c === 0xFEFF
			|| c === 0x1680 || (c >= 0x2000 && c <= 0x200A)
			|| c === 0x2028 || c === 0x2029 || c === 0x202F || c === 0x205F || c === 0x3000;
}

method(String.prototype, "trim", function trim() {
	if (this == null) throw new TypeError("String.prototype.trim called on null or undefined");
	var s = "" + this, i = 0, j = s.length;
	while (i < j && isSpace(s.charCodeAt(i))) ++i;
	while (j > i && isSpace(s.charCodeAt(j - 1))) --j;
	return s.substring(i, j);
});

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
		throw new TypeError("Object.create: prototype must be an object or null");
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

// 15.1.1.1-3: ES5 made the global NaN, Infinity and undefined non-writable. ES3 15.1.1 left them writable, so
// stdlib.js installs them with dontEnum + dontDelete only; re-define them here with readOnly added.
$defineProperty(this, "NaN", this.NaN, true, true, true);
$defineProperty(this, "Infinity", this.Infinity, true, true, true);
$defineProperty(this, "undefined", this.undefined, true, true, true);

})
