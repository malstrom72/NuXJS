# ES3 Test262 Failures Analysis
48 Test262 tests from the ES3 portion of Test262 still fail in NuXJS. All of these tests target ES3 semantics that NuXJS does not yet implement correctly.
| Feature | Spec Clause | Failures |
| --- | --- | ---:|
| Array | §15.4 | 9 |
| Date | §15.9 | 7 |
| Error | §15.11 | 1 |
| Function | §15.3 | 1 |
| RegExp | §15.10 | 17 |
| String | §15.5 | 11 |

The table counts only failing Test262 cases. One additional custom test,
`unconforming/readOnlyNumericProps`, documents an intentional deviation and is
excluded from these totals.

Tests that rely on the optional URI helpers (`decodeURI`, `encodeURI`, and their component variants) are excluded: cases targeting these helpers are marked as by_design, while unrelated tests that require them are tagged bad_test.
Tests expecting the global `NaN`, `Infinity`, or `undefined` properties to be immutable are tagged `not_es3`; ES3 only requires {DontEnum, DontDelete} (§15.1.1.1–15.1.1.3).

Each list below states the ES3 requirement that the corresponding test checks. NuXJS currently violates these behaviors.

For spec references, consult the Markdown edition of the ES3 spec at `docs/specs/ECMA-262 3.md`.

When an item is resolved, check it off and add a brief note citing the ES3 spec section and the regression `.io` test that verifies the fix.

### Array
- [x] built-ins/Array/arrayIndexTooLarge — property "4294967296" wraps to index 0
> #### **15.4 Array Objects**
>
> Array objects give special treatment to a certain class of property names. A property name *P* (in the form of a string value) is an *array index* if and only if ToString(ToUint32(*P*)) is equal to *P* and ToUint32(*P*) is not equal to 2<sup>32</sup>−1.
>
NuXJS result: assigning `a["4294967296"]=1` sets `a.length` to `1` and stores the value at index `0`.
Expected: property names ≥2<sup>32</sup> should create ordinary properties, leaving `length` at `0` and `a[0]` undefined.
Plan: Reject property names whose ToUint32 value is ≥2<sup>32</sup>, treating them as normal properties without updating `length`.
```io
> a=[]
> a["4294967296"]=1
> print(a.length)
< 0
-
> print(a[0])
< undefined
-
> print(a["4294967296"])
< 1
-
```
See `tests/unconforming/arrayIndexTooLarge.io` for a regression test.
  - [ ] Fixed
- [x] built-ins/Array/S15.4.5.1_A2.1_T1 — P in [4294967295, -1, true]
> ## **15.4.5.1 [[Put]] (P, V)**
>
> Array objects use a variation of the [[Put]] method used for other native ECMAScript objects (8.6.2.2).
		>
		> Assume *A* is an Array object and *P* is a string.
		>
		> When the [[Put]] method of *A* is called with property *P* and value *V*, the following steps are taken:
		>
		> - 1. Call the [[CanPut]] method of *A* with name P.
		> - 2. If Result(1) is **false**, return.
		> - 3. If *A* doesn't have a property with name *P*, go to step 7.
		> - 4. If P is **"length"**, go to step 12.

NuXJS result: assigning `true` as an index sets `x[1]` and increases length to `2`, leaving `x["true"]` undefined.
Expected: non-array keys must not affect length and should create a plain property.
Plan: In the array `[[Put]]` implementation, only string keys matching the array-index definition should adjust `length`; booleans become ordinary properties.
```io
> var x=[]
> x[true]=1
> print(x.length)
< 0
-
> print(x["true"])
< 1
-
> print(x[1])
< undefined
-
```
  - [ ] Fixed
- [x] built-ins/Array/S15.4_A1.1_T1 — Checking for boolean primitive
				> #### **15.4 Array Objects**
				>
				> Array objects give special treatment to a certain class of property names. A property name *P* (in the form of a string value) is an *array index* if and only if ToString(ToUint32(*P*)) is equal to *P* and ToUint32(*P*) is not equal to 2<sup>32</sup>−1. Every Array object has a **length** property whose value is always a nonnegative integer less than 232. The value of the **length** property is numerically greater than the name of every property whose name is an array index; whenever a property of an Array object is created or changed, other properties are adjusted as necessary to maintain this invariant. Specifically, whenever a property is added whose name is an array index, the **length** property is changed, if necessary, to be one more than the numeric value of that array index; and whenever the **length** property is changed, every property whose name is an array index whose value is not smaller than the new length is automatically deleted. This constraint applies only to properties of the Array object itself and is unaffected by **length** or array index properties that may be inherited from its prototype.

NuXJS result: assigning `true` as an index sets `x[1]` and increases length to `2`, leaving `x["true"]` undefined.
Expected: non-array keys must not affect length and should create a plain property.
Plan: Per ES3 §15.4, treat `P` as an index only when it is a string and `ToString(ToUint32(P)) === P` with `ToUint32(P) != 2^32−1`; otherwise create an ordinary property and leave `length` unchanged.
```io
> var x=[];
> x[true]=1;
> print(x.length);
< 0
-
> print(x["true"]);
< 1
-
> print(x[1]);
< undefined
-
```
See `tests/unconforming/booleanIndexCoercion.io` for a regression test.
  - [ ] Fixed
- [x] built-ins/Array/cantAssignObjectToArrayLength — assigning object to length throws *(by design)*
> #### **15.4.5.1 [[Put]] (P, V)**
>
> When the [[Put]] method of *A* is called with property "length" and value *V*, the following steps are taken:
> - 12. Compute ToUint32(*V*).
> - 13. If Result(12) is not equal to ToNumber(*V*), throw a **RangeError** exception.
>
NuXJS result: assigning an object with `valueOf` returning `23` to `a.length` throws `RangeError` and leaves length `0`.
Expected: the object should convert to `23` and set `a.length` to `23`.
Resolution: supporting object length assignment would require asynchronous conversion; NuXJS leaves this ES3 violation unimplemented.
Flagged `by_design` in `tools/testdash.json`.
```io
> a=[]
> o={valueOf:function() { return 23 }}
> print(o+10)
< 33

> a.length=o
> print(a.length)
< 23

> o={valueOf:function() { return 47 }}
> s='length';
> a[s]=o
> print(a.length)
< 47
-
```
See `tests/unconforming/cantAssignObjectToArrayLength.io` for a regression test.
- [x] Fixed
- [x] built-ins/Array/readOnlyNumericProps — writes override read-only numeric prototype properties *(by design)*
	> #### **8.6.2.2 [[Put]] (P, V)**
	>
	> If a property with name *P* exists and is **ReadOnly**, return without doing anything.

NuXJS result: assigning to `a[123]` creates an own property even when `Array.prototype` defines a read-only property "123".
Expected: the write should be ignored and the inherited value remain.
Plan: Accepted deviation for performance — ES3 programs cannot observe read-only numeric prototype indices. No change planned.
```io
> Object.defineProperty(Array.prototype, '123', { value: 456, writable: false })
> a=[]
> a[123]=789
> print(a[123])
< 789
```
See `tests/unconforming/readOnlyNumericProps.io` for a regression test.
  - [ ] Fixed
- [x] built-ins/Array/prototype/pop/S15.4.4.6_A2_T2 — If ToUint32(length) equal zero, call the [[Put]] method	 of this object with arguments "length" and 0 and return undefined
	> ## **15.4.4.6 Array.prototype.pop ( )**
	> 
	> The last element of the array is removed from the array and returned.
	> 
	> - 1. Call the [[Get]] method of this object with argument "**length**".
	> - 2. Call ToUint32(Result(1)).
	> - 3. If Result(2) is not zero, go to step 6.
	> - 4. Call the [[Put]] method of this object with arguments "**length**" and Result(2).
	> - 5. Return **undefined**.
	> - 6. Call ToString(Result(2)–1).
		> - 7. Call the [[Get]] method of this object with argument Result(6).
		> - 8. Call the [[Delete]] method of this object with argument Result(6).
NuXJS result: `obj.length = Infinity` followed by `obj.pop()` returns `undefined` but sets `obj.length` to `0`.
Expected: `obj.pop()` should leave `length` at `9007199254740990` (2^53−2).
Plan: Prior to ES3 §15.4.4.6 steps 1–8, normalize `length` by replacing non‑finite or ≥2^53 values with `2^53−2` so `[[Put]]('length', ToUint32(length))` doesn't reset it to zero.
```io
> obj={}
> obj.length=Number.POSITIVE_INFINITY
> obj.pop=Array.prototype.pop
> print(obj.pop())
< undefined
-
> print(obj.length)
< 9007199254740990
-
```
See `tests/unconforming/arrayPopLengthInfinity.io` for a regression test.
  - [ ] Fixed
