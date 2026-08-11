// 15.9.4.2: "Unrecognisable Strings or dates containing illegal element values in the format String shall cause
// Date.parse to return NaN", and 15.9.1.15 counts out-of-bounds values as illegal alongside syntax errors. That same
// clause makes the fall back to implementation-specific formats optional ("may"), and the es5 build declines it, so
// the 15.9.1.15 grammar is the whole of what parses, bar the space and lowercase t separators toString and
// toUTCString print. ES3 dictates no format at all and keeps its loose scan; the twin is
// tests/es3only/dateFormatsLoose.io. Only NaN-ness is asserted here, never an instant, so the machine's zone cannot
// reach these results.
> function p(s) { print('"' + s + '" ' + (isNaN(Date.parse(s)) ? "NaN" : "parses")) };
-
// Out of bounds: MM is 01 to 12 and DD is 01 to 31.
> p("2011-13-10"); p("2011-00-10"); p("2011-10-45"); p("2011-10-00");
< "2011-13-10" NaN
< "2011-00-10" NaN
< "2011-10-45" NaN
< "2011-10-00" NaN
-
// Out of bounds: HH is 00 to 24, mm and ss are 00 to 59, and the offset is a HH:mm time expression.
> p("2011-10-10T25:00:00"); p("2011-10-10T14:60:00"); p("2011-10-10T14:48:60"); p("2011-10-10T14:48:00+25:00");
< "2011-10-10T25:00:00" NaN
< "2011-10-10T14:60:00" NaN
< "2011-10-10T14:48:60" NaN
< "2011-10-10T14:48:00+25:00" NaN
-
// Syntax errors: trailing text, a separator with no time, a truncated field, non-digits, text after the offset.
> p("2011-10-10garbage"); p("2011-10-10T"); p("2011-10-10T14"); p("2011-10-10Txx:00"); p("2011-10-10T14:48:00Zjunk");
< "2011-10-10garbage" NaN
< "2011-10-10T" NaN
< "2011-10-10T14" NaN
< "2011-10-10Txx:00" NaN
< "2011-10-10T14:48:00Zjunk" NaN
-
// The extended year is exactly six digits and is never bare, and a two digit year is not a year at all.
> p(""); p("+1974-07-14 01:15"); p("74-07-14 01:15"); p("2011-1-1");
< "" NaN
< "+1974-07-14 01:15" NaN
< "74-07-14 01:15" NaN
< "2011-1-1" NaN
-
// The offset spellings the es3 build still takes. 15.9.1.15 has only "+HH:mm", so none of these is in the format and
// 15.9.4.2 lets us stop there rather than guess. Deliberately stricter than V8, which takes the last two.
> p("1974-07-14T01:15:16.017+02"); p("1974-07-14T01:15+05:"); p("1974-07-14 01:15:16 +0200"); p("1974-07-14 01:15:16 GMT-01:30");
< "1974-07-14T01:15:16.017+02" NaN
< "1974-07-14T01:15+05:" NaN
< "1974-07-14 01:15:16 +0200" NaN
< "1974-07-14 01:15:16 GMT-01:30" NaN
-
// Everything 15.9.1.15 does spell still parses: the three date-only forms, the three time forms, both zone forms.
> p("2011"); p("2011-10"); p("2011-10-10"); p("2011-10-10T14:48"); p("2011-10-10T14:48:00"); p("2011-10-10T14:48:00.123");
< "2011" parses
< "2011-10" parses
< "2011-10-10" parses
< "2011-10-10T14:48" parses
< "2011-10-10T14:48:00" parses
< "2011-10-10T14:48:00.123" parses
-
> p("2011-10-10T14:48:00Z"); p("2011-10-10T14:48:00+02:00"); p("2011-10-10T14:48:00-05:30"); p("+001974-07-14T01:15"); p("-000074-07-14T01:15");
< "2011-10-10T14:48:00Z" parses
< "2011-10-10T14:48:00+02:00" parses
< "2011-10-10T14:48:00-05:30" parses
< "+001974-07-14T01:15" parses
< "-000074-07-14T01:15" parses
-
// The two relaxations NuXJS needs for itself: toString prints the space separator, and the parser has always taken a
// lowercase t. 15.9.4.2's round trips, pinned in tests/stdlib/dates.io, depend on the first.
> p("2011-10-10 14:48:00"); p("2011-10-10 14:48:00Z"); p("2011-10-10t14:48:00");
< "2011-10-10 14:48:00" parses
< "2011-10-10 14:48:00Z" parses
< "2011-10-10t14:48:00" parses
-
// 15.9.1.15 bounds DD at 31 whatever the month, so a short month is in the format and MakeDay rolls it over. That is
// the letter of the clause; JavaScriptCore rejects it and V8 does not.
> print(new Date("2011-02-31T00:00:00Z").toISOString());
< 2011-03-03T00:00:00.000Z
-
// HH is bounded at 24 and NOTE 1 offers 24:00 as the day's far midnight, so the hour rolls the date over. The clause
// puts no extra condition on the other fields at 24, so 24:30 is in the format too; V8 and JavaScriptCore reject it.
> print(new Date("2011-10-10T24:00:00Z").toISOString() + " " + new Date("2011-10-10T24:30:00Z").toISOString());
< 2011-10-11T00:00:00.000Z 2011-10-11T00:30:00.000Z
