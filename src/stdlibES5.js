/*
	ES5.1 additions to the standard library.

	Compiled into STDLIB_ES5_JS and run only in NUXJS_ES5 builds, as a standalone module that receives the same
	native `support` bridge as stdlib.js and runs with `this` bound to the global object. The ES3 stdlib.js is
	never touched, so the ES3 embedding stays byte-for-byte identical. This module may use the native `support`
	hooks and the globals stdlib.js has already installed, but not stdlib.js's private (closure-local) helpers.

	The minifier seeds this module with stdlib.js's @preserve header, so only genuinely new names go below.

	@preserve: trim,preventExtensions,isExtensible,defineProperties,defineOwnProperty,get,set,keys,create,now
	@preserve: getOwnPropertyDescriptor,getOwnPropertyNames,createObject,seal,freeze,isSealed,isFrozen
	@preserve: forEach,map,filter,some,every,reduce,reduceRight,bind,bindFunction
*/
(function (support) {

/*
	Every global and every prototype method this module needs is captured now, before any user code can run. Reading
	them at call time would let a script swap them out underneath the library, which is the hazard PRIO 1 of
	docs/Standard Library Guidelines.md is about: nothing below may reach a method through a user-visible prototype.
*/
var $defineProperty = support.defineProperty, unconstructable = support.distinctConstructor
		, $getInternalProperty = support.getInternalProperty, $callWithArgs = support.callWithArgs
		, $charCodeAt = support.charCodeAt, $sub = support.substring
		, typeError = TypeError, $Object = Object, $String = String;

// Presence bitmask for a property descriptor; must match PropertyDescriptor::HAS_* in NuXJS.h.
var HAS_VALUE = 1, HAS_WRITABLE = 2, HAS_GET = 4, HAS_SET = 8, HAS_ENUMERABLE = 16, HAS_CONFIGURABLE = 32;

// Built-in methods are writable, non-enumerable, configurable, and (like all standard built-ins) not constructors.
function method(target, key, fn) { $defineProperty(target, key, unconstructable(fn), false, true, false); }

// 9.9 / many 15.2.3.x steps: "If Type(O) is not Object, throw a TypeError exception."
function isObject(v) { return (v !== null && (typeof v === "object" || typeof v === "function")); }

function requireObject(o, what) {
	if (!isObject(o)) throw typeError("Object." + what + " called on non-object");
	return o;
}

/*
	8.10.5 ToPropertyDescriptor, packed positionally as [present, value, get, set, attribs] for the native
	defineOwnProperty `define` hands it to. The attributes object is read through [[Get]], so accessors on it run.
	15.2.3.7 converts every descriptor before defining any of them, so the packed form has to outlive the
	conversion; a named object would spend preserved names on `value`, `get` and `set`.
*/
function toPropertyDescriptor(attrs) {
	if (!isObject(attrs)) throw typeError("Property description must be an object");
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
	return [ present, v, g, s, attribs ];
}

// `key` is already a String at all three call sites, ToString(P) being an earlier and separately ordered step.
function define(o, key, d) { support.defineOwnProperty(o, key, d[0], d[1], d[2], d[3], d[4]); }

/*
	Prototype methods whose first step is CheckObjectCoercible or ToObject on the this value. They must be strict:
	a non-strict function has a null or undefined this substituted with the global object (10.4.3), which would
	make the required TypeError unreachable. Strict mode also makes `arguments` unmapped, which is what the
	"was the argument supplied?" tests below want. Strict also means `this` is undefined in here, so the global
	object comes in as a parameter for the one member below that installs onto it rather than onto a prototype.
*/
(function (globalObject) {
"use strict";

// 9.4 ToInteger, restated verbatim from stdlib.js, which keeps its copy closure-local. 9.6 ToUint32 needs no
// helper: `>>> 0` is that conversion, so `length` is normalised inline below.
var $floor = Math.floor, $isNaN = isNaN, $isFinite = isFinite;
function int(v) { return ($isNaN(v = +v) || v === 0) ? 0 : (!$isFinite(v) ? v : (v < 0 ? -$floor(-v) : $floor(v))); }

// Step 1 of every array method below: ToObject(this), which throws for null and undefined (9.9).
function toObject(v, what) {
	if (v == null) throw typeError("Array.prototype." + what + " called on null or undefined");
	return $Object(v);
}

// "If IsCallable(callbackfn) is false, throw a TypeError exception." Runs after length is read, never before.
function checkCallback(f, what) {
	if (typeof f !== "function") throw typeError("Array.prototype." + what + " callback is not a function");
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
	while (i < j && isSpace($charCodeAt(s, i))) ++i;
	while (j > i && isSpace($charCodeAt(s, j - 1))) --j;
	return $sub(s, i, j);
});

/*
	15.1.2.2 step 2 skips StrWhiteSpace, which 9.3.1 defines as 7.2 WhiteSpace, so parseInt has to accept the same
	set as isSpace above. stdlib.js keeps its own ES3 table for this, closure-local and so out of reach here, and
	editing it would move the es3 binary. Strip the leading run and delegate: everything after step 2, the radix
	rules and the digit loop, is already ES5-correct. String() and not "" + string because step 1 is ToString,
	which for an object with a valueOf is not what the implicit ToPrimitive would pick. parseFloat needs none of
	this, being native and sharing eatStringWhite with the lexer.
*/
var baseParseInt = parseInt;
method(globalObject, "parseInt", function parseInt(string, radix) {
	var s = $String(string), i = 0, n = s.length;
	while (i < n && isSpace($charCodeAt(s, i))) ++i;
	return baseParseInt(i === 0 ? s : $sub(s, i, n), radix);
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
	return "[object " + $getInternalProperty($Object(this), "class") + "]";
});

// 15.9.5.44: fully generic. ES3 had no toJSON at all, and stdlib.js's version reads the receiver's own date value
// rather than going through ToPrimitive and the receiver's own (reassignable) toISOString.
method(Date.prototype, "toJSON", function toJSON(key) {
	var o = $Object(this), tv = support.toPrimitiveNumber(o), toISO;
	if (typeof tv === "number" && !$isFinite(tv)) return null;
	if (typeof (toISO = o.toISOString) !== "function") throw typeError("toISOString is not callable");
	return $callWithArgs(toISO, o);
});

/*
	15.4.4.6-13, the mutators. ES5 passes Throw = true to every [[Put]] and [[Delete]] they make, where the ES3
	editions of the same algorithms had no Throw flag at all, so a refused store was silent. Being strict is exactly
	that flag: 8.7.2 and 11.4.1 turn a refused store or delete into the TypeError the spec asks for. It also stops
	`length` from running ahead of an element that was never stored, on a non-extensible array or past a read-only
	length. The algorithms themselves are unchanged from stdlib.js, holes and array-likes included.
*/
method(Array.prototype, "push", function push(item) {
	var o = toObject(this, "push"), n = o.length >>> 0, argv = arguments;
	for (var i = 0; i < argv.length; ++i) {
		o[n] = argv[i];
		++n;
	}
	o.length = n;
	return n;
});

// 4.a in both pop and shift: an empty array still gets the length store, so a read-only length throws there too.
method(Array.prototype, "pop", function pop() {
	var o = toObject(this, "pop"), len = o.length >>> 0, element;
	if (len !== 0) {
		element = o[--len];
		delete o[len];
	}
	o.length = len;
	return element;
});

method(Array.prototype, "shift", function shift() {
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
});

method(Array.prototype, "unshift", function unshift(item) {
	var o = toObject(this, "unshift"), len = o.length >>> 0, argv = arguments, argc = argv.length, k, to;
	for (k = len; k-- > 0; ) {
		to = k + argc;
		if (k in o) o[to] = o[k]; else delete o[to];
	}
	for (k = 0; k < argc; ++k) o[k] = argv[k];
	return (o.length = len + argc);
});

method(Array.prototype, "reverse", function reverse() {
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
});

// The `length` of splice is 2, so both are formal parameters even though deleteCount is read through `arguments`.
method(Array.prototype, "splice", function splice(start, deleteCount) {
	var o = toObject(this, "splice"), a = [], len = o.length >>> 0, argv = arguments, argc = argv.length, k, n, to;
	if ((start = int(start)) < 0) { if ((start += len) < 0) start = 0; }
	else if (start > len) start = len;
	// 7: min(max(ToInteger(deleteCount), 0), len - start). Taken literally that makes a.splice(i) delete nothing,
	// since ToInteger(undefined) is 0; no engine has ever done that and ES2015 rewrote the step to say len - start,
	// which is what stdlib.js does too, so es5 keeps it. With no arguments at all nothing is deleted either.
	var count = (argc === 0 ? 0 : argc === 1 ? len - start : int(deleteCount));
	if (count < 0) count = 0;
	else if (count > len - start) count = len - start;
	for (k = 0; k < count; ++k) if (start + k in o) a[k] = o[start + k];
	a.length = count;	// 15.4.4.12 omits this step, but every edition since sets it, and so does stdlib.js
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
});

/*
	15.4.4.11. The ordering itself is unchanged, so this hands the present elements to the base sort and then writes
	the permutation back strictly, which is what supplies the Throw flag. SortCompare's ranking falls out of that:
	the base comparator already sorts undefined last, and lifting the holes out puts them after even those.
*/
var $sort = Array.prototype.sort;

method(Array.prototype, "sort", function sort(comparefn) {
	var o = toObject(this, "sort"), len = o.length >>> 0, v = [], k;
	if (len < 2) return o;	// nothing can move, so nothing is stored: a frozen empty or single array must not throw
	for (k = 0; k < len; ++k) if (k in o) v[v.length] = o[k];
	$callWithArgs($sort, v, arguments);
	for (k = 0; k < v.length; ++k) o[k] = v[k];
	for (; k < len; ++k) delete o[k];
	return o;
});

/*
	15.4.4.14-22. All nine are generic over array-likes, read length once up front, and visit only indices that
	are actually present, so holes are skipped rather than passed as undefined. Each declares exactly one formal
	parameter because the spec fixes its `length` at 1; the optional second argument comes from `arguments`.

	The callback takes (element, index, O), so `args` below is one scratch argument list per call rather than per
	element: callWithArgs copies it into the callee's frame before invoking and never retains it.
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
	var o = toObject(this, "every"), len = o.length >>> 0, f = checkCallback(callbackfn, "every"), t = arguments[1]
			, args = [ 0, 0, o ];
	for (var k = 0; k < len; ++k) {
		if (k in o) { args[0] = o[k]; args[1] = k; if (!$callWithArgs(f, t, args)) return false; }
	}
	return true;
});

method(Array.prototype, "some", function some(callbackfn) {
	var o = toObject(this, "some"), len = o.length >>> 0, f = checkCallback(callbackfn, "some"), t = arguments[1]
			, args = [ 0, 0, o ];
	for (var k = 0; k < len; ++k) {
		if (k in o) { args[0] = o[k]; args[1] = k; if ($callWithArgs(f, t, args)) return true; }
	}
	return false;
});

method(Array.prototype, "forEach", function forEach(callbackfn) {
	var o = toObject(this, "forEach"), len = o.length >>> 0, f = checkCallback(callbackfn, "forEach")
			, t = arguments[1], args = [ 0, 0, o ];
	for (var k = 0; k < len; ++k) if (k in o) { args[0] = o[k]; args[1] = k; $callWithArgs(f, t, args); }
});

method(Array.prototype, "map", function map(callbackfn) {
	var o = toObject(this, "map"), len = o.length >>> 0, f = checkCallback(callbackfn, "map"), t = arguments[1]
			, args = [ 0, 0, o ], a = [];
	a.length = len;	// 6: length is fixed up front, so a hole in the source stays a hole in the result
	for (var k = 0; k < len; ++k) if (k in o) { args[0] = o[k]; args[1] = k; a[k] = $callWithArgs(f, t, args); }
	return a;
});

method(Array.prototype, "filter", function filter(callbackfn) {
	var o = toObject(this, "filter"), len = o.length >>> 0, f = checkCallback(callbackfn, "filter")
			, t = arguments[1], args = [ 0, 0, o ], a = [], to = 0, v;	// 8: `to` packs the result densely, unlike map
	for (var k = 0; k < len; ++k) {
		if (k in o) { args[0] = v = o[k]; args[1] = k; if ($callWithArgs(f, t, args)) a[to++] = v; }
	}
	return a;
});

/*
	reduce / reduceRight take four callback arguments and no thisArg, so the callback is called as a function.
	With no initialValue the first present element seeds the accumulator; if there is none, that is a TypeError,
	which also covers step 5 (empty and unseeded) without a second test.
*/
method(Array.prototype, "reduce", function reduce(callbackfn) {
	var o = toObject(this, "reduce"), len = o.length >>> 0, f = checkCallback(callbackfn, "reduce")
			, k = 0, seeded = (arguments.length > 1), acc = arguments[1], args = [ 0, 0, 0, o ];
	while (!seeded && k < len) { if (seeded = (k in o)) acc = o[k]; ++k; }
	if (!seeded) throw typeError("Reduce of empty array with no initial value");
	for (; k < len; ++k) {
		if (k in o) { args[0] = acc; args[1] = o[k]; args[2] = k; acc = $callWithArgs(f, null, args); }
	}
	return acc;
});

method(Array.prototype, "reduceRight", function reduceRight(callbackfn) {
	var o = toObject(this, "reduceRight"), len = o.length >>> 0, f = checkCallback(callbackfn, "reduceRight")
			, k = len - 1, seeded = (arguments.length > 1), acc = arguments[1], args = [ 0, 0, 0, o ];
	while (!seeded && k >= 0) { if (seeded = (k in o)) acc = o[k]; --k; }
	if (!seeded) throw typeError("Reduce of empty array with no initial value");
	for (; k >= 0; --k) {
		if (k in o) { args[0] = acc; args[1] = o[k]; args[2] = k; acc = $callWithArgs(f, null, args); }
	}
	return acc;
});

})(this);

/*
	15.2.3.7 steps 3-6. Every descriptor is converted before any of them is defined, so a malformed one later in
	the list leaves the properties ahead of it untouched. `pairs` holds name and packed descriptor in alternating
	slots, the enumeration order of step 3 being for-in order by the note under the algorithm.
*/
function defineAll(o, properties) {
	var props = $Object(properties), pairs = [], p, i, n;
	for (p in props) {
		if (support.hasOwnProperty(props, p)) {
			pairs[pairs.length] = p;
			pairs[pairs.length] = toPropertyDescriptor(props[p]);
		}
	}
	for (i = 0, n = pairs.length; i < n; i += 2) define(o, pairs[i], pairs[i + 1]);
	return o;
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
	return support.preventExtensions(o);
}

function isLockedDown(o, what, frozen) {
	var names = support.getOwnPropertyNames(requireObject(o, what)), i, d;
	for (i = names.length; --i >= 0; ) {
		d = support.getOwnPropertyDescriptor(o, names[i]);
		if (d.configurable || (frozen && ("value" in d) && d.writable)) return false;
	}
	return !support.isExtensible(o);
}

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
	define(o, "" + p, toPropertyDescriptor(attributes));	// 2 before 3: ToString(P) runs before ToPropertyDescriptor
	return o;
});