- [x] built-ins/Array/prototype/pop/S15.4.4.6_A4_T2 — [[Prototype]] of Array instance is Array.prototype, [[Prototype] of Array.prototype is Object.prototype
	> ## **15.4.4.6 Array.prototype.pop ( )**
	> 
	> The last element of the array is removed from the array and returned.
	> 
	> - 1. Call the [[Get]] method of this object with argument "**length**".
	> - 2. Call ToUint32(Result(1)).
	> - 3. If Result(2) is not zero, go to step 6.
	> - 4. Call the [[Put]] method of this object with arguments "**length**" and Result(2).
	> - 5. Return **undefined**.
	> - 6. Call ToString(Result(2)–1).
	> - 7. Call the [[Get]] method of this object with argument Result(6).
	> - 8. Call the [[Delete]] method of this object with argument Result(6).
NuXJS result: borrowing `pop` for a plain object leaves index `1` intact, so the own property masks the inherited `-1`.
Expected: `pop` should delete index `1`, revealing the prototype value.
Plan: When `pop` is borrowed, after retrieving the element (steps 6–7), call `[[Delete]](ToString(length−1))` per ES3 §15.4.4.6 step 8 so the last own index is removed and prototype values surface.
```io
> Object.prototype[1]=-1
> Object.prototype.pop=Array.prototype.pop
> var x={0:0,1:1,length:2}
> print(x.pop())
< 1
-
> print(x[1])
< -1
-
```
See `tests/unconforming/arrayPopPrototypeDelete.io` for a regression test.
  - [ ] Fixed
- [x] built-ins/Array/prototype/push/S15.4.4.7_A2_T2 — The arguments are appended to the end of the array, in	 the order in which they appear. The new length of the array is returned  as the result of the call
	> ## **15.4.4.7 Array.prototype.push ( [ item1 [ , item2 [ , … ] ] ] )**
	> 
	> The arguments are appended to the end of the array, in the order in which they appear. The new length of the array is returned as the result of the call.
	> 
	> When the **push** method is called with zero or more arguments *item1, item2*, etc., the following steps are taken:
	> 
	> - 1. Call the [[Get]] method of this object with argument "**length**".
	> - 2. Let *n* be the result of calling ToUint32(Result(1)).
	> - 3. Get the next argument in the argument list; if there are no more arguments, go to step 7.
	> - 4. Call the [[Put]] method of this object with arguments ToString(*n*) and Result(3).
		> - 5. Increase *n* by 1.
		> - 6. Go to step 3.
NuXJS result: `obj.length = Infinity; obj.push(-4)` returns `1` and shrinks `length` to `1`.
Expected: a `TypeError` and `length` remaining `Infinity`.
Plan: Follow ES3 §15.4.4.7 steps 1–3: compute `n = ToUint32(length)` and compare it to `ToNumber(length)`; if they differ (e.g., `Infinity` or >2^32−1), throw `TypeError` before any `[[Put]]` occurs.
```io
> obj={}
> obj.length=Number.POSITIVE_INFINITY
> obj.push=Array.prototype.push
> try{obj.push(-4)}catch(e){print(e.name)}
< TypeError
-
> print(obj.length)
< Infinity
-
> print(obj[9007199254740991])
< undefined
-
```
See `tests/unconforming/arrayPushLengthInfinity.io` for a regression test.
  - [ ] Fixed
- [x] built-ins/Array/prototype/shift/S15.4.4.9_A3_T3 — length is arbitrarily
		> ## **15.4.4.9 Array.prototype.shift ( )**
	> 
	> The first element of the array is removed from the array and returned.
	> 
	> - 1. Call the [[Get]] method of this object with argument "**length**".
	> - 2. Call ToUint32(Result(1)).
	> - 3. If Result(2) is not zero, go to step 6.
	> - 4. Call the [[Put]] method of this object with arguments "**length**" and Result(2).
	> - 5. Return **undefined**.
	> - 6. Call the [[Get]] method of this object with argument **0**.
		> - 7. Let *k* be 1.
		> - 8. If *k* equals Result(2), go to step 18.
NuXJS result: `obj.length = -4294967294; obj.shift()` returns `'x'` and sets `length` to `1`.
Expected: the call should return `undefined`, leave `length` `0`, and keep elements unchanged.
Plan: If `ToUint32(length)` differs from the numeric value, clamp `length` to `0` and return `undefined` without moving elements.
```io
> obj={}
> obj.shift=Array.prototype.shift
> obj[0]='x'
> obj[1]='y'
> obj.length=-4294967294
> print(obj.shift())
< undefined
-
> print(obj.length)
< 0
-
> print(obj[0])
< x
-
> print(obj[1])
< y
-
```
See `tests/unconforming/arrayShiftNegativeLength.io` for a regression test.
  - [ ] Fixed
- [x] built-ins/Array/prototype/shift/S15.4.4.9_A4_T2 — [[Prototype]] of Array instance is Array.prototype, [[Prototype] of Array.prototype is Object.prototype
	> ## **15.4.4.9 Array.prototype.shift ( )**
	> 
	> The first element of the array is removed from the array and returned.
	> 
	> - 1. Call the [[Get]] method of this object with argument "**length**".
	> - 2. Call ToUint32(Result(1)).
	> - 3. If Result(2) is not zero, go to step 6.
	> - 4. Call the [[Put]] method of this object with arguments "**length**" and Result(2).
	> - 5. Return **undefined**.
	> - 6. Call the [[Get]] method of this object with argument **0**.
	> - 7. Let *k* be 1.
	> - 8. If *k* equals Result(2), go to step 18.
NuXJS result: borrowing `shift` for a plain object leaves property `1` as `1` instead of exposing the prototype's `-1`.
Expected: index `1` should be deleted and fall back to `-1`, with `length` decremented to `1`.
Plan: When borrowed, `shift` must delete the property at `length - 1` and reindex remaining elements so inherited values surface and `length` decreases.
```io
> Object.prototype[1] = -1
> Object.prototype.length = 2
> Object.prototype.shift = Array.prototype.shift
> var x = {0:0,1:1}
> print(x.shift())
< 0
-
> print(x[0])
< 1
-
> print(x[1])
< -1
-
> print(x.length)
< 1
-
```
See `tests/unconforming/arrayShiftPrototypeDelete.io` for a regression test.
  - [ ] Fixed
- [x] built-ins/Array/prototype/toLocaleString/S15.4.4.3_A1_T1 — it is the function that should be invoked
	> #### **15.4.4.3 Array.prototype.toLocaleString ( )**
	> 
	> The elements of the array are converted to strings using their **toLocaleString** methods, and these strings are then concatenated, separated by occurrences of a separator string that has been derived in an implementation-defined locale-specific way. The result of calling this function is intended to be analogous to the result of **toString**, except that the result of this function is intended to be localespecific.
	> 
	> The result is calculated as follows:
	> 
	> - 1. Call the [[Get]] method of this object with argument **"length"**.
	> - 2. Call ToUint32(Result(1)).
	> - 3. Let *separator* be the list-separator string appropriate for the host environment's current locale (this is derived in an implementation-defined way).
	> 
		> - 4. Call ToString(*separator*).
		> - 5. If Result(2) is zero, return the empty string.
NuXJS result: element `toLocaleString` methods are never invoked, leaving counters untouched.
Expected: each defined element's `toLocaleString` should run.
Plan: During concatenation, iterate over all own indices from `0` to `length - 1`, calling each element's `toLocaleString`.
```io
> var n=0
> var obj={toLocaleString:function(){n++;return 'obj'}}
> var arr=[undefined,obj,null,obj,obj]
> arr.toLocaleString()
> print(n)
< 3
-
```
See `tests/unconforming/arrayToLocaleStringCallsElements.io` for a regression test.
  - [ ] Fixed
- [x] built-ins/Array/prototype/toLocaleString/S15.4.4.3_A3_T1 — "[[Prototype]] of Array instance is Array.prototype"
	> #### **15.4.4.3 Array.prototype.toLocaleString ( )**
	> 
	> The elements of the array are converted to strings using their **toLocaleString** methods, and these strings are then concatenated, separated by occurrences of a separator string that has been derived in an implementation-defined locale-specific way. The result of calling this function is intended to be analogous to the result of **toString**, except that the result of this function is intended to be localespecific.
	> 
	> The result is calculated as follows:
	> 
	> - 1. Call the [[Get]] method of this object with argument **"length"**.
	> - 2. Call ToUint32(Result(1)).
	> - 3. Let *separator* be the list-separator string appropriate for the host environment's current locale (this is derived in an implementation-defined way).
	> 
	> - 4. Call ToString(*separator*).
	> - 5. If Result(2) is zero, return the empty string.

		NuXJS result: elements inherited from `Array.prototype` are skipped, leaving the invocation counter at `0`.
Expected: both the own and prototype elements should invoke their `toLocaleString` methods, producing `2`.
Plan: Include inherited indices in the iteration so prototype-defined elements also run their `toLocaleString` methods.
```io
	> var n = 0;
	> var obj = {toLocaleString:function(){n++;return 'obj';}};
	> Array.prototype[1] = obj;
	> var x = [obj];
	> x.length = 2;
	> x.toLocaleString();
	> print(n);
	< 2
	-
	```
	See `tests/unconforming/arrayToLocaleStringPrototypeElement.io` for a regression test.
	  - [ ] Fixed
### Date
- [x] built-ins/Date/S15.9.3.1_A6_T1 — 2 arguments, (year, month)
		> ## **15.9.3.1 new Date (year, month [, date [, hours [, minutes [, seconds [, ms ] ] ] ] ] )**
		>
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

				NuXJS result: `new Date(1970, undefined)` yields `0` instead of `NaN`.
								Expected: explicitly passing `undefined` for *month* should produce `NaN` because step 2 applies `ToNumber(undefined)`.
								Plan: Always apply `ToNumber` to the `month` argument; if it is `undefined`, the resulting `NaN` causes the constructor to produce `NaN` rather than defaulting to `0`.

				```io
		> print(isNaN(new Date(1970, undefined)))
		< true
		-
		```
		See `tests/unconforming/dateYearMonthUndefined.io` for a regression test.
		  - [ ] Fixed
- [x] built-ins/Date/S15.9.3.1_A6_T2 — 3 arguments, (year, month, date)
		> ## **15.9.3.1 new Date (year, month [, date [, hours [, minutes [, seconds [, ms ] ] ] ] ] )**
		>
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

				NuXJS result: `new Date(1970,0,undefined)` returns a valid date instead of `NaN`.
				Expected: providing `undefined` for *date* should invoke `ToNumber(undefined)` and yield `NaN`.
				Plan: Apply `ToNumber` to *date* before defaulting so an explicit `undefined` becomes `NaN`.

				```io
				> print(isNaN(new Date(1970, 0, undefined)))
		< true
		-
		```
		See `tests/unconforming/dateYearMonthDateUndefined.io` for a regression test.
		  - [ ] Fixed
- [x] built-ins/Date/S15.9.3.1_A6_T3 — 4 arguments, (year, month, date, hours)
	> ## **15.9.3.1 new Date (year, month [, date [, hours [, minutes [, seconds [, ms ] ] ] ] ] )**
	> 
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
		NuXJS result: `new Date(1970, 0, 1, undefined)` yields `0` instead of `NaN`.
		Expected: providing `undefined` for *hours* should produce `NaN`.
		Plan: Coerce *hours* with `ToNumber` before defaulting so `undefined` results in `NaN`.
		```io
		> print(isNaN(new Date(1970, 0, 1, undefined)))
	< true
	-
	```
	See `tests/unconforming/dateYearMonthDateHoursUndefined.io` for a regression test.
	  - [ ] Fixed
- [x] built-ins/Date/S15.9.3.1_A6_T4 — 5 arguments, (year, month, date, hours, minutes)
	> ## **15.9.3.1 new Date (year, month [, date [, hours [, minutes [, seconds [, ms ] ] ] ] ] )**
	> 
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
		NuXJS result: `new Date(1970, 0, 1, 0, undefined)` produces `0` instead of `NaN`.
		Expected: an explicit `undefined` *minutes* argument must yield `NaN`.
		Plan: Convert *minutes* via `ToNumber` before applying the default `0` to ensure `undefined` produces `NaN`.
		```io
	> print(isNaN(new Date(1970, 0, 1, 0, undefined)))
	< true
	-
	```
	See `tests/unconforming/dateYearMonthDateHoursMinutesUndefined.io` for a regression test.
	  - [ ] Fixed
- [x] built-ins/Date/S15.9.3.1_A6_T5 — 6 arguments, (year, month, date, hours, minutes, seconds)
	> ## **15.9.3.1 new Date (year, month [, date [, hours [, minutes [, seconds [, ms ] ] ] ] ] )**
	> 
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
		NuXJS result: `new Date(1970, 0, 1, 0, 0, undefined)` returns `0` instead of `NaN`.
		Expected: `undefined` for *seconds* should propagate to `NaN`.
		Plan: Apply `ToNumber` to *seconds* prior to defaulting so explicit `undefined` yields `NaN`.
		```io
	> print(isNaN(new Date(1970, 0, 1, 0, 0, undefined)))
	< true
	-
	```
	See `tests/unconforming/dateYearMonthDateHoursMinutesSecondsUndefined.io` for a regression test.
	  - [ ] Fixed
- [x] built-ins/Date/TimeClip_negative_zero — TimeClip converts negative zero to positive zero
		> ## **15.9.1.14 TimeClip (time)**
		>
		> The operator TimeClip calculates a number of milliseconds from its argument, which must be an ECMAScript number value. This operator functions as follows:
		>
		> - 1. If *time* is not finite, return **NaN**.
		> - 2. If abs(Result(1)) > **8.64 x 10<sup>15</sup>**, return **NaN**.
		> - 3. Return an implementation-dependent choice of either ToInteger(Result(2)) or ToInteger(Result(2)) + (**+0**). (Adding a positive zero converts −**0** to **+0**.)
		>
		> ## *NOTE*
		>
		> *The point of step 3 is that an implementation is permitted a choice of internal representations of time values, for example as a 64-bit signed integer or as a 64-bit floating-point value. Depending on the implementation, this internal representation may or may not distinguish* <sup>−</sup>*0 and +0.*
	   
		   NuXJS result: `new Date(-0).getTime()` preserves −0, so `1/new Date(-0).getTime()` yields `-Infinity`.
		   Expected: TimeClip must convert −0 to +0, resulting in `Infinity`.
		   Plan: Add `+0` after `ToInteger(time)` in TimeClip to normalize −0 to +0.

		   ```io
	   > print(1/new Date(-0).getTime())
	   < Infinity
	   -
	   ```

	   See `tests/unconforming/dateTimeClipNegativeZero.io` for a regression test.

		 - [ ] Fixed
- [x] built-ins/Date/prototype/setFullYear/15.9.5.40_1 — Date.prototype.setFullYear - Date.prototype is itself not an instance of Date
> #### **15.9.5 Properties of the Date Prototype Object**
>
> None of these functions are generic; a **TypeError** exception is thrown if the **this** value is not an object for which the value of the internal [[Class]] property is **"Date"**.
>
NuXJS result: `Date.prototype.setFullYear.call(Date.prototype, 1970)` returns `0` instead of throwing.
Expected: non-Date receivers must raise a `TypeError`.
Plan: Verify that the `this` value has [[Class]] "Date" before proceeding and throw `TypeError` otherwise.
```io
> try { Date.prototype.setFullYear.call(Date.prototype, 1970); } catch (e) { print(e.name); }
< TypeError
-
```
See `tests/unconforming/datePrototypeSetFullYearInvalidThis.io` for a regression test.
  - [ ] Fixed

### Error
- [x] built-ins/Error/S15.11.1.1_A1_T1 — Checking message property of different error objects
		> #### **15.11.1.1 Error (message)**
		>
		> The [[Prototype]] property of the newly constructed object is set to the original Error prototype object, the one that is the initial value of **Error.prototype** (15.11.3.1).
		>
		> The [[Class]] property of the newly constructed object is set to **"Error"**.
		>
		> If the argument *message* is not **undefined**, the **message** property of the newly constructed object is set to ToString(*message*).

	   NuXJS result: calling `Error()` without an argument defines an own `message` property set to the empty string.
	   Expected: when the `message` parameter is `undefined`, the constructor must leave `message` unset so that `hasOwnProperty("message")` is `false`.
	   Plan: Only define an own `message` property when the argument is not `undefined`.

```io
> var e = Error()
	   > print(e.hasOwnProperty("message"))
	   < false
	   -
	   ```

	See `tests/unconforming/errorFunctionUndefinedMessage.io` for a regression test.

		- [x] Fixed in `src/stdlib.js`; omits own `message` when called without argument (§15.11.1.1).
		Regression: `tests/unconforming/errorFunctionUndefinedMessage.io`.
- [x] built-ins/Error/S15.11.2.1_A1_T1 — Checking message property of different error objects
		> ## **15.11.2.1 new Error (message)**
		>
		> The [[Prototype]] property of the newly constructed object is set to the original Error prototype object, the one that is the initial value of **Error.prototype** (15.11.3.1).
		>
		> The [[Class]] property of the newly constructed Error object is set to **"Error"**.
		>
		> If the argument *message* is not **undefined**, the **message** property of the newly constructed object is set to ToString(*message*).

	   NuXJS result: `new Error()` also creates an own `message` property with value `""` even when no argument is supplied.
	   Expected: absent a `message` argument, the instance should inherit the empty string from `Error.prototype` and report `hasOwnProperty("message") === false`.
	   Plan: The constructor should omit defining `message` when the parameter is `undefined`, letting the prototype's value be inherited.

```io
> var e = new Error()
		   > print(e.hasOwnProperty("message"))
		   < false
		   -
		   ```
			See `tests/unconforming/errorConstructorUndefinedMessage.io` for a regression test.
			  - [x] Fixed in `src/stdlib.js`; `new Error()` now inherits `message` when argument is absent (§15.11.2.1).
				Regression: `tests/unconforming/errorConstructorUndefinedMessage.io`.

- [x] built-ins/Error/prototype/name/15.11.4.2-1 — Error.prototype.name is not enumerable.
	   > #### **15.11.4.2 Error.prototype.name**
	   >
	   > The initial value of **Error.prototype.name** is "**Error**".
	   >
	   > In every case, the **length** property of a built-in Function object described in this section has the attributes { ReadOnly, DontDelete, DontEnum }. Every other property described in this section has the attribute { DontEnum } (and no others) unless otherwise specified.

	   NuXJS result: iterating an `Error` instance reveals the `name` property.
	   Expected: `name` should not be enumerated.
	   Plan: Define `Error.prototype.name` with the {DontEnum} attribute so for-in loops skip it.

```io
> var e = new Error("msg")
	   > var seen = false
		   > for (var p in e) if (p === "name") seen = true
		   > print(seen)
		   < false
		   -
		   ```
			See `tests/unconforming/errorPrototypeNameEnumerable.io` for a regression test.
			  - [ ] Fixed

### Function
- [x] built-ins/Function/prototype/S15.3.4_A5 — Checking if creating "new Function.prototype object" fails
	> ## **15.3.4 Properties of the Function Prototype Object**
	> 
	> The Function prototype object is itself a Function object (its [[Class]] is **"Function"**) that, when invoked, accepts any arguments and returns **undefined**.
	> 
	> The value of the internal [[Prototype]] property of the Function prototype object is the Object prototype object (15.3.2.1).
	> 
	> It is a function with an "empty body"; if it is invoked, it merely returns **undefined**.
	> 
		> #### **15.3**
		>
		> None of the built-in functions described in this section shall implement the internal [[Construct]] method unless otherwise specified in the description of a particular function.

		NuXJS result: `new Function.prototype()` creates an object instead of throwing.
		Expected: since `Function.prototype` lacks a [[Construct]] method, invoking it with `new` must throw `TypeError`.
		Plan: Remove or override the [[Construct]] behavior of `Function.prototype` so attempts to instantiate it throw `TypeError`.
```io
> try { new Function.prototype(); } catch (e) { print(e.name); }
< TypeError
		-
		```
		See `tests/unconforming/functionPrototypeConstructible.io` for a regression test.
		  - [ ] Fixed

### RegExp
		>
	> The production *CharacterClassEscape* **:: d** evaluates by returning the ten-element set of characters containing the characters **0** through **9** inclusive.
	> 
	> The production *CharacterClassEscape* **:: D** evaluates by returning the set of all characters not included in the set returned by *CharacterClassEscape* **:: d**.
	> 
	> The production *CharacterClassEscape* **:: s** evaluates by returning the set of characters containing the characters that are on the right-hand side of the *WhiteSpace* (7.2) or *LineTerminator* (7.3) productions.
	> 
	> The production *CharacterClassEscape* **:: S** evaluates by returning the set of all characters not included in the set returned by *CharacterClassEscape* **:: s**.
	> 
	> The production *CharacterClassEscape* **:: w** evaluates by returning the set of characters containing the sixty-three characters:
- [x] built-ins/RegExp/S15.10.2.12_A2_T1 — WhiteSpace
		> #### **15.10.2.12 CharacterClassEscape**
	> 
	> The production *CharacterClassEscape* **:: d** evaluates by returning the ten-element set of characters containing the characters **0** through **9** inclusive.
	> 
	> The production *CharacterClassEscape* **:: D** evaluates by returning the set of all characters not included in the set returned by *CharacterClassEscape* **:: d**.
	> 
	> The production *CharacterClassEscape* **:: s** evaluates by returning the set of characters containing the characters that are on the right-hand side of the *WhiteSpace* (7.2) or *LineTerminator* (7.3) productions.
	> 
		> The production *CharacterClassEscape* **:: S** evaluates by returning the set of all characters not included in the set returned by *CharacterClassEscape* **:: s**.
		>
		> The production *CharacterClassEscape* **:: w** evaluates by returning the set of characters containing the sixty-three characters:
NuXJS result: `/\s/.test("\u1680")` and `/\s/.test("\u2000")` both yield `false`, while their `/\S/` counterparts return `true`.
Expected: both `\u1680` (OGHAM SPACE MARK) and `\u2000` (EN QUAD) are listed in *WhiteSpace*, so `/\s/` should match and `/\S/` should not.
NuXJS deliberately omits certain Unicode space separators, including `\u1680`, so `\s` does not match them.
```io
> print(/\s/.test("\u1680"))
< false
-
> print(/\S/.test("\u1680"))
< true
-
> print(/\s/.test("\u2000"))
< true
-
> print(/\S/.test("\u2000"))
< false
-
```
See `tests/unconforming/regExpWhiteSpace.io` and `tests/unconforming/regExpWhiteSpace2000.io` for regression tests.
  - [ ] Fixed
	> #### **15.10.2.8 Atom**
	> 
	> The production *Atom* **::** *PatternCharacter* evaluates as follows:
	> 
	> - 1. Let *ch* be the character represented by *PatternCharacter*.
	> - 2. Let *A* be a one-element CharSet containing the character *ch*.
	> - 3. Call *CharacterSetMatcher*(*A*, **false**) and return its Matcher result.
	> 
	> The production *Atom* **:: .** evaluates as follows:
	> 
	> - 1. Let *A* be the set of all characters except the four line terminator characters <LF>, <CR>, <LS>, or <PS>.
	> - 2. Call *CharacterSetMatcher*(*A*, **false**) and return its Matcher result.
- [x] built-ins/RegExp/prototype/exec/S15.10.6.2_A1_T10 — String is 1.01 and RegExp is /1|12/
	> #### **15.10.6.2 RegExp.prototype.exec(string)**
	> 
	> Performs a regular expression match of *string* against the regular expression and returns an Array object containing the results of the match, or **null** if the string did not match
	> 
	> The string ToString(*string*) is searched for an occurrence of the regular expression pattern as follows:
	> 
	> - 1. Let *S* be the value of ToString(*string*).
	> - 2. Let *length* be the length of *S*.
	> - 3. Let *lastIndex* be the value of the **lastIndex** property.
	> - 4. Let *i* be the value of ToInteger(*lastIndex*).
	> - 5. If the **global** property is **false**, let *i* = 0.
	> - 6. If *I* < 0 or *I* > *length* then set **lastIndex** to 0 and return **null**.
NuXJS result: `/1|12/.exec(1.01)` returns `null`.
Expected: `ToString(1.01)` is `"1.01"`, so the pattern should match `"1"` at index `0`.
Plan: Coerce non-string inputs with `ToString` before executing the pattern so number primitives are matched as strings.
```io
> var r=/1|12/.exec(1.01)
> print(r[0])
< 1
-
> print(r.index)
< 0
-
```
See `tests/unconforming/regExpExecNumberPrimitive.io` for a regression test.
  - [ ] Fixed
- [x] built-ins/RegExp/prototype/exec/S15.10.6.2_A1_T11 — String is new Number(1.012) and RegExp is /2|12/
		> #### **15.10.6.2 RegExp.prototype.exec(string)**
	> 
	> Performs a regular expression match of *string* against the regular expression and returns an Array object containing the results of the match, or **null** if the string did not match
	> 
	> The string ToString(*string*) is searched for an occurrence of the regular expression pattern as follows:
	> 
	> - 1. Let *S* be the value of ToString(*string*).
	> - 2. Let *length* be the length of *S*.
	> - 3. Let *lastIndex* be the value of the **lastIndex** property.
	> - 4. Let *i* be the value of ToInteger(*lastIndex*).
		> - 5. If the **global** property is **false**, let *i* = 0.
		> - 6. If *I* < 0 or *I* > *length* then set **lastIndex** to 0 and return **null**.
NuXJS result: executing `/2|12/` on `new Number(1.012)` yields match `"je"` at index `3`.
Expected: the string "1.012" should match `"12"` at index `3`.
Plan: Apply `ToString` to object-wrapped numbers so their string form participates in the match.
```io
> var r=/2|12/.exec(new Number(1.012))
> print(r[0])
< 12
-
> print(r.index)
< 3
-
```
See `tests/unconforming/regExpExecNumberObject.io` for a regression test.
  - [ ] Fixed
- [x] built-ins/RegExp/prototype/exec/S15.10.6.2_A1_T12 — String is {toString:function(){return Math.PI;}} and RegExp is /\.14/
		> #### **15.10.6.2 RegExp.prototype.exec(string)**
	> 
	> Performs a regular expression match of *string* against the regular expression and returns an Array object containing the results of the match, or **null** if the string did not match
	> 
	> The string ToString(*string*) is searched for an occurrence of the regular expression pattern as follows:
	> 
	> - 1. Let *S* be the value of ToString(*string*).
	> - 2. Let *length* be the length of *S*.
	> - 3. Let *lastIndex* be the value of the **lastIndex** property.
	> - 4. Let *i* be the value of ToInteger(*lastIndex*).
		> - 5. If the **global** property is **false**, let *i* = 0.
		> - 6. If *I* < 0 or *I* > *length* then set **lastIndex** to 0 and return **null**.
NuXJS result: executing `/\.14/` on an object whose `toString` returns `Math.PI` produces match `"obj"` at index `1`.
Expected: the string "3.141592653589793" should match `".14"` at index `1`.
Plan: Use `ToString` on arbitrary objects and coerce the result to a string even if `toString` returns a number.
```io
> var r=/\.14/.exec({toString:function(){return Math.PI;}})
> print(r[0])
< .14
-
> print(r.index)
< 1
-
```
See `tests/unconforming/regExpExecToStringPi.io` for a regression test.
  - [ ] Fixed
- [x] built-ins/RegExp/prototype/exec/S15.10.6.2_A1_T13 — String is true and RegExp is /t[a-b|q-s]/
	> #### **15.10.6.2 RegExp.prototype.exec(string)**
	> 
	> Performs a regular expression match of *string* against the regular expression and returns an Array object containing the results of the match, or **null** if the string did not match
	> 
	> The string ToString(*string*) is searched for an occurrence of the regular expression pattern as follows:
	> 
	> - 1. Let *S* be the value of ToString(*string*).
	> - 2. Let *length* be the length of *S*.
	> - 3. Let *lastIndex* be the value of the **lastIndex** property.
	> - 4. Let *i* be the value of ToInteger(*lastIndex*).
	> - 5. If the **global** property is **false**, let *i* = 0.
	> - 6. If *I* < 0 or *I* > *length* then set **lastIndex** to 0 and return **null**.
NuXJS result: `/t[a-b|q-s]/.exec(true)` returns `null`.
Expected: `ToString(true)` is `\"true\"`, so the pattern should match `\"tr\"` at index `0`.
Plan: Convert boolean primitives via `ToString` so their textual form is searched.
```io
> var r=/t[a-b|q-s]/.exec(true)
> print(r[0])
< tr
-
> print(r.index)
< 0
-
```
See `tests/unconforming/regExpExecBooleanPrimitive.io` for a regression test.
  - [ ] Fixed
- [x] built-ins/RegExp/prototype/exec/S15.10.6.2_A1_T14 — String is new Boolean and RegExp is /AL|se/
		> #### **15.10.6.2 RegExp.prototype.exec(string)**
	> 
	> Performs a regular expression match of *string* against the regular expression and returns an Array object containing the results of the match, or **null** if the string did not match
	> 
	> The string ToString(*string*) is searched for an occurrence of the regular expression pattern as follows:
	> 
	> - 1. Let *S* be the value of ToString(*string*).
	> - 2. Let *length* be the length of *S*.
	> - 3. Let *lastIndex* be the value of the **lastIndex** property.
	> - 4. Let *i* be the value of ToInteger(*lastIndex*).
		> - 5. If the **global** property is **false**, let *i* = 0.
		> - 6. If *I* < 0 or *I* > *length* then set **lastIndex** to 0 and return **null**.
NuXJS result: executing `/AL|se/` on `new Boolean(false)` yields match `"je"` at index `3`.
Expected: the string "false" should match `"se"` at index `3`.
Plan: Coerce Boolean objects with `ToString` before matching.
```io
> var r=/AL|se/.exec(new Boolean(false))
> print(r[0])
< se
-
> print(r.index)
< 3
-
```
See `tests/unconforming/regExpExecBooleanObject.io` for a regression test.
  - [ ] Fixed
- [x] built-ins/RegExp/prototype/exec/S15.10.6.2_A1_T15 — "String is {toString:function(){return false;}} and RegExp is /LS/i"
		> #### **15.10.6.2 RegExp.prototype.exec(string)**
	> 
	> Performs a regular expression match of *string* against the regular expression and returns an Array object containing the results of the match, or **null** if the string did not match
	> 
	> The string ToString(*string*) is searched for an occurrence of the regular expression pattern as follows:
	> 
	> - 1. Let *S* be the value of ToString(*string*).
	> - 2. Let *length* be the length of *S*.
	> - 3. Let *lastIndex* be the value of the **lastIndex** property.
	> - 4. Let *i* be the value of ToInteger(*lastIndex*).
		> - 5. If the **global** property is **false**, let *i* = 0.
		> - 6. If *I* < 0 or *I* > *length* then set **lastIndex** to 0 and return **null**.
NuXJS result: executing `/LS/i` on an object whose `toString` returns `false` matches `"bj"` at index `2`.
Expected: the string "false" should match `"ls"` at index `2`.
Plan: If `toString` yields a non-string primitive, run `ToString` on that value so `false` becomes "false" before matching.
```io
> var r=/LS/i.exec({toString:function(){return false;}})
> print(r[0])
< ls
-
> print(r.index)
< 2
-
```
See `tests/unconforming/regExpExecToStringFalse.io` for a regression test.
  - [ ] Fixed
- [x] built-ins/RegExp/prototype/exec/S15.10.6.2_A1_T17 — String is `null` and RegExp is `/ll|l/`
		> #### **15.10.6.2 RegExp.prototype.exec(string)**
		>
		> Performs a regular expression match of *string* against the regular expression and returns an Array object containing the results of the match, or **null** if the string did not match
		>
		> The string ToString(*string*) is searched for an occurrence of the regular expression pattern as follows:
		>
		> - 1. Let *S* be the value of ToString(*string*).
		> - 2. Let *length* be the length of *S*.
		> - 3. Let *lastIndex* be the value of the **lastIndex** property.
		> - 4. Let *i* be the value of ToInteger(*lastIndex*).
		> - 5. If the **global** property is **false**, let *i* = 0.
		> - 6. If *I* < 0 or *I* > *length* then set **lastIndex** to 0 and return **null**.
		NuXJS result: `/ll|l/.exec(null)` returns `null`.
		Expected: coercing `null` to "null" should match `"ll"` at index `2`.
		Plan: Apply `ToString` to `null` so the regexp runs on "null" and finds "ll".

		```io
		> var r = /ll|l/.exec(null)
		> print(r[0])
		< ll
		-
		> print(r.index)
		< 2
		-
		> print(r.input)
		< null
		-
		```
		See `tests/unconforming/regExpExecNullString.io` for a regression test.
		  - [ ] Fixed
- [x] built-ins/RegExp/prototype/exec/S15.10.6.2_A1_T18 — String is `undefined` and RegExp is `/nd|ne/`
		> #### **15.10.6.2 RegExp.prototype.exec(string)**
		>
		> Performs a regular expression match of *string* against the regular expression and returns an Array object containing the results of the match, or **null** if the string did not match
		>
		> The string ToString(*string*) is searched for an occurrence of the regular expression pattern as follows:
		>
		> - 1. Let *S* be the value of ToString(*string*).
		> - 2. Let *length* be the length of *S*.
		> - 3. Let *lastIndex* be the value of the **lastIndex** property.
		> - 4. Let *i* be the value of ToInteger(*lastIndex*).
		> - 5. If the **global** property is **false**, let *i* = 0.
		> - 6. If *I* < 0 or *I* > *length* then set **lastIndex** to 0 and return **null**.
		NuXJS result: `/nd|ne/.exec(undefined)` returns `null`.
		Expected: converting `undefined` to "undefined" should match `"nd"` at index `1`.
		Plan: Convert `undefined` via `ToString` before executing the pattern.

		```io
		> var r = /nd|ne/.exec(undefined)
		> print(r[0])
		< nd
		-
		> print(r.index)
		< 1
		-
		> print(r.input)
		< undefined
		-
		```
		See `tests/unconforming/regExpExecUndefinedString.io` for a regression test.
		  - [ ] Fixed
- [x] built-ins/RegExp/prototype/exec/S15.10.6.2_A1_T19 — String is `void 0` and RegExp is `/e{1}/`
		> #### **15.10.6.2 RegExp.prototype.exec(string)**
		>
		> Performs a regular expression match of *string* against the regular expression and returns an Array object containing the results of the match, or **null** if the string did not match
		>
		> The string ToString(*string*) is searched for an occurrence of the regular expression pattern as follows:
		>
		> - 1. Let *S* be the value of ToString(*string*).
		> - 2. Let *length* be the length of *S*.
		> - 3. Let *lastIndex* be the value of the **lastIndex** property.
		> - 4. Let *i* be the value of ToInteger(*lastIndex*).
		> - 5. If the **global** property is **false**, let *i* = 0.
		> - 6. If *I* < 0 or *I* > *length* then set **lastIndex** to 0 and return **null**.
		NuXJS result: `/e{1}/.exec(void 0)` returns `null`.
		Expected: the string "undefined" should match `"e"` at index `3`.
		Plan: Ensure `void 0` is stringified to "undefined" prior to matching.

		```io
		> var r = /e{1}/.exec(void 0)
		> print(r[0])
		< e
		-
		> print(r.index)
		< 3
		-
		> print(r.input)
		< undefined
		-
		```
		See `tests/unconforming/regExpExecVoid0.io` for a regression test.
		  - [ ] Fixed
- [x] built-ins/RegExp/prototype/exec/S15.10.6.2_A1_T2 — String is new String("123") and RegExp is /((1)|(12))((3)|(23))/
	> #### **15.10.6.2 RegExp.prototype.exec(string)**
	> 
	> Performs a regular expression match of *string* against the regular expression and returns an Array object containing the results of the match, or **null** if the string did not match
	> 
	> The string ToString(*string*) is searched for an occurrence of the regular expression pattern as follows:
	> 
	> - 1. Let *S* be the value of ToString(*string*).
	> - 2. Let *length* be the length of *S*.
	> - 3. Let *lastIndex* be the value of the **lastIndex** property.
		> - 4. Let *i* be the value of ToInteger(*lastIndex*).
		> - 5. If the **global** property is **false**, let *i* = 0.
		> - 6. If *I* < 0 or *I* > *length* then set **lastIndex** to 0 and return **null**.
NuXJS result: executing the nested capture pattern on `new String("123")` returns incorrect capture groups.
Expected: `r[0]` should be `"123"` with captures `1`, `1`, `undefined`, `3`, `undefined`.
Plan: Fix capture group bookkeeping so unmatched alternates yield `undefined` entries.
```io
> var r=/((1)|(12))((3)|(23))/.exec(new String("123"))
> print(r[0])
> print(r[1])
> print(r[2])
> print(r[3])
> print(r[4])
> print(r[5])
< 123
< 1
< 1
< undefined
< 3
< undefined
-
```
See `tests/unconforming/regExpExecNestedCaptures.io` for a regression test.
  - [ ] Fixed
- [x] built-ins/RegExp/prototype/exec/S15.10.6.2_A1_T20 — String is x and RegExp is /[a-f]d/, where x is undefined variable
	> #### **15.10.6.2 RegExp.prototype.exec(string)**
	> 
	> Performs a regular expression match of *string* against the regular expression and returns an Array object containing the results of the match, or **null** if the string did not match
	> 
	> The string ToString(*string*) is searched for an occurrence of the regular expression pattern as follows:
	> 
	> - 1. Let *S* be the value of ToString(*string*).
	> - 2. Let *length* be the length of *S*.
	> - 3. Let *lastIndex* be the value of the **lastIndex** property.
	> - 4. Let *i* be the value of ToInteger(*lastIndex*).
		> - 5. If the **global** property is **false**, let *i* = 0.
		> - 6. If *I* < 0 or *I* > *length* then set **lastIndex** to 0 and return **null**.
		NuXJS result: `/[a-f]d/.exec(x)` where `x` is an undefined variable returns `null`.
		Expected: the string "undefined" should match `"ed"` at index `7`.
		Plan: Evaluate the argument expression and run `ToString` on its value (`undefined`) before matching.

		```io
		> var r = /[a-f]d/.exec(x)
		> print(r[0])
		< ed
		-
		> print(r.index)
		< 7
		-
		> print(r.input)
		< undefined
		-
		> var x;
		-
		```
		See `tests/unconforming/regExpExecUndefinedVariable.io` for a regression test.
		  - [ ] Fixed
- [x] built-ins/RegExp/prototype/exec/S15.10.6.2_A1_T21 — String is function(){}() and RegExp is /[a-z]n/
	> #### **15.10.6.2 RegExp.prototype.exec(string)**
	> 
	> Performs a regular expression match of *string* against the regular expression and returns an Array object containing the results of the match, or **null** if the string did not match
	> 
	> The string ToString(*string*) is searched for an occurrence of the regular expression pattern as follows:
	> 
	> - 1. Let *S* be the value of ToString(*string*).
	> - 2. Let *length* be the length of *S*.
	> - 3. Let *lastIndex* be the value of the **lastIndex** property.
	> - 4. Let *i* be the value of ToInteger(*lastIndex*).
		> - 5. If the **global** property is **false**, let *i* = 0.
		> - 6. If *I* < 0 or *I* > *length* then set **lastIndex** to 0 and return **null**.
		NuXJS result: `/[a-z]n/.exec(function(){}())` returns `null`.
		Expected: calling the function yields `undefined`, which should match `"un"` at index `0`.
		Plan: Coerce the function call's result to "undefined" before executing the regexp.

		```io
		> var r = /[a-z]n/.exec(function(){}())
		> print(r[0])
		< un
		-
		> print(r.index)
		< 0
		-
		> print(r.input)
		< undefined
		-
		```
		See `tests/unconforming/regExpExecFunctionCallUndefined.io` for a regression test.
		  - [ ] Fixed
- [x] built-ins/RegExp/prototype/exec/S15.10.6.2_A1_T3 — String is new Object("abcdefghi") and RegExp is /a[a-z]{2,4}/
		> #### **15.10.6.2 RegExp.prototype.exec(string)**
	> 
	> Performs a regular expression match of *string* against the regular expression and returns an Array object containing the results of the match, or **null** if the string did not match
	> 
	> The string ToString(*string*) is searched for an occurrence of the regular expression pattern as follows:
	> 
	> - 1. Let *S* be the value of ToString(*string*).
	> - 2. Let *length* be the length of *S*.
	> - 3. Let *lastIndex* be the value of the **lastIndex** property.
		> - 4. Let *i* be the value of ToInteger(*lastIndex*).
		> - 5. If the **global** property is **false**, let *i* = 0.
		> - 6. If *I* < 0 or *I* > *length* then set **lastIndex** to 0 and return **null**.
NuXJS result: executing `/a[a-z]{2,4}/` on `new Object("abcdefghi")` yields `[obje` instead of the substring.
Expected: the string "abcdefghi" should match `"abcde"` at index `0`.
Plan: When `ToString` is applied to a `String` object, use its underlying primitive string rather than `[object Object]`.
```io
> var r=/a[a-z]{2,4}/.exec(new Object("abcdefghi"))
> print(r[0])
< abcde
-
> print(r.index)
< 0
-
```
See `tests/unconforming/regExpExecObjectString.io` for a regression test.
  - [ ] Fixed
- [x] built-ins/RegExp/prototype/exec/S15.10.6.2_A1_T4 — String is {toString:function(){return "abcdefghi";}} and RegExp is /a[a-z]{2,4}?/
		> #### **15.10.6.2 RegExp.prototype.exec(string)**
	> 
	> Performs a regular expression match of *string* against the regular expression and returns an Array object containing the results of the match, or **null** if the string did not match
	> 
	> The string ToString(*string*) is searched for an occurrence of the regular expression pattern as follows:
	> 
	> - 1. Let *S* be the value of ToString(*string*).
	> - 2. Let *length* be the length of *S*.
	> - 3. Let *lastIndex* be the value of the **lastIndex** property.
		> - 4. Let *i* be the value of ToInteger(*lastIndex*).
		> - 5. If the **global** property is **false**, let *i* = 0.
		> - 6. If *I* < 0 or *I* > *length* then set **lastIndex** to 0 and return **null**.
NuXJS result: executing `/a[a-z]{2,4}?/` on an object with `toString` returning "abcdefghi" yields `[ob` instead of the expected substring.
Expected: the string "abcdefghi" should match `"abc"` at index `0`.
Plan: Respect custom `toString` results by stringifying their primitive return value.
```io
> var r=/a[a-z]{2,4}?/.exec({toString:function(){return "abcdefghi";}})
> print(r[0])
< abc
-
> print(r.index)
< 0
-
```
See `tests/unconforming/regExpExecToStringObject.io` for a regression test.
  - [ ] Fixed
- [x] built-ins/RegExp/prototype/exec/S15.10.6.2_A1_T5 — String is {toString:function(){return {};}, valueOf:function(){return "aabaac";}} and RegExp is /(aa|aabaac|ba|b|c)* /
	> #### **15.10.6.2 RegExp.prototype.exec(string)**
	> 
	> Performs a regular expression match of *string* against the regular expression and returns an Array object containing the results of the match, or **null** if the string did not match
	> 
	> The string ToString(*string*) is searched for an occurrence of the regular expression pattern as follows:
	> 
	> - 1. Let *S* be the value of ToString(*string*).
	> - 2. Let *length* be the length of *S*.
	> - 3. Let *lastIndex* be the value of the **lastIndex** property.
	> - 4. Let *i* be the value of ToInteger(*lastIndex*).
		> - 5. If the **global** property is **false**, let *i* = 0.
		> - 6. If *I* < 0 or *I* > *length* then set **lastIndex** to 0 and return **null**.
NuXJS result: `/(aa|aabaac|ba|b|c)*/.exec(obj)` where `obj` defines both `valueOf` and `toString` does not consult `valueOf` first.
Expected: `ToString` must invoke `valueOf` before `toString`, yielding a match for `"aabaac"` at index `0`.
Plan: Implement `ToPrimitive` with hint `String` so `valueOf` is tried when `toString` returns an object.
```io
> var r=/(aa|aabaac|ba|b|c)*/.exec({toString:function(){return {};}, valueOf:function(){return "aabaac";}})
> print(r[0])
> print(r.index)
< aabaac
< 0
-
```
See `tests/unconforming/regExpExecValueOfObject.io` for a regression test.
  - [ ] Fixed

- [x] built-ins/RegExp/S15.10.2.12_A1_T1 — CharacterClassEscape `\s` misses ES3 white-space characters
> #### **15.10.2.12 CharacterClassEscape**
>
> The production *CharacterClassEscape* **:: s** evaluates by returning the set of characters containing the characters that are on the right-hand side of the *WhiteSpace* (7.2) or *LineTerminator* (7.3) productions.
NuXJS result: `/\s/.test("\u1680")` and `/\s/.test("\u2000")` both yield `false`.
Expected: both `\u1680` (OGHAM SPACE MARK) and `\u2000` (EN QUAD) are listed in *WhiteSpace*, so `/\s/` should match them.
```io
> print(/\s/.test("\u1680"))
< false
-
> print(/\s/.test("\u2000"))
< false
-
```
Plan: Expand the engine's white-space table to include all ES3 white-space code points.
  - [ ] Fixed

- [x] built-ins/RegExp/S15.10.2.8_A3_T15 — engine truncates deep capturing groups
> #### **15.10.2.8 Atom**
>
> Parentheses of the form *( Disjunction )* serve both to group the components of the pattern together and to save the result of the match.
NuXJS result: a pattern with 200 nested capturing groups returns an array of length `1`.
Expected: the match result should contain one entry for each of the 200 capturing groups, for a total length of `201`.
```io
> var re = new RegExp(Array(201).join("(") + "hi" + Array(201).join(")"));
> print(re.exec("hi").length);
< 1
-
```
Plan: Lift the limit on tracked capturing groups so all groups are reported.
  - [ ] Fixed

### String
- [x] built-ins/String/prototype/indexOf/S15.5.4.7_A1_T11 — calling `indexOf` with Date object `this` yields wrong index
> #### **15.5.4.7 String.prototype.indexOf (searchString, position)**
>
> If *searchString* appears as a substring of the result of converting this object to a string, at one or more positions that are greater than or equal to *position*, then the index of the smallest such position is returned; otherwise, **-1** is returned. If *position* is **undefined**, 0 is assumed, so as to search all of the string.
>
> The **indexOf** method takes two arguments, *searchString* and *position*, and performs the following steps:
>
> - 1. Call ToString, giving it the **this** value as its argument.
> - 2. Call ToString(*searchString*).
> - 3. Call ToInteger(*position*). (If *position* is **undefined**, this step produces the value **0**).
> - 4. Compute the number of characters in Result(1).
> - 5. Compute min(max(Result(3), 0), Result(4)).
> - 6. Compute the number of characters in the string that is Result(2).
NuXJS result: `String.prototype.indexOf.call(new Date(0), "GMT")` returns `-1`.
Expected: converting the Date to a string includes "GMT", so the index should be `25`.
Plan: Convert the **this** value with `ToString` before searching so Date strings expose "GMT".
```io
> print(String.prototype.indexOf.call(new Date(0), "GMT"))
< 25
-
```
See `tests/unconforming/stringIndexOfDateThis.io` for a regression test.
  - [ ] Fixed
- [x] built-ins/String/prototype/replace/S15.5.4.11_A12 — `replace` should treat undefined `this` correctly
	   > #### **15.5.4.11 String.prototype.replace (searchValue, replaceValue)**
	   >
	   > Let *string* denote the result of converting the **this** value to a string.
	   >
		   NuXJS result: `String.prototype.replace.call(undefined, "d", "D")` produces `[object Object]`.
		   Expected: the **this** value `undefined` should convert to the string "undefined", yielding `"unDefineD"` after replacement.
		   Plan: Coerce the **this** value via `ToString` so `undefined` becomes "undefined" before replacement.

		   ```io
		   > print(String.prototype.replace.call(undefined, "d", "D"))
		   < unDefineD
	   -
	   ```
	   See `tests/unconforming/stringReplaceUndefinedThis.io` for a regression test.
		 - [ ] Fixed
- [x] built-ins/String/prototype/replace/S15.5.4.11_A1_T11 — replacing with objects whose `toString` throws
		> #### **15.5.4.11 String.prototype.replace ( searchValue, replaceValue )**
		>
		> Otherwise, let *newstring* denote the result of converting *replaceValue* to a string.
		>
				NuXJS result: replacing with an object whose `toString` throws does not propagate the exception.
				Expected: the replacement value must be converted to a string; an error from `toString` should be thrown.
			   Plan: Apply `ToString` to the replacement and propagate any exception from its `toString`.
				```io
				> try { "a".replace("a", { toString: function(){ throw new Error("X"); } }); } catch (e) { print(e.message); }
				< X
		-
		```
		See `tests/unconforming/stringReplaceThrowingToString.io` for a regression test.
		  - [ ] Fixed
- [x] built-ins/String/prototype/replace/S15.5.4.11_A1_T12 — replacing with object whose `valueOf` throws
		> #### **15.5.4.11 String.prototype.replace ( searchValue, replaceValue )**
		>
		> Otherwise, let *newstring* denote the result of converting *replaceValue* to a string.
		>
				NuXJS result: if the replacement object's `valueOf` throws, the exception is swallowed.
				Expected: `ToString` first invokes `valueOf`; an error from `valueOf` must propagate.
			   Plan: Invoke `valueOf` during `ToString` and propagate its errors before calling `toString`.
				```io
				> try { "a".replace("a", { valueOf: function(){ throw new Error("Y"); } }); } catch (e) { print(e.message); }
				< Y
		-
		```
		See `tests/unconforming/stringReplaceThrowingValueOf.io` for a regression test.
		  - [ ] Fixed
- [x] built-ins/String/prototype/replace/S15.5.4.11_A3_T1 — `$11` sequences ignored in computed `replaceValue`
	   > #### **15.5.4.11 String.prototype.replace ( searchValue, replaceValue )**
	   >
	   > If *replaceValue* is not a function, ToString(*replaceValue*) is processed for substitution patterns.	The sequence `"$"` followed by one or two decimal digits *nn* (0 < *nn* ≤ *NCaptures*) is replaced by the *nn*-th captured substring.
	   >
		   NuXJS result: `var r = "$11" + 15; "xab".replace(/(x)/, r)` leaves the `$11` literal and returns `"$1115ab"`.
		   Expected: `$11` should expand to capture `1` followed by `"1"`, producing `"x115ab"`.
		   Plan: After computing `replaceValue`, expand `$nn` sequences to the corresponding capture groups before insertion.

		   ```io
		   > var r = "$11" + 15
		   > print("xab".replace(/(x)/, r))
	   < x115ab
	   -
	   ```
	   See `tests/unconforming/stringReplace11Concat.io` for a regression test.
		 - [ ] Fixed
- [x] built-ins/String/prototype/replace/S15.5.4.11_A3_T2 — `replaceValue` is "$11" + "15"
	   > #### **15.5.4.11 String.prototype.replace ( searchValue, replaceValue )**
	   >
	   > If *replaceValue* is not a function, ToString(*replaceValue*) is processed for substitution patterns.	The sequence "\$" followed by one or two decimal digits *nn* (0 < *nn* ≤ *NCaptures*) is replaced by the *nn*-th captured substring.
	   >
	   NuXJS result: `var r = "$11" + "15"; "xab".replace(/(x)/, r)` yields `$1115ab`.
		   Expected: `$11` should expand to capture `1` followed by "1", producing "x115ab".
		   Plan: Scan two-digit `$nn` tokens and, when `nn` exceeds the capture count, treat `$n` as the capture and append the extra digit literally.
		   ```io
	   > var r = "$11" + "15"
	   > print("xab".replace(/(x)/, r))
	   < x115ab
	   -
	   ```
	   See `tests/unconforming/stringReplace11Plus15.io` for a regression test.
		 - [ ] Fixed
- [x] built-ins/String/prototype/replace/S15.5.4.11_A3_T3 — `replaceValue` is "$11" + "A15"
	   > #### **15.5.4.11 String.prototype.replace ( searchValue, replaceValue )**
	   >
	   > If *replaceValue* is not a function, ToString(*replaceValue*) is processed for substitution patterns.	The sequence "\$" followed by one or two decimal digits *nn* (0 < *nn* ≤ *NCaptures*) is replaced by the *nn*-th captured substring.
	   >
		   NuXJS result: `var r = "$11" + "A15"; "xab".replace(/(x)/, r)` returns `$11A15ab`.
		   Expected: "x1A15ab" after expanding `$11` to capture `1` plus "1".
		   Plan: When processing replacement text, prefer a two-digit capture only if it exists; otherwise use the first digit's capture and emit the remaining text unchanged.
		   ```io
	   > var r = "$11" + "A15"
	   > print("xab".replace(/(x)/, r))
	   < x1A15ab
	   -
	   ```
	   See `tests/unconforming/stringReplace11PlusA15.io` for a regression test.
		 - [ ] Fixed
- [x] built-ins/String/prototype/replace/S15.5.4.11_A5_T1 — regex `/^(a+)\1*,\1+$/` with backreference
	   > #### **15.10.2.9 AtomEscape**
	   >
	   > An escape sequence of the form "\\" followed by a nonzero decimal number *n* matches the result of the *n*th set of capturing parentheses.
	   >
		   NuXJS result: "aa,a".replace(/^(a+)\1*,\1+$/, "$1") leaves the string unchanged.
		   Expected: backreference handling should collapse the match to "a".
		   Plan: Implement backreference evaluation so `\1` and similar escapes compare against the previously captured text, even when quantified.
		   ```io
	   > print("aa,a".replace(/^(a+)\1*,\1+$/, "$1"))
	   < a
	   -
	   ```
	   See `tests/unconforming/stringReplaceBackreference.io` for a regression test.
		 - [ ] Fixed
- [x] built-ins/String/prototype/toLocaleLowerCase/supplementary_plane — supplementary-plane mapping not defined in ES3
		> ## **15.5.4.17 String.prototype.toLocaleLowerCase ( )**
		>
		> This function works exactly the same as **toLowerCase** except that its result is intended to yield the correct result for the host environment's current locale, rather than a locale-independent result. There will only be a difference in the few cases (such as Turkish) where the rules for that language conflict with the regular Unicode case mappings.
		>
		> ## *NOTE 1*
		>
		> *The* **toLocaleLowerCase** *function is intentionally generic; it does not require that its this value be a String object. Therefore, it can be transferred to other kinds of objects for use as a method.*
		>
		> #### *NOTE 2*
		>
		> *The first parameter to this function is likely to be used in a future version of this standard; it is recommended that implementations do not use this parameter position for anything else.*
NuXJS result: `print("\uD835\uDD0A".toLocaleLowerCase())` collapses the surrogate pair to `"G"`.
Expected: the original character `"𝔊"` should be preserved.
Resolution: ES3 strings are 16‑bit and provide no rules for characters outside the Basic Multilingual Plane.
Flagged `not_es3` in `tools/testdash.json`.
```io
> print("\uD835\uDD0A".toLocaleLowerCase())
< 𝔊
-
```
See `tests/unconforming/toLocaleLowerCaseSupplementaryPlane.io` for a regression test.
  - [ ] Fixed
- [x] built-ins/String/prototype/toLocaleUpperCase/supplementary_plane — supplementary-plane mapping not defined in ES3
	> #### **15.5.4.19 String.prototype.toLocaleUpperCase ( )**
	> 
	> This function works exactly the same as **toUpperCase** except that its result is intended to yield the correct result for the host environment's current locale, rather than a locale-independent result. There will only be a difference in the few cases (such as Turkish) where the rules for that language conflict with the regular Unicode case mappings.
	> 
	> #### *NOTE 1*
	> 
	> *The* **toLocaleUpperCase** *function is intentionally generic; it does not require that its this value be a String object. Therefore, it can be transferred to other kinds of objects for use as a method.*
	> 
> *NOTE 2*
>
> *The first parameter to this function is likely to be used in a future version of this standard; it is recommended that implementations do not use this parameter position for anything else.*
NuXJS result: `print("\uD835\uDD24".toLocaleUpperCase())` collapses the surrogate pair to `"g"`.
Expected: `"𝔊"`.
Resolution: ES3 strings are 16‑bit and provide no rules for characters outside the Basic Multilingual Plane.
Flagged `not_es3` in `tools/testdash.json`.
```io
> print("\uD835\uDD24".toLocaleUpperCase())
< 𝔊
-
```
See `tests/unconforming/toLocaleUpperCaseSupplementaryPlane.io` for a regression test.
  - [ ] Fixed
- [x] built-ins/String/prototype/toLowerCase/supplementary_plane — supplementary-plane mapping not defined in ES3
> ## **15.5.4.16 String.prototype.toLowerCase ( )**
>
> If this object is not already a string, it is converted to a string. The characters in that string are converted one by one to lower case. The result is a string value, not a String object.
>
> The characters are converted one by one. The result of each conversion is the original character, unless that character has a Unicode lowercase equivalent, in which case the lowercase equivalent is used instead.
>
> #### *NOTE 1*
>
> *The result should be derived according to the case mappings in the Unicode character database (this explicitly includes not only the UnicodeData.txt file, but also the SpecialCasings.txt file that accompanies it in Unicode 2.1.8 and later).*
>
> ## *NOTE 2*
NuXJS result: `print("\uD835\uDD0A".toLowerCase())` collapses the surrogate pair to `"G"`.
Expected: `"𝔊"`.
Resolution: ES3 strings are 16‑bit and provide no rules for characters outside the Basic Multilingual Plane.
Flagged `not_es3` in `tools/testdash.json`.
```io
> print("\uD835\uDD0A".toLowerCase())
< 𝔊
-
```
See `tests/unconforming/toLowerCaseSupplementaryPlane.io` for a regression test.
  - [ ] Fixed
- [x] built-ins/String/prototype/toUpperCase/supplementary_plane — supplementary-plane mapping not defined in ES3
		> #### **15.5.4.18 String.prototype.toUpperCase ( )**
		>
		> This function behaves in exactly the same way as **String.prototype.toLowerCase**, except that characters are mapped to their *uppercase* equivalents as specified in the Unicode Character Database.
		>
		> #### *NOTE 1*
		>
		> *Because both* **toUpperCase** *and* **toLowerCase** *have context-sensitive behaviour, the functions are not symmetrical. In other words,* **s.toUpperCase().toLowerCase()** *is not necessarily equal to* **s.toLowerCase()***.*
		>
		> #### *NOTE 2*
		>
		> *The* **toUpperCase** *function is intentionally generic; it does not require that its this value be a String object. Therefore, it can be transferred to other kinds of objects for use as a method.*
NuXJS result: `print("\uD835\uDD0A".toUpperCase())` collapses the surrogate pair to `"G"`.
Expected: `"𝔊"`.
Resolution: ES3 strings are 16‑bit and provide no rules for characters outside the Basic Multilingual Plane.
Flagged `not_es3` in `tools/testdash.json`.
```io
> print("\uD835\uDD0A".toUpperCase())
< 𝔊
-
```
See `tests/unconforming/toUpperCaseSupplementaryPlane.io` for a regression test.
  - [ ] Fixed
### parseInt
- [x] built-ins/parseInt/S15.1.2.2_A2_T10 — "StrWhiteSpaceChar :: USP"
	> #### **15.1.2.2 parseInt (string , radix)**
	> 
	> The **parseInt** function produces an integer value dictated by interpretation of the contents of the *string* argument according to the specified *radix*. Leading whitespace in the string is ignored. If *radix* is **undefined** or 0, it is assumed to be 10 except when the number begins with the character pairs **0x** or **0X**, in which case a radix of 16 is assumed. Any radix-16 number may also optionally begin with the character pairs **0x** or **0X**.
	> 
		>
		> *StrWhiteSpaceChar* **:::** <TAB> <SP> <NBSP> <FF> <VT> <CR> <LF> <LS> <PS> <USP>

NuXJS result: `parseInt("\u1680123")` returns `NaN`.
By design, NuXJS excludes the OGHAM SPACE MARK from its whitespace set.

```io
> print(parseInt("\u1680123"))
< NaN
-
```
See `tests/unconforming/parseIntUSP.io` for a regression test.
  - [ ] Fixed

- [x] built-ins/parseInt/S15.1.2.2_A5.2_T2 — ": 0X"
		> #### **15.1.2.2 parseInt (string , radix)**
		>
		> The **parseInt** function produces an integer value dictated by interpretation of the contents of the *string* argument according to the specified *radix*. Leading whitespace in the string is ignored. If *radix* is **undefined** or 0, it is assumed to be 10 except when the number begins with the character pairs **0x** or **0X**, in which case a radix of 16 is assumed. Any radix-16 number may also optionally begin with the character pairs **0x** or **0X**.
		>
		> - 13. If the length of *S* is at least 2 and the first two characters of *S* are either "0x" or "0X", then remove the first two characters from *S* and let *R* = 16.
Previously, `parseInt("0X1")` returned `0`, ignoring the hexadecimal prefix.
Now strings starting with `0x` or `0X` parse as base 16 when the radix is undefined or 0, producing `1` for `"0X1"`.
Resolution: Accept an uppercase `0X` prefix when the radix is omitted or 0, mirroring the check for lowercase `0x`.
```io
> print(parseInt("0X1"))
< 1
-
> print(parseInt("0XA"))
< 10
-
```
See `tests/unconforming/parseInt0XPrefix.io` for a regression test.
  - [x] Fixed
- [x] built-ins/parseInt/S15.1.2.2_A7.2_T3 — Checking algorithm for R = 16
		> #### **15.1.2.2 parseInt (string , radix)**
		>
		> The **parseInt** function produces an integer value dictated by interpretation of the contents of the *string* argument according to the specified *radix*. Leading whitespace in the string is ignored. If *radix* is **undefined** or 0, it is assumed to be 10 except when the number begins with the character pairs **0x** or **0X**, in which case a radix of 16 is assumed. Any radix-16 number may also optionally begin with the character pairs **0x** or **0X**.
		>
		> - 13. If the length of *S* is at least 2 and the first two characters of *S* are either "0x" or "0X", then remove the first two characters from *S* and let *R* = 16.
Previously, `parseInt("0X10", 16)` returned `0` instead of `16`.
With radix 16, uppercase `0X` prefixes are now valid, so `parseInt("0X10", 16)` yields `16`.
Resolution: When radix is 16, strip an optional leading `0X` or `0x` before parsing digits.
```io
> print(parseInt("0X10", 16))
< 16
-
> print(parseInt("0XFF", 16))
< 255
-
```
See `tests/unconforming/parseIntRadix16Uppercase.io` for a regression test.
  - [x] Fixed

