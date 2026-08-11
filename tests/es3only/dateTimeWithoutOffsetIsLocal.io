// ES3 15.9.4.2 defines no date format at all: "The string may be interpreted as a local time, a UTC time, or a
// time in some other time zone, depending on the contents of the string." So nothing here is dictated. The only
// thing ES3 does require is that Date.parse(x.toString()) and Date.parse(x.toUTCString()) give x.valueOf() back,
// which tests/stdlib/dates.io pins, and no date-only string ever comes out of either. The es3 build therefore
// reads everything that carries no offset as local, which is what it has always done.
// ES5.1 15.9.1.15 does dictate it, so the es5 build answers UTC for all of these except the space form; the twin
// is tests/es5/isoDateTimeWithoutOffsetIsUTC.io. Comparing against the local component constructor rather than
// printing a time keeps this independent of the machine's zone.
> function show(l, v) { print(l + ": " + v) }
-
// Date-only. UTC in ES5.1 and in every later edition, but ES3 asks for nothing, so the es3 build leaves it local.
> show("date only", new Date("2011-10-10").valueOf() === new Date(2011, 9, 10).valueOf());
< date only: true
> show("year only", new Date("2011").valueOf() === new Date(2011, 0, 1).valueOf());
< year only: true
-
// The T form, which 15.9.1.15 does define and the es5 build reads as UTC.
> show("T form", new Date("2011-10-10T14:48:00").valueOf() === new Date(2011, 9, 10, 14, 48).valueOf());
< T form: true
-
// Lowercase t is not 15.9.1.15's separator either, and the es3 build treats it exactly like the uppercase one.
> show("t form", new Date("2011-10-10t14:48:00").valueOf() === new Date(2011, 9, 10, 14, 48).valueOf());
< t form: true
-
// An explicit offset still wins over all of it, in either build.
> show("explicit Z", new Date("2011-10-10T14:48:00Z").toISOString());
< explicit Z: 2011-10-10T14:48:00.000Z
> show("explicit +02:00", new Date("2011-10-10T14:48:00+02:00").toISOString());
< explicit +02:00: 2011-10-10T12:48:00.000Z
