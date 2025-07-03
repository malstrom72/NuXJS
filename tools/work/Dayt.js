"use strict"

/***
	Date object in javascript
***/



var $toPrimitive = function(v) { return (!$isPrimitive(v) ? $support.toPrimitiveNumber(v) : v); };

var $isNaN = isNaN;
var $isFinite = isFinite;
var $floor = Math.floor;
var $NaN = NaN;
var $Now = Date.now();
var $Infinity = Infinity;



function $isPrimitive(v) {
	var v, t;
	return (((t = typeof v) !== "object" || v === null) && t !== "function");
}

// Date Object

var Dayt = function Dayt(year, month, date, hours, minutes, seconds, ms) {
	var v;
	if (!(this instanceof Dayt)) {
		return (new Dayt()).toString()
	} else if (arguments.length >= 2 && arguments.length <= 7) {
		this.Value = $timeClip($fromLocalTime($makeDateTime.apply(this, arguments)));
	} else if (arguments.length === 1) {
		this.Value = $timeClip(typeof (v = $toPrimitive(arguments[0])) === "String" ? this.parse(v) : +v);
	} else {
		this.Value = $Now;
	}
};
Dayt.parse = function(s) { throw "Not implemented"; };
Dayt.UTC = function(year, month, date, hours, minutes, seconds, ms) { 
	return $timeClip($makeDateTime(year, month, date, hours, minutes, seconds, ms));
};
Dayt.prototype.toISOString = function() {
	var z, y, dt, tm;
	if ($isNaN(z = this.Value)) throw RangeError("Invalid time value");
	return (0 <= (y = (dt = $dateFromEpoch(z))[0]) && y <= 9999 ? ("000" + y).slice(-4) :
		(y < 0 ? "-" : "+") + ("00000" + Math.abs(y)).slice(-6)) +
		"-" + ("0" + (dt[1] + 1)).slice(-2) + 
		"-" + ("0" + dt[2]).slice(-2) +
		"T" + ("0" + (tm = $timeFromEpoch(z))[0]).slice(-2) +
		":" + ("0" + tm[1]).slice(-2) +
		":" + ("0" + tm[2]).slice(-2) +
		"." + ("00" + String(tm[3]).slice(0,3)).slice(-3) + "Z";
};
Dayt.prototype.toUTCString = function() {
	var z, tm, dt;
	if ($isNaN(z = this.Value)) return "Invalid Date";
	return $_weekDayNames[$weekdayFromTime(z)] + 
		", " + ("0" + (dt = $dateFromEpoch(z))[2]).slice(-2) + 
		" " + $_monthNames[dt[1]] + 
		" " + dt[0] +
		" " + ("0" + (tm = $timeFromEpoch(z))[0]).slice(-2) +
		":" + ("0" + tm[1]).slice(-2) +
		":" + ("0" + tm[2]).slice(-2) +
		" GMT";
};
Dayt.prototype.toString = function() {
	if ($isNaN(this.Value)) return "Invalid Date";
	return (this.toDateString() + " " + this.toTimeString());
};
Dayt.prototype.toDateString = function() {
	var l, dt;
	if ($isNaN(l = $toLocalTime(this.Value))) return "Invalid Date";
	return $_weekDayNames[$weekdayFromTime(l)] + 
		" " + $_monthNames[(dt = $dateFromEpoch(l))[1]] + 
		" " + ("0" + dt[2]).slice(-2) + 
		" " + dt[0];
};
Dayt.prototype.toTimeString = function() {
	var l, z, tm, tz;
	if ($isNaN(l = $toLocalTime(z = this.Value))) return "Invalid Date";
	return ("0" + (tm = $timeFromEpoch(l))[0]).slice(-2) +
		":" + ("0" + tm[1]).slice(-2) +
		":" + ("0" + tm[2]).slice(-2) +
		" GMT" + ((tz = $floor(($support.localTZA() + $support.localDST(z)) * 100 / $msPerHour)) !== 0 ?
			(tz < 0 ? "-" : "+") + ("000" + Math.abs(tz)).slice(-4) +
			" (" + $support.localTZName(z) + ")" : "");
};
Dayt.prototype.toLocaleString = Dayt.prototype.toString;
Dayt.prototype.toLocaleDateString = Dayt.prototype.toDateString;
Dayt.prototype.toLocaleTimeString = Dayt.prototype.toTimeString;

