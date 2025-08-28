/*
ES5 additions to the standard library.
This file is appended into stdlib.js at build time when present (see tools/stdlibToCpp.pika).
It runs inside the stdlib IIFE and can access helpers like defineProperties, str, $sub, int, uint32, etc.

# Renaming rules must match stdlib.js minifier expectations. We preserve core language keywords
# and helper names used across both files so the generated ES5 code parses and binds within the
# stdlib IIFE lexical scope. Do not preserve `unconstructable` so it aliases to the same short
# name as in stdlib.js (currently `d`).

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

@preserve: String,Array,Object,Date,JSON,Function
@preserve: str,$sub,int,uint32,$getInternalProperty
@preserve: trim,trimLeft,trimRight,forEach,map,filter,indexOf,lastIndexOf,reduce,reduceRight,every,some
@preserve: now,defineProperty,defineProperties,create,keys,getPrototypeOf,get,set
*/

// Local helper: mirror stdlib.js defineProperties so we can use it below
function defineProperties(object, attribs, props) {
var ro = attribs.readOnly, de = attribs.dontEnum, dd = attribs.dontDelete;
for (var p in props) support.defineProperty(object, p, props[p], ro, de, dd);
return object;
}

// String.prototype.trim*, added to the existing String prototype
defineProperties(String.prototype, { dontEnum: true }, {
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
})
});

// Array.prototype iteration and search methods
defineProperties(Array.prototype, { dontEnum: true }, {
forEach: unconstructable(function forEach(callbackfn) { // .length should be 1
var o = Object(this), len = uint32(o.length), t = arguments[1];
if (typeof callbackfn !== "function") throw TypeError();
for (var k = 0; k < len; ++k) if (k in o) callbackfn.call(t, o[k], k, o);
}),
map: unconstructable(function map(callbackfn) { // .length should be 1
var o = Object(this), len = uint32(o.length), t = arguments[1], a = new Array(len);
if (typeof callbackfn !== "function") throw TypeError();
for (var k = 0; k < len; ++k) if (k in o) a[k] = callbackfn.call(t, o[k], k, o);
return a;
}),
filter: unconstructable(function filter(callbackfn) { // .length should be 1
var o = Object(this), len = uint32(o.length), t = arguments[1], a = [], to = 0;
if (typeof callbackfn !== "function") throw TypeError();
for (var k = 0; k < len; ++k) if (k in o) { var v = o[k]; if (callbackfn.call(t, v, k, o)) a[to++] = v; }
a.length = to;
return a;
}),
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
}),
reduce: unconstructable(function reduce(callbackfn) { // .length should be 1
var o = Object(this), len = uint32(o.length), k = 0, acc;
if (typeof callbackfn !== "function") throw TypeError();
if (arguments.length > 1) acc = arguments[1]; else {
while (k < len && !(k in o)) ++k;
if (k >= len) throw TypeError();
acc = o[k++];
}
for (; k < len; ++k) if (k in o) acc = callbackfn.call(void 0, acc, o[k], k, o);
return acc;
}),
reduceRight: unconstructable(function reduceRight(callbackfn) { // .length should be 1
var o = Object(this), len = uint32(o.length), k = len - 1, acc;
if (typeof callbackfn !== "function") throw TypeError();
if (arguments.length > 1) acc = arguments[1]; else {
while (k >= 0 && !(k in o)) --k;
if (k < 0) throw TypeError();
acc = o[k--];
}
for (; k >= 0; --k) if (k in o) acc = callbackfn.call(void 0, acc, o[k], k, o);
return acc;
}),
every: unconstructable(function every(callbackfn) { // .length should be 1
var o = Object(this), len = uint32(o.length), t = arguments[1];
if (typeof callbackfn !== "function") throw TypeError();
for (var k = 0; k < len; ++k) if (k in o && !callbackfn.call(t, o[k], k, o)) return false;
return true;
}),
some: unconstructable(function some(callbackfn) { // .length should be 1
var o = Object(this), len = uint32(o.length), t = arguments[1];
if (typeof callbackfn !== "function") throw TypeError();
for (var k = 0; k < len; ++k) if (k in o && callbackfn.call(t, o[k], k, o)) return true;
return false;
})
});

// Date.now
defineProperties(Date, { dontEnum: true }, {
now: unconstructable(function now() { return support.getCurrentTime(); })
});

// Object helpers: defineProperty (accessors), defineProperties, create, keys
defineProperties(Object, {dontEnum : true}, {
defineProperty : unconstructable(function defineProperty(o, p, d) {
var k = str(p);
var ro = !d.writable, de = !d.enumerable, dd = !d.configurable;
if ("get" in d || "set" in d) {
if ("value" in d || "writable" in d) throw TypeError();
var g = d.get; var s = d.set;
if (g !== undefined && typeof g !== "function") throw TypeError();
if (s !== undefined && typeof s !== "function") throw TypeError();
support.defineProperty(o, k, undefined, ro, de, dd, g, s);
} else {
support.defineProperty(o, k, d.value, ro, de, dd);
}
}),
defineProperties : unconstructable(function defineProperties(o, props) {
if (o === undefined || o === null) throw TypeError();
var obj = Object(o);
for (var k in props) {
if (Object.prototype.hasOwnProperty.call(props, k)) Object.defineProperty(obj, k, props[k]);
}
return obj;
}),
create : unconstructable(function create(proto, properties) {
if (proto === null) throw TypeError();
var t = typeof proto;
if (t !== "object" && t !== "function") throw TypeError();
var o = support.createWrapper("Object", void 0, proto);
if (properties !== void 0) Object.defineProperties(o, Object(properties));
return o;
}),
keys : unconstructable(function keys(o) {
if (o === undefined || o === null) throw TypeError();
var obj = Object(o); var res = []; var k;
for (k in obj) if (Object.prototype.hasOwnProperty.call(obj, k)) res[res.length] = k;
return res;
})
});
