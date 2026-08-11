// 15.9.1.15: "The value of an absent time zone offset is Z". The format it defines separates the date and the
// time with a T, so that is the form the rule governs, and the es5 build reads it as UTC. ES3 defines no date
// format at all, so the es3 build leaves it local; tests/es3only/dateTimeWithoutOffsetIsLocal.io is the twin.
// This is a deliberate divergence from V8 and JavaScriptCore, which follow the later edition that made the T
// form local again. See docs/specs/ES5.1 vs modern divergences.md.
> function show(l, v) { print(l + ": " + v) }
-
// The T form with no offset. UTC, so the answer does not depend on the machine's zone.
> show("T form", new Date("2011-10-10T14:48:00").toISOString());
< T form: 2011-10-10T14:48:00.000Z
> show("t form", new Date("2011-10-10t14:48:00").toISOString());
< t form: 2011-10-10T14:48:00.000Z
-
// Every field of the format, absent fields defaulting as 15.9.1.15 says and the whole still UTC.
> show("with seconds", new Date("2011-10-10T14:48:16").toISOString());
< with seconds: 2011-10-10T14:48:16.000Z
> show("with millis", new Date("2011-10-10T14:48:16.017").toISOString());
< with millis: 2011-10-10T14:48:16.017Z
-
// Date-only stays UTC, which is the one reading every edition shares.
> show("date only", new Date("2011-10-10").toISOString());
< date only: 2011-10-10T00:00:00.000Z
-
// The space form is not 15.9.1.15's, so it falls to our own heuristics and stays local. That is what makes
// Date.parse(x.toString()) round trip, toString printing exactly that shape.
> show("space form local", new Date("2011-10-10 14:48:00").valueOf() === new Date(2011, 9, 10, 14, 48).valueOf());
< space form local: true
-
// 15.9.4.2 requires all three of these to come back to the same instant, whichever form each method prints.
> var rt = new Date(1234567890000);
> show("toString", Date.parse(rt.toString()) === rt.valueOf());
< toString: true
> show("toUTCString", Date.parse(rt.toUTCString()) === rt.valueOf());
< toUTCString: true
> show("toISOString", Date.parse(rt.toISOString()) === rt.valueOf());
< toISOString: true
-
// An explicit offset always wins, in either build.
> show("explicit +02:00", new Date("2011-10-10T14:48:00+02:00").toISOString());
< explicit +02:00: 2011-10-10T12:48:00.000Z
