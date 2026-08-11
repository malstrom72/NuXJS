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
// getDay/getUTCDay are deterministic; 1970-01-01 was a Thursday and 2009-02-13T23:31:30Z a Friday.
> print(new Date(0).getDay() + " " + new Date(0).getUTCDay() + " " + new Date(1234567890123).getUTCDay())
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
