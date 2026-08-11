// ES5.1 Annex B (informative) B.2.4 getYear, B.2.5 setYear, B.2.6 toGMTString. Annex B is informative rather than
// normative in ES5.1, so these are a deliberate inclusion; escape (B.2.1) and unescape (B.2.2) stay unimplemented,
// as they always have been in NuXJS. B.2.3 String.prototype.substr was already there.
// B.2.4 step 3: YearFromTime(LocalTime(t)) - 1900, so the offset is from 1900 and may go negative.
> print(new Date(1995, 0, 1).getYear())
< 95
> print(new Date(2026, 0, 1).getYear())
< 126
> print(new Date(1899, 0, 1).getYear())
< -1
-
// B.2.4 step 2: an invalid date is NaN, not a year. It comes straight out of dateFromEpoch, which getFullYear and
// the rest of 15.9.5.10 to 15.9.5.13 take their own step 2 from as well; tests/stdlib/dates.io pins those.
> print(new Date(NaN).getYear())
< NaN
-
// "this time value" requires a Date, so a foreign receiver is a TypeError.
> try { Date.prototype.getYear.call({}) } catch (e) { print(e.name) }
< TypeError
> try { Date.prototype.setYear.call({}, 95) } catch (e) { print(e.name) }
< TypeError
-
// B.2.5 step 4: 0 <= ToInteger(year) <= 99 folds into the 1900s; anything else is used as the full year.
> var d = new Date(0); d.setYear(95); print(d.getFullYear())
< 1995
> var d = new Date(0); d.setYear(0); print(d.getFullYear())
< 1900
> var d = new Date(0); d.setYear(99); print(d.getFullYear())
< 1999
> var d = new Date(0); d.setYear(100); print(d.getFullYear())
< 100
> var d = new Date(0); d.setYear(1995); print(d.getFullYear())
< 1995
> var d = new Date(0); d.setYear(-1); print(d.getFullYear())
< -1
-
// B.2.5 steps 5 and 6 keep month, date and the time within the day, and step 8 returns the new time value.
> var d = new Date(2000, 5, 15, 12, 30); d.setYear(88); print(d.getMonth() + "/" + d.getDate() + "/" + d.getHours())
< 5/15/12
> print(new Date(0).setYear(95))
< 788918400000
-
// B.2.5 step 3: a NaN year clears the date rather than clipping it. Step 1 still starts an invalid date from +0.
> var d = new Date(0); print(d.setYear(NaN) + "/" + d.getTime())
< NaN/NaN
> var d = new Date(NaN); d.setYear(95); print(d.getFullYear())
< 1995
-
// B.2.6: "the same Function object that is the initial value of Date.prototype.toUTCString", not a copy of it.
> print(Date.prototype.toGMTString === Date.prototype.toUTCString)
< true
-
// All three are non-enumerable, like every other built-in.
> var f = 0; for (var k in Date.prototype) if (k === "getYear" || k === "setYear" || k === "toGMTString") ++f; print(f)
< 0
-
// B.2.1 and B.2.2 are deliberately absent.
> print(typeof this.escape + " " + typeof this.unescape)
< undefined undefined
-