Dayt.prototype.valueOf = function() { return this.Value; };
Dayt.prototype.getTime = function() { if (!(this instanceof Dayt)) throw TypeError("this is not a Date object."); return this.Value; };
Dayt.prototype.getFullYear = function() { return $dateFromEpoch($toLocalTime(this.Value))[0]; };
Dayt.prototype.getUTCFullYear = function() { return $dateFromEpoch(this.Value)[0]; };
Dayt.prototype.getMonth = function() { return $dateFromEpoch($toLocalTime(this.Value))[1]; };
Dayt.prototype.getUTCMonth = function() { return $dateFromEpoch(this.Value)[1]; };
Dayt.prototype.getDate = function() { return $dateFromEpoch($toLocalTime(this.Value))[2]; };
Dayt.prototype.getUTCDate = function() { return $dateFromEpoch(this.Value)[2]; };
Dayt.prototype.getDay = function() { return $weekdayFromTime($toLocalTime(this.Value)); };
Dayt.prototype.getUTCDay = function() { return $weekdayFromTime(this.Value); };
Dayt.prototype.getHours = function() { return $hourFromTime($toLocalTime(this.Value)); };
Dayt.prototype.getUTCHours = function() { return $hourFromTime(this.Value); };
Dayt.prototype.getMinutes = function() { return $minFromTime($toLocalTime(this.Value)); };
Dayt.prototype.getUTCMinutes = function() { return $minFromTime(this.Value); };
Dayt.prototype.getSeconds = function() { return $secFromTime($toLocalTime(this.Value)); };
Dayt.prototype.getUTCSeconds = function() { return $secFromTime(this.Value); };
Dayt.prototype.getMilliseconds = function() { return $msFromTime($toLocalTime(this.Value)); };
Dayt.prototype.getUTCMilliseconds = function() { return $msFromTime(this.Value); };
Dayt.prototype.getTimezoneOffset = function() { return (this.Value - $toLocalTime(this.Value)) / $msPerMinute; };

Dayt.prototype.setTime = function(time) {
	if (!(this instanceof Dayt)) throw TypeError("this is not a Date object.");
	return (this.Value = $timeClip(+time));
};
Dayt.prototype.setMilliseconds = function(ms) { return (this.Value = $timeClip($fromLocalTime($setTimeParts($toLocalTime(this.Value), 3, arguments)))); };
Dayt.prototype.setUTCMilliseconds = function(ms) { return (this.Value = $timeClip($setTimeParts(this.Value, 3, arguments))); };
Dayt.prototype.setSeconds = function(sec, ms) { return (this.Value = $timeClip($fromLocalTime($setTimeParts($toLocalTime(this.Value), 2, arguments)))); };
Dayt.prototype.setUTCSeconds = function(sec, ms) { return (this.Value = $timeClip($setTimeParts(this.Value, 2, arguments))); };
Dayt.prototype.setMinutes = function(min, sec, ms) { return (this.Value = $timeClip($fromLocalTime($setTimeParts($toLocalTime(this.Value), 1, arguments)))); };
Dayt.prototype.setUTCMinutes = function(min, sec, ms) { return (this.Value = $timeClip($setTimeParts(this.Value, 1, arguments))); };
Dayt.prototype.setHours = function(hour, min, sec, ms) { return (this.Value = $timeClip($fromLocalTime($setTimeParts($toLocalTime(this.Value), 0, arguments)))); };
Dayt.prototype.setUTCHours = function(hour, min, sec, ms) { return (this.Value = $timeClip($setTimeParts(this.Value, 0, arguments))); };
Dayt.prototype.setDate = function(date) { return (this.Value = $timeClip($fromLocalTime($setDateParts($toLocalTime(this.Value), 2, arguments)))); };
Dayt.prototype.setUTCDate = function(date) { return (this.Value = $timeClip($setDateParts(this.Value, 2, arguments))); };
Dayt.prototype.setMonth = function(month, date) { return (this.Value = $timeClip($fromLocalTime($setDateParts($toLocalTime(this.Value), 1, arguments)))); };
Dayt.prototype.setUTCMonth = function(month, date) { return (this.Value = $timeClip($setDateParts(this.Value, 1, arguments))); };
Dayt.prototype.setFullYear = function(year, month, date) { return (this.Value = $timeClip($fromLocalTime($setDateParts($isNaN(this.Value) ? 0 : $toLocalTime(this.Value), 0, arguments)))); };
Dayt.prototype.setUTCFullYear = function(year, month, date) { return (this.Value = $timeClip($setDateParts($isNaN(this.Value) ? 0 : this.Value, 0, arguments))); };

