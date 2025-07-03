> function localDateTimeFromString(s) { var d = new Date(s); print(s + " = " + d.toDateString() + ' ' + d.toTimeString()) };
> function utcDateTimeFromString(s) { var d = new Date(s); print(s + " : " + d.valueOf() + " = " + d.toISOString()) };
-
> localDateTimeFromString("1974-07-14 01:15");
< 1974-07-14 01:15 = 1974-07-14 01:15:00
-
> localDateTimeFromString("1974");
< 1974 = 1974-01-01 00:00:00
-
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
