/*
ES5 additions to the standard library.
This file is "included" with an eval at the end of stdlib.js if ES5 support is enabled.

@preserve: trim,trimLeft,trimRight,forEach,map,filter,reduce,reduceRight,every,some
@preserve: get,set
@preserve: now,create,getOwnPropertyDescriptor,getOwnPropertyNames,keys,preventExtensions,isExtensible,bind
@preserve: defineProperties
*/

// Use helpers provided by the base stdlib: defProps, int, uint32, str

// ES5 `Object.prototype.toString`
defProps(Object.prototype, { dontEnum: true }, {
	toString: unconstructable(function toString() {
		return "[object " + $getInternalProperty(this, "class") + ']';
	})
});

// String.prototype.trim*
defProps(String.prototype, { dontEnum: true }, {
	trimLeft: function trimLeft() {
		var s = str(this), i = 0, j = s.length, c;
		for (; i < j; ++i) {
			c = s.charCodeAt(i);
			if (c !== 0x20 && (c < 0x09 || c > 0x0D) && c !== 0xA0 && c !== 0x2028 && c !== 0x2029 && c !== 0xFEFF) break;
		}
		return s.substring(i, j);
	},
	trimRight: function trimRight() {
		var s = str(this), j = s.length, c;
		for (; j > 0; --j) {
			c = s.charCodeAt(j - 1);
			if (c !== 0x20 && (c < 0x09 || c > 0x0D) && c !== 0xA0 && c !== 0x2028 && c !== 0x2029 && c !== 0xFEFF) break;
		}
		return s.substring(0, j);
	},
	trim: function trim() {
		var s = str(this), i = 0, j = s.length, c;
		for (; i < j; ++i) {
			c = s.charCodeAt(i);
			if (c !== 0x20 && (c < 0x09 || c > 0x0D) && c !== 0xA0 && c !== 0x2028 && c !== 0x2029 && c !== 0xFEFF) break;
		}
		for (; j > i; --j) {
			c = s.charCodeAt(j - 1);
			if (c !== 0x20 && (c < 0x09 || c > 0x0D) && c !== 0xA0 && c !== 0x2028 && c !== 0x2029 && c !== 0xFEFF) break;
		}
		return s.substring(i, j);
	}
});

// Array.prototype iteration and search methods
defProps(Array.prototype, { dontEnum: true }, {
	forEach: function forEach(callbackfn) {
		var o = Object(this), len = uint32(o.length), t = arguments[1];
		if (typeof callbackfn !== "function") throw TypeError();
		for (var k = 0; k < len; ++k) if (k in o) callbackfn.call(t, o[k], k, o);
	},
	map: function map(callbackfn) {
		var o = Object(this), len = uint32(o.length), t = arguments[1], a = new Array(len);
		if (typeof callbackfn !== "function") throw TypeError();
		for (var k = 0; k < len; ++k) if (k in o) a[k] = callbackfn.call(t, o[k], k, o);
		return a;
	},
	filter: function filter(callbackfn) {
		var o = Object(this), len = uint32(o.length), t = arguments[1], a = [], to = 0;
		if (typeof callbackfn !== "function") throw TypeError();
		for (var k = 0; k < len; ++k) if (k in o) { var v = o[k]; if (callbackfn.call(t, v, k, o)) a[to++] = v; }
		a.length = to;
		return a;
	},
	indexOf: function indexOf(searchElement) {
		var len = uint32(this.length), i = arguments[1];
		if (len === 0) return -1;
		i = int(i);
		if (i < 0) { i += len; if (i < 0) i = 0; }
		for (; i < len; ++i) if (i in this && this[i] === searchElement) return i;
		return -1;
	},
	lastIndexOf: function lastIndexOf(searchElement) {
		var len = uint32(this.length), i = arguments[1];
		if (len === 0) return -1;
		if (i === void 0) i = len - 1; else { i = int(i); if (i < 0) i += len; if (i >= len) i = len - 1; }
		for (; i >= 0; --i) if (i in this && this[i] === searchElement) return i;
		return -1;
	},
	reduce: function reduce(callbackfn) {
		var o = Object(this), len = uint32(o.length), k = 0, acc;
		if (typeof callbackfn !== "function") throw TypeError();
		if (arguments.length > 1) acc = arguments[1]; else {
			while (k < len && !(k in o)) ++k;
			if (k >= len) throw TypeError();
			acc = o[k++];
		}
		for (; k < len; ++k) if (k in o) acc = callbackfn.call(void 0, acc, o[k], k, o);
		return acc;
	},
	reduceRight: function reduceRight(callbackfn) {
		var o = Object(this), len = uint32(o.length), k = len - 1, acc;
		if (typeof callbackfn !== "function") throw TypeError();
		if (arguments.length > 1) acc = arguments[1]; else {
			while (k >= 0 && !(k in o)) --k;
			if (k < 0) throw TypeError();
			acc = o[k--];
		}
		for (; k >= 0; --k) if (k in o) acc = callbackfn.call(void 0, acc, o[k], k, o);
		return acc;
	},
	every: function every(callbackfn) {
		var o = Object(this), len = uint32(o.length), t = arguments[1];
		if (typeof callbackfn !== "function") throw TypeError();
		for (var k = 0; k < len; ++k) if (k in o && !callbackfn.call(t, o[k], k, o)) return false;
		return true;
	},
	some: function some(callbackfn) {
		var o = Object(this), len = uint32(o.length), t = arguments[1];
		if (typeof callbackfn !== "function") throw TypeError();
		for (var k = 0; k < len; ++k) if (k in o && callbackfn.call(t, o[k], k, o)) return true;
		return false;
	}
});

