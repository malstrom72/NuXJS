# Date constructor default-argument behaviour

## Specification language

### ES3 (15.9.3.1)
> When **Date** is called with two to seven arguments, it computes the date from *year*, *month*, and (optionally) *date*, *hours*, *minutes*, *seconds* and *ms*.
>
> The [[Prototype]] property of the newly constructed object is set to the original Date prototype object, the one that is the initial value of **Date.prototype** (15.9.4.1).
>
> The [[Class]] property of the newly constructed object is set to **"Date"**.
>
> The [[Value]] property of the newly constructed object is set as follows:
>
> - 1. Call ToNumber(*year*).
> - 2. Call ToNumber(*month*).
> - 3. If *date* is supplied use ToNumber(*date*); else use **1**.
> - 4. If *hours* is supplied use ToNumber(*hours*); else use **0**.
> - 5. If *minutes* is supplied use ToNumber(*minutes*); else use **0**.
> - 6. If *seconds* is supplied use ToNumber(*seconds*); else use **0**.
> - 7. If *ms* is supplied use ToNumber(*ms*); else use **0**.
> - 8. If Result(1) is not **NaN** and 0 ≤ ToInteger(Result(1)) ≤ 99, Result(8) is 1900+ToInteger(Result(1)); otherwise, Result(8) is Result(1).
> - 9. Compute MakeDay(Result(8), Result(2), Result(3)).
> - 10. Compute MakeTime(Result(4), Result(5), Result(6), Result(7)).
> - 11. Compute MakeDate(Result(9), Result(10)).
> - 12. Set the [[Value]] property of the newly constructed object to TimeClip(UTC(Result(11))).
【F:docs/specs/ECMA-262 3.md†L6065-L6084】

