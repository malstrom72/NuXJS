/*
	ES5.1 additions to the standard library.

	Compiled into STDLIB_ES5_JS and run only in NUXJS_ES5 builds, as a standalone module that receives the same
	native `support` bridge as stdlib.js and runs with `this` bound to the global object. The ES3 stdlib.js is
	never touched, so the ES3 embedding stays byte-for-byte identical. This module may use the native `support`
	hooks and the globals stdlib.js has already installed, but not stdlib.js's private (closure-local) helpers.

	@preserve: trim,preventExtensions,isExtensible
*/
(function (support) {

var $defineProperty = support.defineProperty;

function method(target, name, fn) { $defineProperty(target, name, fn, false, true, false); }

// 9.9 / many 15.2.3.x steps: "If Type(O) is not Object, throw a TypeError exception."
function requireObject(o, name) {
	if (o === null || (typeof o !== "object" && typeof o !== "function")) {
		throw new TypeError("Object." + name + " called on non-object");
	}
	return o;
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

})
