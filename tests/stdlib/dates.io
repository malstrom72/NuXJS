> function localDateTimeFromString(s) { var d = new Date(s); print(s + " = " + d.toDateString() + ' ' + d.toTimeString()) };
> function utcDateTimeFromString(s) { var d = new Date(s); print(s + " : " + d.valueOf() + " = " + d.toISOString()) };
-
> localDateTimeFromString("1974-07-14 01:15");
< 1974-07-14 01:15 = 1974-07-14 01:15:00
-
// A bare year, and the other date-only forms, are the one shape the two builds read differently: es5 follows
// 15.9.1.15 and answers UTC where es3 answers local. Printing local time here would say which build it is, so
// the pair lives in tests/es3only/dateTimeWithoutOffsetIsLocal.io and tests/es5/isoDateTimeWithoutOffsetIsUTC.io,
// which cover the bare-year syntax between them. Everything below carries a time and is local in both.
> localDateTimeFromString("+1974-07-14 01:15");
< +1974-07-14 01:15 = Invalid Date Invalid Date
-
> localDateTimeFromString("0074-07-14 01:15");
< 0074-07-14 01:15 = 0074-07-14 01:15:00
-
> localDateTimeFromString("74-07-14 01:15");
< 74-07-14 01:15 = Invalid Date Invalid Date
-
> localDateTimeFromString("-000074-07-14 01:15");
< -000074-07-14 01:15 = -000074-07-14 01:15:00
-
> localDateTimeFromString("+001974-07-14 01:15");
< +001974-07-14 01:15 = 1974-07-14 01:15:00
-
> utcDateTimeFromString("1974-07-14T01:15:16.017Z");
< 1974-07-14T01:15:16.017Z : 142996516017 = 1974-07-14T01:15:16.017Z
-
> utcDateTimeFromString("1974-07-14T01:15:16.017+01:00");
< 1974-07-14T01:15:16.017+01:00 : 142992916017 = 1974-07-14T00:15:16.017Z
-
> utcDateTimeFromString("1974-07-14T01:15:16.017+02");
< 1974-07-14T01:15:16.017+02 : 142989316017 = 1974-07-13T23:15:16.017Z
-
> utcDateTimeFromString("1974-07-14T01:15:16.017+02:03");
< 1974-07-14T01:15:16.017+02:03 : 142989136017 = 1974-07-13T23:12:16.017Z
-
> utcDateTimeFromString("1974-07-14T01:15:16+03");
< 1974-07-14T01:15:16+03 : 142985716000 = 1974-07-13T22:15:16.000Z
-
> utcDateTimeFromString("1974-07-14T01:15:16+04");
< 1974-07-14T01:15:16+04 : 142982116000 = 1974-07-13T21:15:16.000Z
-
> utcDateTimeFromString("1974-07-14T01:15+05:");
< 1974-07-14T01:15+05: : 142978500000 = 1974-07-13T20:15:00.000Z
-
> utcDateTimeFromString("1974-07-14 01:15:16 +0200");
< 1974-07-14 01:15:16 +0200 : 142989316000 = 1974-07-13T23:15:16.000Z
-
> utcDateTimeFromString("1974-07-14 01:15:16 GMT-01:30");
< 1974-07-14 01:15:16 GMT-01:30 : 143001916000 = 1974-07-14T02:45:16.000Z
-
> utcDateTimeFromString("+1974-07-14 01:15Z");
! !!!! RangeError: Invalid time value
-
> x = new Date(10100)
> y = new Date(110100)
-
> print(typeof (x+y))
< string
-
> print(typeof (x-y))
< number
-
> print(x-y)
< -100000
-
> print(x==(x-0))
< false
-
> print(x==(x+''))
< true
-
> d=new Date()
-
> d.setMilliseconds(123)
-
> print(d.getMilliseconds())
< 123
-
> d.setSeconds(33)
-
> print(d.getSeconds())
< 33
-
> d.setMinutes(11)
-
> print(d.getMinutes())
< 11
-
> d.setHours(4)
-
> print(d.getHours())
< 4
-
> d.setHours(1,11,22,333)
-
> print(d.getHours())
< 1
-
> print(d.getMinutes())
< 11
-
> print(d.getSeconds())
< 22
-
> print(d.getMilliseconds())
< 333
-
> d.setUTCMilliseconds(321)
-
> print(d.getUTCMilliseconds())
< 321
-
> d.setUTCSeconds(43)
-
> print(d.getUTCSeconds())
< 43
-
> d.setUTCMinutes(21)
-
> print(d.getUTCMinutes())
< 21
-
> d.setUTCHours(7)
-
> print(d.getUTCHours())
< 7
-
> d.setUTCHours(2,22,33,444)
-
> print(d.getUTCHours())
< 2
-
> print(d.getUTCMinutes())
< 22
-
> print(d.getUTCSeconds())
< 33
-
> print(d.getMilliseconds())
< 444
-
> d.setDate(13)
-
> print(d.getDate())
< 13
-
> d.setMonth(3)
-
> print(d.getMonth())
< 3
-
> d.setFullYear(2011)
-
> print(d.getFullYear())
< 2011
-
> d.setFullYear(2015,10,9)
-
> print(d.getFullYear())
< 2015
-
> print(d.getMonth())
< 10
-
> print(d.getDate())
< 9
-
> d.setUTCDate(5)
-
> print(d.getUTCDate())
< 5
-
> d.setUTCMonth(7)
-
> print(d.getUTCMonth())
< 7
-
> d.setUTCFullYear(2004)
-
> print(d.getUTCFullYear())
< 2004
-
> d.setUTCFullYear(2006,3,5)
-
> print(d.getUTCFullYear())
< 2006
-
> print(d.getUTCMonth())
< 3
-
> print(d.getUTCDate())
< 5
-
// 15.9.5.27 setTime never worked: it called setDateValue(timeClip(+time)) without `this`, so checkDateClass got the
// timestamp instead of the Date object and every call threw "this is not a Date object".
> print(d.setTime(86400000))
< 86400000
-
> print(d.getTime() + " " + d.getUTCFullYear() + " " + d.getUTCDate())
< 86400000 1970 2
-
> print(new Date(0).setTime(-1))
< -1
-
> print(isNaN(new Date(0).setTime(NaN)))
< true
-
> print(new Date(0).setTime("86400000"))
< 86400000
-
// These had no behavioural test at all until now, which is how setTime stayed broken since the initial import.
// getDay/getUTCDay pinned zone-independently: getDay reads local time, so it gets a date built from local
// components - 1970-01-01 was a Thursday in every zone that way - where new Date(0).getDay() would answer
// Wednesday west of Greenwich. 2009-02-13T23:31:30Z was a Friday.
> print(new Date(1970, 0, 1).getDay() + " " + new Date(0).getUTCDay() + " " + new Date(1234567890123).getUTCDay())
< 4 4 5
-
> print(new Date(86400000 * 3).getUTCDay() + " " + new Date(86400000 * 4).getUTCDay())
< 0 1
-
// 15.9.5.44 toJSON delegates to toISOString.
> print(new Date(1234567890123).toJSON() + " " + (new Date(1234567890123).toJSON() === new Date(1234567890123).toISOString()))
< 2009-02-13T23:31:30.123Z true
-
// 15.9.5.42/3/4 are implementation-dependent in their format, so these pin OUR format, not a spec requirement.
// The trailing Z is the exception: without it the string is the same shape toString prints for local time, and
// 15.9.4.2 requires both to read back as the instant they came from.
> print(new Date(0).toUTCString())
< 1970-01-01 00:00:00Z
-
> print(new Date(1234567890123).toUTCString() + " | " + new Date(-1).toUTCString())
< 2009-02-13 23:31:30Z | 1969-12-31 23:59:59Z
-
// 15.9.4.2 does require these, whatever the format: for a Date whose milliseconds are zero, parsing back what the
// engine printed has to give the instant. Independent of the machine's zone by construction.
> var rt = new Date(1234567890000);
> print(Date.parse(rt.toString()) === rt.valueOf());
< true
> print(Date.parse(rt.toUTCString()) === rt.valueOf());
< true
> print(Date.parse(rt.toISOString()) === rt.valueOf());
< true
-
// Locale and zone dependent, so only the shape is checkable here.
> print(typeof new Date(0).toLocaleDateString() + " " + typeof new Date(0).toLocaleTimeString() + " " + typeof new Date(0).getTimezoneOffset())
< string string number
-
> print(new Date(0).getTimezoneOffset() === new Date(0).getTimezoneOffset())
< true
-
// 15.9.4.2 opens "The parse function applies the ToString operator to its argument". It never did: parse read the
// argument a character at a time, which a String object survives by indexing the same way, so the gap only showed
// on everything else. undefined and null threw a TypeError where ToString makes them the strings "undefined" and
// "null" and the answer is an ordinary NaN. Nothing here depends on the format, only on the coercion happening.
> print(isNaN(Date.parse()) + " " + isNaN(Date.parse(undefined)) + " " + isNaN(Date.parse(null)))
< true true true
-
// An array and a plain object with a toString both reach the same string, and both must parse as that string. The
// constructor already coerced through toPrimitive, so new Date(x) and Date.parse(x) disagreed on the same argument.
> var iso = "2011-10-10T14:48:00Z";
> print(Date.parse([iso]) === Date.parse(iso))
< true
> print(Date.parse({ toString: function () { return iso } }) === Date.parse(iso))
< true
> print(Date.parse([iso]) === new Date([iso]).valueOf())
< true
-
// ToString is ToPrimitive with hint String, so toString is asked before valueOf, and an object carrying only valueOf
// falls through to Object.prototype.toString rather than to the date string.
> var log = "";
> Date.parse({ toString: function () { log += "S"; return iso }, valueOf: function () { log += "V"; return 1 } });
> print(log + " " + isNaN(Date.parse({ valueOf: function () { return iso } })))
< S true
-
// 15.9.5.10 to 15.9.5.13 all have "If t is NaN, return NaN" as step 2, worded identically in ES3, so an invalid date
// has to answer NaN from every getter. Four of them did not: dateFromEpoch runs its era arithmetic through int(),
// and ToInteger(NaN) is 0 by 9.4, so the year and month fell out as 0 and 2 while the day correctly did not.
> var bad = new Date(NaN);
> print(bad.getFullYear() + " " + bad.getUTCFullYear() + " " + bad.getMonth() + " " + bad.getUTCMonth())
< NaN NaN NaN NaN
-
> print(bad.getDate() + " " + bad.getUTCDate() + " " + bad.getDay() + " " + bad.getUTCDay() + " " + bad.getHours())
< NaN NaN NaN NaN NaN
-
> print(bad.getMinutes() + " " + bad.getSeconds() + " " + bad.getMilliseconds() + " " + bad.getTime())
< NaN NaN NaN NaN
-
// 15.9.5.40 step 1 is the one place NaN does not propagate: setFullYear reads this time value "but if this time
// value is NaN, let t be +0". Its siblings have no such step, so they stay NaN, and neither reading may change.
> var a = new Date(NaN); a.setUTCFullYear(2011); print(a.toISOString())
< 2011-01-01T00:00:00.000Z
-
> var b = new Date(NaN); b.setUTCMonth(3); var c = new Date(NaN); c.setUTCDate(5);
> print(isNaN(b.valueOf()) + " " + isNaN(c.valueOf()))
< true true
-
// 15.9.3.1 (12) clips the UTC value, not the local intermediate: a local MakeDate past the 8.64e15 edge whose
// UTC value lands back inside must survive, and one millisecond past it must not. The getTimezoneOffset arithmetic
// keeps this zone-independent (the -60 absorbs any DST skew between today and the fallback offset at the edge).
> var tzm = new Date().getTimezoneOffset() * (-1);
> var edge = new Date(1970, 0, 100000001, 0, 0 + tzm - 60, 0, -1);
> print(isFinite(edge.getTime()) + " " + (Math.abs(edge.getTime()) <= 8.64e15))
< true true
> print(isNaN(new Date(1970, 0, 100000001, 0, 0 + tzm + 60, 0, 1).getTime()))
< true
-
// The same conversion, reached by an ordinary date rather than the edge: MSVC's CRT refuses a local time past
// 3000-12-31T23:59:59Z and answers null, which the engine dereferenced, so new Date(3100, 0, 1) took the whole
// process down - a one-liner from guest script, which the sandbox promise does not allow. Past the limit the
// offset falls back to the zone's standard time, so DST-dependent values differ from a platform whose CRT goes
// the distance; what is checkable everywhere is that the round trip through local components survives.
> var far = new Date(3100, 0, 1);
> print(isFinite(far.getTime()) + " " + far.getFullYear() + " " + far.getMonth() + " " + far.getDate())
< true 3100 0 1
-
> print(isFinite(new Date(275760, 8, 12).getTime()) + " " + isFinite(new Date(3100, 0, 1).getTimezoneOffset()))
< true true
-
