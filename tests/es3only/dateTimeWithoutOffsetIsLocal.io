// ES3 15.9.4.2 defines no date format at all: "The string may be interpreted as a local time, a UTC time, or a
// time in some other time zone, depending on the contents of the string." The only thing it does require is that
// Date.parse(x.toString()) and Date.parse(x.toUTCString()) give x.valueOf() back, which tests/stdlib/dates.io
// pins. So the es3 build is free here and reads every date-time without an offset as local, T-separated or not.
// ES5.1 15.9.1.15 does define the T form and makes its absent offset "Z", so the es5 build reads that one as UTC;
// tests/es5/isoDateTimeWithoutOffsetIsUTC.io is the twin. Comparing against the local component constructor keeps
// this independent of the machine's zone.
> function show(l, v) { print(l + ": " + v) }
-
// The T form, which is the half that differs between the builds.
> show("T form local", new Date("2011-10-10T14:48:00").valueOf() === new Date(2011, 9, 10, 14, 48).valueOf());
< T form local: true
-
// Lowercase t is not 15.9.1.15's separator either, and the es3 build treats it exactly like the uppercase one.
> show("t form local", new Date("2011-10-10t14:48:00").valueOf() === new Date(2011, 9, 10, 14, 48).valueOf());
< t form local: true
-
// An explicit offset still wins over any of this, in either build.
> show("explicit Z", new Date("2011-10-10T14:48:00Z").toISOString());
< explicit Z: 2011-10-10T14:48:00.000Z
> show("explicit +02:00", new Date("2011-10-10T14:48:00+02:00").toISOString());
< explicit +02:00: 2011-10-10T12:48:00.000Z