### ES5 (15.9.3.1)
> When **Date** is called with two to seven arguments, it computes the date from *year*, *month*, and (optionally) *date*, *hours*, *minutes*, *seconds* and *ms*.
>
> The [[Prototype]] internal property of the newly constructed object is set to the original Date prototype object, the one that is the initial value of `Date.prototype` ([15.9.4.1](#sec-15.9.4.1)).
>
> The [[Class]] internal property of the newly constructed object is set to `"Date"`.
>
> The [[Extensible]] internal property of the newly constructed object is set to **true**.
>
> The [[PrimitiveValue]] internal property of the newly constructed object is set as follows:
>
> 1.  Let *y* be [ToNumber](#sec-9.3)(*year*).
> 2.  Let *m* be [ToNumber](#sec-9.3)(*month*).
> 3.  If *date* is supplied then let *dt* be [ToNumber](#sec-9.3)(*date*); else let *dt* be **1**.
> 4.  If *hours* is supplied then let *h* be [ToNumber](#sec-9.3)(*hours*); else let *h* be **0**.
> 5.  If *minutes* is supplied then let *min* be [ToNumber](#sec-9.3)(*minutes*); else let *min* be **0**.
> 6.  If *seconds* is supplied then let *s* be [ToNumber](#sec-9.3)(*seconds*); else let *s* be **0**.
> 7.  If *ms* is supplied then let *milli* be [ToNumber](#sec-9.3)(*ms*); else let *milli* be **0**.
> 8.  If *y* is not **NaN** and 0 ≤ [ToInteger](#sec-9.4)(*y*) ≤ 99, then let *yr* be 1900+[ToInteger](#sec-9.4)(*y*); otherwise, let *yr* be *y*.
> 9.  Let *finalDate* be [MakeDate](#sec-15.9.1.13)([MakeDay](#sec-15.9.1.12)(*yr*, *m*, *dt*), [MakeTime](#sec-15.9.1.11)(*h*, *min*, *s*, *milli*)).
> 10. Set the [[PrimitiveValue]] internal property of the newly constructed object to [TimeClip](#sec-15.9.1.14)([UTC](#sec-15.9.1.9)(*finalDate*)).
【F:docs/specs/ECMA-262 5.1.md†L9278-L9297】

### ES2015 (20.3.2.1)
> 20.3.2 The Date Constructor
> The Date constructor is the %Date% intrinsic object and the initial value of the Date property of the global
> object. When called as a constructor it creates and initializes a new Date object. When Date is called as a
> function rather than as a constructor, it returns a String representing the current time (UTC).
> The Date constructor is a single function whose behaviour is overloaded based upon the number and types of
> its arguments.
> The Date constructor is designed to be subclassable. It may be used as the value of an extends clause of a
> class definition. Subclass constructors that intend to inherit the specified Date behaviour must include a super
> call to the Date constructor to create and initialize the subclass instance with a [[DateValue]] internal slot.
>
> Date ( year, month [, date [ , hours [ , minutes [ , seconds [ , ms ] ] ] ] ] )
>
> This description applies only if the Date constructor is called with at least two arguments.
> When the Date function is called the following steps are taken:
> 1.
> 2.
> 3.
>
> Let numberOfArgs be the number of arguments passed to this function call.
> Assert: numberOfArgs ≥ 2.
> If NewTarget is not undefined, then
> a. Let y be ToNumber(year).
> b. ReturnIfAbrupt(y).
> c. Let m be ToNumber(month).
> d. ReturnIfAbrupt(m).
> e. If date is supplied, let dt be ToNumber(date); else let dt be 1.
> f. ReturnIfAbrupt(dt).
> g. If hours is supplied, let h be ToNumber(hours); else let h be 0.
> h. ReturnIfAbrupt(h).
> i. If minutes is supplied, let min be ToNumber(minutes); else let min be 0.
> j. ReturnIfAbrupt(min).
> k. If seconds is supplied, let s be ToNumber(seconds); else let s be 0.
> l. ReturnIfAbrupt(s).
> m. If ms is supplied, let milli be ToNumber(ms); else let milli be 0.
> n. ReturnIfAbrupt(milli).
> o. If y is not NaN and 0 ≤ ToInteger(y) ≤ 99, let yr be 1900+ToInteger(y); otherwise, let yr be y.
> p. Let finalDate be MakeDate(MakeDay(yr, m, dt), MakeTime(h, min, s, milli)).
> q. Let O be OrdinaryCreateFromConstructor(NewTarget, "%DatePrototype% ", « [[DateValue]]»).
> r. ReturnIfAbrupt(O).
> s. Set the [[DateValue]] internal slot of O to TimeClip(UTC(finalDate)).
> t. Return O.
> Else,
> a. Let now be the Number that is the time value (UTC) identifying the current time.
> b. Return ToDateString (now).
【F:docs/specs/ECMA-262 6.0 Date constructor excerpt.md†L3-L28】

### Interpreting “supplied” arguments

Both ES3 and ES5.1 state that when a caller omits a formal parameter the function receives the value `undefined` for that slot.【F:docs/specs/ECMA-262 3.md†L1763-L1767】 The Date constructor algorithms above then decide whether each argument was “supplied”. If an argument was supplied, the algorithms call `ToNumber` on it instead of using the default; the `ToNumber` conversion tables for both editions explicitly map `undefined` to `NaN`.【F:docs/specs/ECMA-262 3.md†L1498-L1503】【F:docs/specs/ECMA-262 5.1.md†L2833-L2842】 As a result, passing `undefined` for the `date`, `hours`, `minutes`, `seconds`, or `ms` arguments produces `NaN`, which then propagates through `MakeDay`, `MakeTime`, `MakeDate`, and `TimeClip` to yield a final `NaN` time value.

## Test262 S15.9.3.1_A6 expectations
Each Sputnik-derived test constructs a `Date` while propagating `undefined` for one of the optional arguments. Because the `DateValue` helper passes every formal parameter through to the constructor, the Date algorithm treats each slot as “supplied” and therefore converts the explicit `undefined` value to `NaN` via `ToNumber`. The source for each case is reproduced verbatim below so the exact behaviour under test is clear.

### S15.9.3.1_A6_T1 — two arguments `(year, month)`
```js
function DateValue(year, month, date, hours, minutes, seconds, ms){
  return new Date(year, month, date, hours, minutes, seconds, ms).valueOf();
}

if (!isNaN(DateValue(1899, 11))) {
  $ERROR("#1: The value should be NaN");
}

if (!isNaN(DateValue(1899, 12))) {
  $ERROR("#2: The value should be NaN");
}

if (!isNaN(DateValue(1900, 0))) {
  $ERROR("#3: The value should be NaN");
}

if (!isNaN(DateValue(1969, 11))) {
  $ERROR("#4: The value should be NaN");
}

if (!isNaN(DateValue(1969, 12))) {
  $ERROR("#5: The value should be NaN");
}

if (!isNaN(DateValue(1970, 0))) {
  $ERROR("#6: The value should be NaN");
}

if (!isNaN(DateValue(1999, 11))) {
  $ERROR("#7: The value should be NaN");
}

if (!isNaN(DateValue(1999, 12))) {
  $ERROR("#8: The value should be NaN");
}

if (!isNaN(DateValue(2000, 0))) {
  $ERROR("#9: The value should be NaN");
}

if (!isNaN(DateValue(2099, 11))) {
  $ERROR("#10: The value should be NaN");
}

if (!isNaN(DateValue(2099, 12))) {
  $ERROR("#11: The value should be NaN");
}

if (!isNaN(DateValue(2100, 0))) {
  $ERROR("#12: The value should be NaN");
}
```

### S15.9.3.1_A6_T2 — three arguments `(year, month, date)`
```js
function DateValue(year, month, date, hours, minutes, seconds, ms){
  return new Date(year, month, date, hours, minutes, seconds, ms).valueOf();
}

if (!isNaN(DateValue(1899, 11, 31))) {
  $ERROR("#1: The value should be NaN");
}

if (!isNaN(DateValue(1899, 12, 1))) {
  $ERROR("#2: The value should be NaN");
}

if (!isNaN(DateValue(1900, 0, 1))) {
  $ERROR("#3: The value should be NaN");
}

if (!isNaN(DateValue(1969, 11, 31))) {
  $ERROR("#4: The value should be NaN");
}

if (!isNaN(DateValue(1969, 12, 1))) {
  $ERROR("#5: The value should be NaN");
}

if (!isNaN(DateValue(1970, 0, 1))) {
  $ERROR("#6: The value should be NaN");
}

if (!isNaN(DateValue(1999, 11, 31))) {
  $ERROR("#7: The value should be NaN");
}

if (!isNaN(DateValue(1999, 12, 1))) {
  $ERROR("#8: The value should be NaN");
}

if (!isNaN(DateValue(2000, 0, 1))) {
  $ERROR("#9: The value should be NaN");
}

if (!isNaN(DateValue(2099, 11, 31))) {
  $ERROR("#10: The value should be NaN");
}

if (!isNaN(DateValue(2099, 12, 1))) {
  $ERROR("#11: The value should be NaN");
}

if (!isNaN(DateValue(2100, 0, 1))) {
  $ERROR("#12: The value should be NaN");
}
```

### S15.9.3.1_A6_T3 — four arguments `(year, month, date, hours)`
```js
function DateValue(year, month, date, hours, minutes, seconds, ms){
  return new Date(year, month, date, hours, minutes, seconds, ms).valueOf();
}

if (!isNaN(DateValue(1899, 11, 31, 23))) {
  $ERROR("#1: The value should be NaN");
}

if (!isNaN(DateValue(1899, 12, 1, 0))) {
  $ERROR("#2: The value should be NaN");
}

if (!isNaN(DateValue(1900, 0, 1, 0))) {
  $ERROR("#3: The value should be NaN");
}

if (!isNaN(DateValue(1969, 11, 31, 23))) {
  $ERROR("#4: The value should be NaN");
}

if (!isNaN(DateValue(1969, 12, 1, 0))) {
  $ERROR("#5: The value should be NaN");
}

if (!isNaN(DateValue(1970, 0, 1, 0))) {
  $ERROR("#6: The value should be NaN");
}

if (!isNaN(DateValue(1999, 11, 31, 23))) {
  $ERROR("#7: The value should be NaN");
}

if (!isNaN(DateValue(1999, 12, 1, 0))) {
  $ERROR("#8: The value should be NaN");
}

if (!isNaN(DateValue(2000, 0, 1, 0))) {
  $ERROR("#9: The value should be NaN");
}

if (!isNaN(DateValue(2099, 11, 31, 23))) {
  $ERROR("#10: The value should be NaN");
}

if (!isNaN(DateValue(2099, 12, 1, 0))) {
  $ERROR("#11: The value should be NaN");
}

if (!isNaN(DateValue(2100, 0, 1, 0))) {
  $ERROR("#12: The value should be NaN");
}
```

### S15.9.3.1_A6_T4 — five arguments `(year, month, date, hours, minutes)`
```js
function DateValue(year, month, date, hours, minutes, seconds, ms){
  return new Date(year, month, date, hours, minutes, seconds, ms).valueOf();
}

if (!isNaN(DateValue(1899, 11, 31, 23, 59))) {
  $ERROR("#1: The value should be NaN");
}

if (!isNaN(DateValue(1899, 12, 1, 0, 0))) {
  $ERROR("#2: The value should be NaN");
}

if (!isNaN(DateValue(1900, 0, 1, 0, 0))) {
  $ERROR("#3: The value should be NaN");
}

if (!isNaN(DateValue(1969, 11, 31, 23, 59))) {
  $ERROR("#4: The value should be NaN");
}

if (!isNaN(DateValue(1969, 12, 1, 0, 0))) {
  $ERROR("#5: The value should be NaN");
}

if (!isNaN(DateValue(1970, 0, 1, 0, 0))) {
  $ERROR("#6: The value should be NaN");
}

if (!isNaN(DateValue(1999, 11, 31, 23, 59))) {
  $ERROR("#7: The value should be NaN");
}

if (!isNaN(DateValue(1999, 12, 1, 0, 0))) {
  $ERROR("#8: The value should be NaN");
}

if (!isNaN(DateValue(2000, 0, 1, 0, 0))) {
  $ERROR("#9: The value should be NaN");
}

if (!isNaN(DateValue(2099, 11, 31, 23, 59))) {
  $ERROR("#10: The value should be NaN");
}

if (!isNaN(DateValue(2099, 12, 1, 0, 0))) {
  $ERROR("#11: The value should be NaN");
}

if (!isNaN(DateValue(2100, 0, 1, 0, 0))) {
  $ERROR("#12: The value should be NaN");
}
```

### S15.9.3.1_A6_T5 — six arguments `(year, month, date, hours, minutes, seconds)`
```js
function DateValue(year, month, date, hours, minutes, seconds, ms){
  return new Date(year, month, date, hours, minutes, seconds, ms).valueOf();
}

if (!isNaN(DateValue(1899, 11, 31, 23, 59, 59))) {
  $ERROR("#1: The value should be NaN");
}

if (!isNaN(DateValue(1899, 12, 1, 0, 0, 0))) {
  $ERROR("#2: The value should be NaN");
}

if (!isNaN(DateValue(1900, 0, 1, 0, 0, 0))) {
  $ERROR("#3: The value should be NaN");
}

if (!isNaN(DateValue(1969, 11, 31, 23, 59, 59))) {
  $ERROR("#4: The value should be NaN");
}

if (!isNaN(DateValue(1969, 12, 1, 0, 0, 0))) {
  $ERROR("#5: The value should be NaN");
}

if (!isNaN(DateValue(1970, 0, 1, 0, 0, 0))) {
  $ERROR("#6: The value should be NaN");
}

if (!isNaN(DateValue(1999, 11, 31, 23, 59, 59))) {
  $ERROR("#7: The value should be NaN");
}

if (!isNaN(DateValue(1999, 12, 1, 0, 0, 0))) {
  $ERROR("#8: The value should be NaN");
}

if (!isNaN(DateValue(2000, 0, 1, 0, 0, 0))) {
  $ERROR("#9: The value should be NaN");
}

if (!isNaN(DateValue(2099, 11, 31, 23, 59, 59))) {
  $ERROR("#10: The value should be NaN");
}

if (!isNaN(DateValue(2099, 12, 1, 0, 0, 0))) {
  $ERROR("#11: The value should be NaN");
}

if (!isNaN(DateValue(2100, 0, 1, 0, 0, 0))) {
  $ERROR("#12: The value should be NaN");
}
```

## Observed runtime results

### NuXJS
Executing the Sputnik helper against NuXJS shows that the engine coerces `undefined` to the Date defaults instead of propagating `NaN`, so each call returns a finite time value:

```
-2211667200000
-2209075200000
-2208992400000
-2208988860000
-2208988801000
```
【ff284a†L10-L15】

Calling the constructor directly illustrates the discrepancy: NuXJS treats an explicit `undefined` third argument as if it were omitted and still returns `-2211667200000` instead of `NaN`.

```
print(new Date(1899, 11).valueOf());
print(new Date(1899, 11, undefined).valueOf());
```
【26504d†L5-L7】

### Node.js
Modern engines such as Node.js (v20.19.4) follow the specification: the helper returns `NaN` for each case, and the explicit `undefined` third argument differs from the two-argument call.

```
NaN
NaN
NaN
NaN
NaN
```
【d6cf07†L11-L15】

```
console.log(new Date(1899, 11).valueOf());
console.log(new Date(1899, 11, undefined).valueOf());
```
【4c3bf0†L5-L6】

## Conclusion
All three editions of ECMA-262 examined (ES3, ES5.1, and ES2015) require arguments that are explicitly supplied as `undefined` to be converted with `ToNumber`, producing `NaN` and ultimately a `NaN` time value. The five Sputnik `S15.9.3.1_A6_T*` tests therefore match each specification and modern engines. NuXJS currently diverges by treating supplied `undefined` arguments as if they were omitted, so the failures legitimately reflect a specification incompatibility that needs to be fixed in the engine rather than dismissed as test issues.