// Support functions
var $support = {
	toPrimitiveNumber:function toPrimitiveNumber(o) {
		var f, v;
		if ((typeof (f = o.valueOf) !== 'function' || !$isPrimitive(v = o.valueOf()))
				&& (typeof (f = o.toString) !== 'function' || !$isPrimitive(v = o.toString()))) {
			throw TypeError("Error converting object to primitive type");
		}
		return v;
	},
	time:function time() { return Date.now(); },
	localTZA:function localTZA() {
		// LocalTZA measured in milliseconds which when added to UTC represents the local standard time 
		return -Math.max(
	    	(new Date((new Date).getFullYear(), 0, 1)).getTimezoneOffset(),
	    	(new Date((new Date).getFullYear(), 6, 1)).getTimezoneOffset()
    	) * 60000;
    },
    localDST:function localDST(t) {
    	// Returns the DST time adjustment (ms) for a UTC time (t)
		return -$support.localTZA() - (new Date(t)).getTimezoneOffset() * 60000;
	},
	localTZName:function localTZname(t) {
		return ($support.localDST(t) > 0 ? "CEST" : "CET");
	},
};

var $msPerDay = 86400000,
	$msPerHour = 3600000,
	$msPerMinute = 60000,
	$msPerSecond = 1000,
	$_weekDayNames = [ "Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat" ],
	$_monthNames = [ "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec" ],
	$mod = function(x, n) { return ((x %= n) < 0 ? (x + n) % n : x); },
	$int = function(v) { return (!$isFinite(v = +v) ? $NaN : (v < 0 ? -$floor(-v) : $floor(v))); },
	$epochFromDate = function(year, month, day) {
		year += $floor(month / 12) - ((month = ((month %= 12) < 0 ? (12 + month) % 12 : month)) <= 1);
		var era = $int( (year >= 0 ? year : year - 399) / 400 );
		var yoe = year - era * 400;
		var doy = $int( (153 * (month + (month > 1 ? -2 : 10)) + 2) / 5 ) + day-1;
		var doe = yoe * 365 + $int(yoe / 4) - $int(yoe / 100) + doy;
		return (era * 146097 + doe - 719468) * $msPerDay;
	},
	$dateFromEpoch = function(z) {
		z = $floor(z / $msPerDay) + 719468;
		var era = $int( (z >= 0 ? z : z - 146096) / 146097 );
		var doe = z - era * 146097;
		var yoe = $int( (doe - $int(doe / 1460) + $int(doe / 36524) - $int(doe / 146096)) / 365 );
    	var y = yoe + era * 400;
	    var doy = doe - (365 * yoe + $int(yoe / 4) - $int(yoe/100) );
	    var mp = $int( (5 * doy + 2) / 153);
	    var m = mp + (mp < 10 ? 2 : -10);
	    var d = doy - $int( (153 * mp + 2) / 5 ) + 1;
	    return [ (y + (m <= 1)), m, d ];
	},
	$epochFromTime = function(hour, minute, second, ms) {
		return hour * $msPerHour + minute * $msPerMinute + second * $msPerSecond + ms;
	},
	$timeFromEpoch = function(z) {
		return [ $mod($floor(z / $msPerHour), 24), $mod($floor(z / $msPerMinute), 60), $mod($floor(z / $msPerSecond), 60), $mod(z, $msPerSecond) ];
	},
	$setDateParts = function(z, n, a) {
		var i, d = $dateFromEpoch(z), r = $mod(z, $msPerDay);
//		console.log(z + " was " + d + " and " + r);
		for (i = 0; i < a.length; ++i, ++n) d[n] = $int(a[i]);
//		console.log("is " + d + " and " + r);
		return $epochFromDate.apply(null, d) + r;
	},
	$setTimeParts = function(z, n, a) {
		var i, t = $timeFromEpoch(z), r = $floor(z / $msPerDay) * $msPerDay;
		for (i = 0; i < a.length; ++i, ++n) t[n] = $int(a[i]);
		return $epochFromTime.apply(null, t) + r;
	},
	$weekdayFromTime = function(z) { return $mod($floor(z / $msPerDay) +4, 7); },
	$hourFromTime = function(z) { return $mod($floor(z / $msPerHour), 24); },
	$minFromTime = function(z) { return $mod($floor(z / $msPerMinute), 60); },
	$secFromTime = function(z) { return $mod($floor(z / $msPerSecond), 60); },
	$msFromTime = function(z) { return $mod(z, $msPerSecond); },
	$timeClip = function(z) { return (!$isFinite(z) || Math.abs(z) > 8.64e15 ? $NaN : $int(z)); },
	$toLocalTime = function(z) { return z + $support.localTZA() + $support.localDST(z); },
	$fromLocalTime = function(z) { // Variant of UTC(t) that return lowest epoch matching a local DST time
		var l;
		return (l = z - $support.localTZA()) - $support.localDST(l - $support.localTZA());
	},
	$makeDateTime = function(year, month, date, hours, minutes, seconds, ms) {
		var argc = arguments.length;
		return $epochFromDate( (year = $int(year)) + (0 <= year && year <= 99 ? 1900 : 0),
			$int(month), (argc > 2 ? $int(date) : 1)) + $epochFromTime( argc > 3 ? $int(hours) : 0,
			argc > 4 ? $int(minutes) : 0, argc > 5 ? $int(seconds) : 0, argc > 6 ? $int(ms) : 0);
	};

