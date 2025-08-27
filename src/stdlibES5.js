/*
ES5 additions to the standard library.
This file is appended to stdlib.js by tools/stdlibToCpp.pika.

@preserve: indexOf,lastIndexOf
*/

Q(Array.prototype, {
indexOf: unconstructable(function indexOf(searchElement) {
var len = uint32(this.length), i = arguments[1];
if (len === 0) return -1;
if ((i = int(i)) < 0) { i += len; if (i < 0) i = 0; }
for (; i < len; ++i) if (i in this && this[i] === searchElement) return i;
return -1;
}),
lastIndexOf: unconstructable(function lastIndexOf(searchElement) {
var len = uint32(this.length), i = arguments[1];
if (len === 0) return -1;
if (i === void 0) i = len - 1; else { i = int(i); if (i < 0) i += len; if (i >= len) i = len - 1; }
for (; i >= 0; --i) if (i in this && this[i] === searchElement) return i;
return -1;
})
});