// Date.now
defProps(Date, { dontEnum: true }, {
	now: function now() { return new Date().getTime(); }
});

// Date.prototype.toISOString/toJSON
defProps(Date.prototype, { dontEnum: true }, {
toISOString: function toISOString() {
			var t = this.getTime();
if (!$isFinite(t)) throw RangeError("Invalid time value");
		function pad(num, len) {
			var s = '' + num;
			while (s.length < len) s = '0' + s;
			return s;
		}
		var y = this.getUTCFullYear();
		var m = this.getUTCMonth() + 1;
		var d = this.getUTCDate();
		var h = this.getUTCHours();
		var min = this.getUTCMinutes();
		var s = this.getUTCSeconds();
		var ms = this.getUTCMilliseconds();
		var year = (y >= 0 && y <= 9999 ? pad(y, 4)
				: (y < 0 ? '-' : '+') + pad(Math.abs(y), 6));
		return year + '-' + pad(m, 2) + '-' + pad(d, 2) + 'T'
				+ pad(h, 2) + ':' + pad(min, 2) + ':' + pad(s, 2)
				+ '.' + pad(ms, 3) + 'Z';
	},
		toJSON: function toJSON(key) {
				var O = Object(this);
				var tv = support.toPrimitiveNumber(O);
				if (typeof tv === "number" && !$isFinite(tv)) return null;
				var toISO = O.toISOString;
				if (typeof toISO !== "function") throw TypeError();
				return toISO.call(O);
		}
});

// Number.prototype.toJSON
defProps(Number.prototype, { dontEnum: true }, {
		toJSON: function toJSON() {
				var n = support.toPrimitiveNumber(this);
				return $isFinite(n) ? n : null;
		}
});

// String.prototype.toJSON
defProps(String.prototype, { dontEnum: true }, {
		toJSON: function toJSON() {
			return support.toPrimitiveString(this);
		}
});

// Boolean.prototype.toJSON
defProps(Boolean.prototype, { dontEnum: true }, {
		toJSON: function toJSON() {
			return !!support.toPrimitiveNumber(this);
		}
});
// Number.isFinite/Number.isNaN
defProps(Number, { dontEnum: true }, {
	isFinite: unconstructable(function isFinite(n) { return typeof n === "number" && $isFinite(n); }),
	isNaN: unconstructable(function isNaN(n) { return typeof n === "number" && $isNaN(n); })
});

// Object helpers: defineProperty (accessors), defineProperties, create, getOwnPropertyDescriptor, keys, preventExtensions, isExtensible
defProps(Object, { dontEnum: true }, {
	defineProperty: unconstructable(function defineProperty(o, p, d) {
		if (o === undefined || o === null) throw TypeError();
		support.defineProperty(Object(o), str(p), d);
	}),
	defineProperties: unconstructable(function defineProperties(o, props) {
		if (o === undefined || o === null) throw TypeError();
		var obj = Object(o);
		for (var k in props) if (Object.prototype.hasOwnProperty.call(props, k)) Object.defineProperty(obj, k, props[k]);
		return obj;
	}),
		create: unconstructable(function create(proto, properties) {
			var t = typeof proto;
			if (proto !== null && t !== "object" && t !== "function") throw TypeError();
			var o = support.createObject(proto);
			if (properties !== void 0) Object.defineProperties(o, Object(properties));
			return o;
		}),
		getOwnPropertyDescriptor: unconstructable(function getOwnPropertyDescriptor(o, p) {
				if (o === undefined || o === null) throw TypeError();
				return support.getOwnPropertyDescriptor(Object(o), str(p));
		}),
		getOwnPropertyNames: unconstructable(function getOwnPropertyNames(o) {
				if (o === undefined || o === null) throw TypeError();
				return support.getOwnPropertyNames(Object(o));
		}),
			keys: unconstructable(function keys(o) {
				if (o === undefined || o === null) throw TypeError();
				var obj = Object(o), res = [], k;
				for (k in obj) if (Object.prototype.hasOwnProperty.call(obj, k)) res[res.length] = k;
				return res;
}),
			preventExtensions: unconstructable(function preventExtensions(o) {
				if (o === undefined || o === null) throw TypeError();
				return support.preventExtensions(Object(o));
}),
			isExtensible: unconstructable(function isExtensible(o) {
				if (o === undefined || o === null) throw TypeError();
				return support.isExtensible(Object(o));
		}),
		seal: unconstructable(function seal(o) {
			if (o === undefined || o === null) throw TypeError();
			return support.seal(Object(o));
		}),
		freeze: unconstructable(function freeze(o) {
			if (o === undefined || o === null) throw TypeError();
			return support.freeze(Object(o));
		}),
		isSealed: unconstructable(function isSealed(o) {
			if (o === undefined || o === null) throw TypeError();
			return support.isSealed(Object(o));
		}),
		isFrozen: unconstructable(function isFrozen(o) {
			if (o === undefined || o === null) throw TypeError();
			return support.isFrozen(Object(o));
		})
});

// Function.prototype.bind (minimal, declared with one formal parameter)
defProps(Function.prototype, { dontEnum: true }, {
        bind: function bind(thisArg) {
                var target = this;
                if (typeof target !== 'function') throw TypeError();
                var args = [target, thisArg];
                for (var i = 1; i < arguments.length; ++i) args[args.length] = arguments[i];
                return support.bind.apply(null, args);
        }
});

// Function.prototype.name accessor
delete Function.prototype.name;
support.defineProperty(Function.prototype, "name", {
	get: unconstructable(function name() {
		if (typeof this !== "function") throw TypeError();
		var d = support.getOwnPropertyDescriptor(this, "name");
		return d && "value" in d ? d.value : "";
	}),
	configurable: true
});