// Test functions
var d;

console.log( (d = new Date(89268736629000 + 0*60*60*1000)).valueOf() + " = " + String( d ) + " / " + d.getTimezoneOffset() + " = " + $support.localDST(d.valueOf()) )
console.log( (d = new Date(89268736629000 + 1*60*60*1000)).valueOf() + " = " + String( d ) + " / " + d.getTimezoneOffset() + " = " + $support.localDST(d.valueOf()) )
console.log( (d = new Date(89268736629000 + 2*60*60*1000)).valueOf() + " = " + String( d ) + " / " + d.getTimezoneOffset() + " = " + $support.localDST(d.valueOf()) )
console.log( (d = new Date(89268736629000 + 3*60*60*1000)).valueOf() + " = " + String( d ) + " / " + d.getTimezoneOffset() + " = " + $support.localDST(d.valueOf()) )
console.log();
console.log( (d = new Dayt(89268736629000 + 0*60*60*1000)).valueOf() + " = " + String( d ) + " / " + d.getTimezoneOffset() + " = " + $support.localDST(d.valueOf()) )
console.log( (d = new Dayt(89268736629000 + 1*60*60*1000)).valueOf() + " = " + String( d ) + " / " + d.getTimezoneOffset() + " = " + $support.localDST(d.valueOf()) )
console.log( (d = new Dayt(89268736629000 + 2*60*60*1000)).valueOf() + " = " + String( d ) + " / " + d.getTimezoneOffset() + " = " + $support.localDST(d.valueOf()) )
console.log( (d = new Dayt(89268736629000 + 3*60*60*1000)).valueOf() + " = " + String( d ) + " / " + d.getTimezoneOffset() + " = " + $support.localDST(d.valueOf()) )