// 15.2.3.7 Object.defineProperties
method(Object, "defineProperties", function defineProperties(o, properties) {
	return defineAll(requireObject(o, "defineProperties"), properties);
});

// 15.2.3.2 Object.getPrototypeOf (stdlib.js has a version without the non-object check; override for strictness)
method(Object, "getPrototypeOf", function getPrototypeOf(o) {
	return $getInternalProperty(requireObject(o, "getPrototypeOf"), "prototype");
});

// 15.2.3.3 Object.getOwnPropertyDescriptor
method(Object, "getOwnPropertyDescriptor", function getOwnPropertyDescriptor(o, p) {
	return support.getOwnPropertyDescriptor(requireObject(o, "getOwnPropertyDescriptor"), "" + p);
});

// 15.2.3.4 Object.getOwnPropertyNames: all own string-keyed names, including non-enumerable ones.
method(Object, "getOwnPropertyNames", function getOwnPropertyNames(o) {
	return support.getOwnPropertyNames(requireObject(o, "getOwnPropertyNames"));
});

// 15.2.3.14 Object.keys: own enumerable string-keyed property names, in for-in order.
method(Object, "keys", function keys(o) {
	requireObject(o, "keys");
	var result = [], k;
	for (k in o) if (support.hasOwnProperty(o, k)) result[result.length] = k;
	return result;
});

// 15.2.3.5 Object.create
method(Object, "create", function create(o, properties) {
	if (o !== null && !isObject(o)) throw typeError("Object.create: prototype must be an object or null");
	var obj = support.createObject(o);
	return (properties === void 0 ? obj : defineAll(obj, properties));
});

method(Object, "seal", function seal(o) { return lockDown(o, "seal", false); });
method(Object, "freeze", function freeze(o) { return lockDown(o, "freeze", true); });
method(Object, "isSealed", function isSealed(o) { return isLockedDown(o, "isSealed", false); });
method(Object, "isFrozen", function isFrozen(o) { return isLockedDown(o, "isFrozen", true); });

// 15.9.4.4 Date.now: the time value at the moment of the call, which ES3 had no equivalent of.
method(Date, "now", function now() { return support.getCurrentTime(); });

// 15.1.1.1-3: ES5 made the global NaN, Infinity and undefined non-writable. ES3 15.1.1 left them writable, so
// stdlib.js installs them with dontEnum + dontDelete only; re-define them here with readOnly added.
$defineProperty(this, "NaN", this.NaN, true, true, true);
$defineProperty(this, "Infinity", this.Infinity, true, true, true);
$defineProperty(this, "undefined", this.undefined, true, true, true);

})
