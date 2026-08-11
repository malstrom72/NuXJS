// ES3 15.9.4.2 defines no date format, so what the parser accepts is entirely this implementation's choice, and the
// ES3 engine has always scanned loosely: any run of characters up to a Z or a sign is skipped, and the offset itself
// may drop its minutes or its colon. These are the forms that survive only here. 15.9.1.15 spells the offset
// "+HH:mm" and nothing else, and 15.9.4.2 makes the fall back to other formats optional, so the es5 build declines it
// and answers NaN; the twin is tests/es5/dateParseRejectsInvalid.io. Every string carries an explicit offset, so the
// expected values are independent of the machine's zone.
> function utcDateTimeFromString(s) { var d = new Date(s); print(s + " : " + d.valueOf() + " = " + d.toISOString()) };
-
// Offset hours with no minutes.
> utcDateTimeFromString("1974-07-14T01:15:16.017+02");
< 1974-07-14T01:15:16.017+02 : 142989316017 = 1974-07-13T23:15:16.017Z
-
> utcDateTimeFromString("1974-07-14T01:15:16+03");
< 1974-07-14T01:15:16+03 : 142985716000 = 1974-07-13T22:15:16.000Z
-
> utcDateTimeFromString("1974-07-14T01:15:16+04");
< 1974-07-14T01:15:16+04 : 142982116000 = 1974-07-13T21:15:16.000Z
-
// A colon with the minutes missing after it.
> utcDateTimeFromString("1974-07-14T01:15+05:");
< 1974-07-14T01:15+05: : 142978500000 = 1974-07-13T20:15:00.000Z
-
// The compact ISO 8601 offset, which 15.9.1.15 does not include.
> utcDateTimeFromString("1974-07-14 01:15:16 +0200");
< 1974-07-14 01:15:16 +0200 : 142989316000 = 1974-07-13T23:15:16.000Z
-
// Text between the time and the offset, skipped by the scan.
> utcDateTimeFromString("1974-07-14 01:15:16 GMT-01:30");
< 1974-07-14 01:15:16 GMT-01:30 : 143001916000 = 1974-07-14T02:45:16.000Z