console.log((new Date(377,2,27,1,44,18)).valueOf());
console.log((new Dayt(377,2,27,1,44,18)).valueOf());
console.log((new Date(377,2,27,1,44,18)).toISOString());
console.log((new Dayt(377,2,27,1,44,18)).toISOString());
console.log((new Date(-50262851742000 + 60*60*1000)).toISOString());
console.log((new Dayt(-50262851742000 + 60*60*1000)).toISOString());

console.log(new Date(1999,9,31,2,13,41).valueOf());
console.log(new Dayt(1999,9,31,2,13,41).valueOf());
console.log(-214529553979000 % $msPerDay);
console.log($support.localDST(-214529557579000));

console.log(new Date(-1999,9,20,2,13,41).toISOString());
console.log(new Dayt(-1999,9,20,2,13,41).toISOString());

console.log(new Dayt(1974,6,14,1,15,16,17).toString());
console.log(new Dayt(1974,6,14,1,15,16,17).toUTCString());
console.log(new Dayt(1974,6,14,1,15,16,17).toISOString());



(function() {
	function test(what,a,b) {
		if (!((typeof a === "number" && typeof b === "number" && $isNaN(a) && $isNaN(b)) || a === b))
			throw "Test " + what + " failed: " + a + " !== " + b;
	};

	for (var i = 0; i < 100000; ++i) {
		var r, y, m, d, h, n, s, ms, t;
		
		y = ((r = Math.random()) > 0.99 ? NaN : r > 0.98 ? "string" : r > 0.97 ? Infinity : r > 0.96 ? undefined : r * 20000 - 10000);
		m = ((r = Math.random()) > 0.99 ? NaN : r > 0.98 ? "string" : r > 0.97 ? Infinity : r > 0.96 ? undefined : r * 100 - 50);
		d = ((r = Math.random()) > 0.99 ? NaN : r > 0.98 ? "string" : r > 0.97 ? Infinity : r > 0.96 ? undefined : r * 100 - 50);
		h = ((r = Math.random()) > 0.99 ? NaN : r > 0.98 ? "string" : r > 0.97 ? Infinity : r > 0.96 ? undefined : r * 100 - 50);
		n = ((r = Math.random()) > 0.99 ? NaN : r > 0.98 ? "string" : r > 0.97 ? Infinity : r > 0.96 ? undefined : r * 100 - 50);
		s = ((r = Math.random()) > 0.99 ? NaN : r > 0.98 ? "string" : r > 0.97 ? Infinity : r > 0.96 ? undefined : r * 100 - 50);
		ms = ((r = Math.random()) > 0.99 ? NaN : r > 0.98 ? "string" : r > 0.97 ? Infinity : r > 0.96 ? undefined : r * 100 - 50);
		t = ((r = Math.random()) > 0.99 ? NaN : r > 0.98 ? "string" : r > 0.97 ? Infinity : r > 0.96 ? undefined : r * 12e15 - 6e15);
		
		test("new Date(" + JSON.stringify([y,m,d,h,n,s,ms]) + ")", (new Dayt(y,m,d,h,n,s,ms)).valueOf(), (new Date(y,m,d,h,n,s,ms)).valueOf());
		test("Date.UTC(" + JSON.stringify([y,m,d,h,n,s,ms]) + ")", Dayt.UTC(y,m,d,h,n,s,ms), Date.UTC(y,m,d,h,n,s,ms));

		var a = (new Dayt(t));
		var b = (new Date(t));

		test("new Date(" + t + ")", a.valueOf(), b.valueOf());
		test("Date.UTC(" + t + ")", Dayt.UTC(t), Date.UTC(t));
		
		test("toDateString " + JSON.stringify([y,m,d,h,n,s,ms]), a.toDateString(), b.toDateString());
		test("toTimeString " + JSON.stringify([y,m,d,h,n,s,ms]), a.toTimeString(), b.toTimeString());
		test("toString " + JSON.stringify([y,m,d,h,n,s,ms]), a.toString(), b.toString());

		test("toUTCString " + JSON.stringify([y,m,d,h,n,s,ms]), a.toUTCString(), b.toUTCString());
		
		if (!($isNaN(a.getTime()))) test("toISOString " + JSON.stringify([y,m,d,h,n,s,ms]), a.toISOString(), b.toISOString());

		test("valueOf" + JSON.stringify([y,m,d,h,n,s,ms]), a.valueOf(), b.valueOf());
		test("getTime" + JSON.stringify([y,m,d,h,n,s,ms]), a.getTime(), b.getTime());
		test("getFullYear" + JSON.stringify([y,m,d,h,n,s,ms]), a.getFullYear(), b.getFullYear());
		test("getUTCFullYear" + JSON.stringify([y,m,d,h,n,s,ms]), a.getUTCFullYear(), b.getUTCFullYear());
		test("getMonth" + JSON.stringify([y,m,d,h,n,s,ms]), a.getMonth(), b.getMonth());
		test("getUTCMonth" + JSON.stringify([y,m,d,h,n,s,ms]), a.getUTCMonth(), b.getUTCMonth());
		test("getDate" + JSON.stringify([y,m,d,h,n,s,ms]), a.getDate(), b.getDate());
		test("getUTCDate" + JSON.stringify([y,m,d,h,n,s,ms]), a.getUTCDate(), b.getUTCDate());
		test("getDay" + JSON.stringify([y,m,d,h,n,s,ms]), a.getDay(), b.getDay());
		test("getUTCDay" + JSON.stringify([y,m,d,h,n,s,ms]), a.getUTCDay(), b.getUTCDay());
		test("getHours" + JSON.stringify([y,m,d,h,n,s,ms]), a.getHours(), b.getHours());
		test("getUTCHours" + JSON.stringify([y,m,d,h,n,s,ms]), a.getUTCHours(), b.getUTCHours());
		test("getMinutes" + JSON.stringify([y,m,d,h,n,s,ms]), a.getMinutes(), b.getMinutes());
		test("getUTCMinutes" + JSON.stringify([y,m,d,h,n,s,ms]), a.getUTCMinutes(), b.getUTCMinutes());
		test("getSeconds" + JSON.stringify([y,m,d,h,n,s,ms]), a.getSeconds(), b.getSeconds());
		test("getUTCSeconds" + JSON.stringify([y,m,d,h,n,s,ms]), a.getUTCSeconds(), b.getUTCSeconds());
		test("getMilliseconds" + JSON.stringify([y,m,d,h,n,s,ms]), a.getMilliseconds(), b.getMilliseconds());
		test("getUTCMilliseconds" + JSON.stringify([y,m,d,h,n,s,ms]), a.getUTCMilliseconds(), b.getUTCMilliseconds());
		test("getTimezoneOffset" + JSON.stringify([y,m,d,h,n,s,ms]), a.getTimezoneOffset(), b.getTimezoneOffset());

		test("setTime(" + t + ")", (new Dayt()).setTime(t), (new Date()).setTime(t));

		test("setMilliseconds(" + ms + ")", (new Dayt(t)).setMilliseconds(ms), (new Date(t)).setMilliseconds(ms));
		test("setUTCMilliseconds(" + ms + ")", (new Dayt(t)).setUTCMilliseconds(ms), (new Date(t)).setUTCMilliseconds(ms));
		
		test("setSeconds" + JSON.stringify([s]), (new Dayt(t)).setSeconds(s), (new Date(t)).setSeconds(s));
		test("setUTCSeconds" + JSON.stringify([s]), (new Dayt(t)).setUTCSeconds(s), (new Date(t)).setUTCSeconds(s));
		test("setSeconds" + JSON.stringify([s,ms]), (new Dayt(t)).setSeconds(s,ms), (new Date(t)).setSeconds(s,ms));
		test("setUTCSeconds" + JSON.stringify([s,ms]), (new Dayt(t)).setUTCSeconds(s,ms), (new Date(t)).setUTCSeconds(s,ms));
		
		test("setMinutes" + JSON.stringify([n]), (new Dayt(t)).setMinutes(n), (new Date(t)).setMinutes(n));
		test("setUTCMinutes" + JSON.stringify([n]), (new Dayt(t)).setUTCMinutes(n), (new Date(t)).setUTCMinutes(n));
		test("setMinutes" + JSON.stringify([n,s]), (new Dayt(t)).setMinutes(n,s), (new Date(t)).setMinutes(n,s));
		test("setUTCMinutes" + JSON.stringify([n,s]), (new Dayt(t)).setUTCMinutes(n,s), (new Date(t)).setUTCMinutes(n,s));
		test("setMinutes" + JSON.stringify([n,s,ms]), (new Dayt(t)).setMinutes(n,s,ms), (new Date(t)).setMinutes(n,s,ms));
		test("setUTCMinutes" + JSON.stringify([n,s,ms]), (new Dayt(t)).setUTCMinutes(n,s,ms), (new Date(t)).setUTCMinutes(n,s,ms));

		test("setHours" + JSON.stringify([h]), (new Dayt(t)).setHours(h), (new Date(t)).setHours(h));
		test("setUTCHours" + JSON.stringify([h]), (new Dayt(t)).setUTCHours(h), (new Date(t)).setUTCHours(h));
		test("setHours" + JSON.stringify([h,n]), (new Dayt(t)).setHours(h,n), (new Date(t)).setHours(h,n));
		test("setUTCHours" + JSON.stringify([h,n]), (new Dayt(t)).setUTCHours(h,n), (new Date(t)).setUTCHours(h,n));
		test("setHours" + JSON.stringify([h,n,s]), (new Dayt(t)).setHours(h,n,s), (new Date(t)).setHours(h,n,s));
		test("setUTCHours" + JSON.stringify([h,n,s]), (new Dayt(t)).setUTCHours(h,n,s), (new Date(t)).setUTCHours(h,n,s));
		test("setHours" + JSON.stringify([h,n,s,ms]), (new Dayt(t)).setHours(h,n,s,ms), (new Date(t)).setHours(h,n,s,ms));
		test("setUTCHours" + JSON.stringify([h,n,s,ms]), (new Dayt(t)).setUTCHours(h,n,s,ms), (new Date(t)).setUTCHours(h,n,s,ms));

		test("setDate(" + d + ")", (new Dayt(t)).setDate(d), (new Date(t)).setDate(d));
		test("setUTCDate(" + d + ")", (new Dayt(t)).setUTCDate(d), (new Date(t)).setUTCDate(d));

		test("setMonth" + JSON.stringify([m]), (new Dayt(t)).setMonth(m), (new Date(t)).setMonth(m));
		test("setUTCMonth" + JSON.stringify([m]), (new Dayt(t)).setUTCMonth(m), (new Date(t)).setUTCMonth(m));
		test("setMonth" + JSON.stringify([m,d]), (new Dayt(t)).setMonth(m,d), (new Date(t)).setMonth(m,d));
		test("setUTCMonth" + JSON.stringify([m,d]), (new Dayt(t)).setUTCMonth(m,d), (new Date(t)).setUTCMonth(m,d));

		test("setFullYear" + JSON.stringify([y]), (new Dayt(t)).setFullYear(y), (new Date(t)).setFullYear(y));
		test("setUTCFullYear" + JSON.stringify([y]), (new Dayt(t)).setUTCFullYear(y), (new Date(t)).setUTCFullYear(y));
		test("setFullYear" + JSON.stringify([y,m]), (new Dayt(t)).setFullYear(y,m), (new Date(t)).setFullYear(y,m));
		test("setUTCFullYear" + JSON.stringify([y,m]), (new Dayt(t)).setUTCFullYear(y,m), (new Date(t)).setUTCFullYear(y,m));
		test("setFullYear" + JSON.stringify([y,m,d]), (new Dayt(t)).setFullYear(y,m,d), (new Date(t)).setFullYear(y,m,d));
		test("setUTCFullYear" + JSON.stringify([y,m,d]), (new Dayt(t)).setUTCFullYear(y,m,d), (new Date(t)).setUTCFullYear(y,m,d));
	};

})();

//	console.log(Dayt.UTC(2001,-13,-1,1,1,1,1));
//	console.log(Date.UTC(2001,-13,-1,1,1,1,1));
