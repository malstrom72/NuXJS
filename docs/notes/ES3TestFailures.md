# ES3 Test262 Failures Analysis
80 Test262 tests from the ES3 portion of Test262 still fail in NuXJS. All of these tests target ES3 semantics that NuXJS does not yet implement correctly.
| Feature | Spec Clause | Failures |
| --- | --- | ---:|
| Expressions | §11 | 3 |
| Array | §15.4 | 9 |
| Date | §15.9 | 7 |
| Error | §15.11 | 5 |
| Function | §15.3 | 1 |
| Math | §15.8 | 0 |
| Number | §15.7 | 3 |
| Object | §15.2 | 16 |
| RegExp | §15.10 | 18 |
| String | §15.5 | 17 |
| parseFloat |	| 1 |
| parseInt |  | 3 |

Tests that rely on the optional URI helpers (`decodeURI`, `encodeURI`, and their component variants) are excluded: cases targeting these helpers are marked as by_design, while unrelated tests that require them are tagged bad_test.
Tests expecting the global `NaN`, `Infinity`, or `undefined` properties to be immutable are tagged `not_es3`; ES3 only requires {DontEnum, DontDelete} (§15.1.1.1–15.1.1.3).

Each list below states the ES3 requirement that the corresponding test checks. NuXJS currently violates these behaviors.

For spec references, consult the Markdown edition of the ES3 spec at `docs/specs/ECMA-262 3.md`.

When an item is resolved, check it off and add a brief note citing the ES3 spec section and the regression `.io` test that verifies the fix.

### Expressions
- [ ] language/expressions/evalOrderOfBaseAndName — property name evaluated before null-base check
> #### **11.2.1 Property Accessors**
>
> The production *MemberExpression* **:** *MemberExpression* **[** *Expression* **]** is evaluated as follows:
> - 1. Evaluate *MemberExpression*.
> - 3. Evaluate *Expression*.
>
NuXJS result: `invalidBase[objectPropertyName]` calls `objectPropertyName.toString()` before throwing `TypeError`.
Expected: property names should not be evaluated when the base is `null`; the expression should immediately throw `TypeError`.
```io
> var invalidBase = null;
> var objectPropertyName = { toString: function() { print("to string called!"); return 'x' } };
> try { invalidBase[objectPropertyName] } catch (e) { print(e.name) }
< TypeError
-
```
See `tests/unconforming/evalOrderOfBaseAndName.io` for a regression test.
- [ ] language/expressions/rightSideBeforeAssignmentRef — right-hand side evaluated before resolving assignment target
> #### **11.13.1 Simple Assignment ( = )**
>
> The production *AssignmentExpression* **:** *LeftHandSideExpression* **=** *AssignmentExpression* is evaluated as follows:
> - 1. Evaluate *LeftHandSideExpression*.
> - 2. Evaluate *AssignmentExpression*.
>
NuXJS result: in `x = (eval("var x;"), 1)` the `eval` creates a local `x` before the assignment resolves, yielding `typeof innerX === "number"` and leaving the outer `x` unchanged.
Expected: the assignment should resolve the outer `x` first, producing `typeof innerX === "undefined"` and updating the outer `x` to `1`.
```io
> var x = 0;
>   var innerX = (function() {
>     // If we were to conform strictly to ES spec, the left-hand side of th assigment is a reference to the outer x.
>     x = (eval("var x;"), 1);
>     return x;
>   })();
> print(typeof innerX);
> print(x);
< undefined
< 1
-
> function testFunction() {
>   var x = 0;
>   var scope = {x: 1};
>   with (scope) {
>     x = (delete scope.x, 2);
>   }
>   print(scope.x);
>   print(x);
> }
> testFunction();
< 2
< 0
-
```
See `tests/unconforming/rightSideBeforeAssignmentRef.io` for a regression test.
- [ ] language/expressions/funcCallEvalOrder — argument assignment changes callee
> #### **11.2.3 Function Calls**
>
> The production *CallExpression* **:** *MemberExpression* *Arguments* is evaluated as follows:
> - 1. Evaluate *MemberExpression*.
> - 2. Evaluate *Arguments*, producing an internal list of argument values.
>
NuXJS result: `o.f(o.f=b)` invokes `b` because the argument assignment runs before the property reference.
Expected: the property reference should be resolved first so the original `a` is called and `b` is merely passed as an argument.
```io
> function a() { print("a") }
> function b() { print("b") }
> o = { f: a };
> o.f(o.f=b)
< a
-
```
See `tests/unconforming/funcCallEvalOrder.io` for a regression test.

### Array
- [ ] built-ins/Array/arrayIndexTooLarge — property "4294967296" wraps to index 0
> #### **15.4 Array Objects**
>
> Array objects give special treatment to a certain class of property names. A property name *P* (in the form of a string value) is an *array index* if and only if ToString(ToUint32(*P*)) is equal to *P* and ToUint32(*P*) is not equal to 2<sup>32</sup>−1.
>
NuXJS result: assigning `a["4294967296"]=1` sets `a.length` to `1` and stores the value at index `0`.
Expected: property names ≥2<sup>32</sup> should create ordinary properties, leaving `length` at `0` and `a[0]` undefined.
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
- [ ] built-ins/Array/S15.4.5.1_A2.1_T1 — P in [4294967295, -1, true]
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
See `tests/unconforming/booleanIndexCoercion.io` for a regression test.
- [ ] built-ins/Array/S15.4_A1.1_T1 — Checking for boolean primitive
        > #### **15.4 Array Objects**
        >
        > Array objects give special treatment to a certain class of property names. A property name *P* (in the form of a string value) is an *array index* if and only if ToString(ToUint32(*P*)) is equal to *P* and ToUint32(*P*) is not equal to 2<sup>32</sup>−1. Every Array object has a **length** property whose value is always a nonnegative integer less than 232. The value of the **length** property is numerically greater than the name of every property whose name is an array index; whenever a property of an Array object is created or changed, other properties are adjusted as necessary to maintain this invariant. Specifically, whenever a property is added whose name is an array index, the **length** property is changed, if necessary, to be one more than the numeric value of that array index; and whenever the **length** property is changed, every property whose name is an array index whose value is not smaller than the new length is automatically deleted. This constraint applies only to properties of the Array object itself and is unaffected by **length** or array index properties that may be inherited from its prototype.
        
NuXJS result: assigning `true` as an index sets `x[1]` and increases length to `2`, leaving `x["true"]` undefined.
Expected: non-array keys must not affect length and should create a plain property.
See `tests/unconforming/booleanIndexCoercion.io`.
- [ ] built-ins/Array/cantAssignObjectToArrayLength — assigning object to length throws
	> #### **15.4.5.1 [[Put]] (P, V)**
	>
	> When the [[Put]] method of *A* is called with property "length" and value *V*, the following steps are taken:
	> - 12. Compute ToUint32(*V*).
	> - 13. If Result(12) is not equal to ToNumber(*V*), throw a **RangeError** exception.
	>
NuXJS result: assigning an object with `valueOf` returning `23` to `a.length` throws `RangeError` and leaves length `0`.
Expected: the object should convert to `23` and set `a.length` to `23`.
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
- [ ] built-ins/Array/prototype/pop/S15.4.4.6_A2_T2 — If ToUint32(length) equal zero, call the [[Put]] method	 of this object with arguments "length" and 0 and return undefined
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
- [ ] built-ins/Array/prototype/pop/S15.4.4.6_A4_T2 — [[Prototype]] of Array instance is Array.prototype, [[Prototype] of Array.prototype is Object.prototype
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
- [ ] built-ins/Array/prototype/push/S15.4.4.7_A2_T2 — The arguments are appended to the end of the array, in	 the order in which they appear. The new length of the array is returned  as the result of the call
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
```io
> obj={}
> obj.length=Number.POSITIVE_INFINITY
> obj.push=Array.prototype.push
NuXJS result: calling `push` on an object with `length` set to `Infinity` returns `1` and changes `length` to `1`.
Expected: `push` should throw a `TypeError` and keep `length` at `Infinity`.
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
- [ ] built-ins/Array/prototype/shift/S15.4.4.9_A3_T3 — length is arbitrarily
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
- [ ] built-ins/Array/prototype/shift/S15.4.4.9_A4_T2 — [[Prototype]] of Array instance is Array.prototype, [[Prototype] of Array.prototype is Object.prototype
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
- [ ] built-ins/Array/prototype/toLocaleString/S15.4.4.3_A1_T1 — it is the function that should be invoked
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
- [ ] built-ins/Array/prototype/toLocaleString/S15.4.4.3_A3_T1 — "[[Prototype]] of Array instance is Array.prototype"
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

### Date
- [ ] built-ins/Date/S15.9.3.1_A6_T1 — 2 arguments, (year, month)
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

        ```io
        > print(isNaN(new Date(1970, undefined)))
        < true
        -
        ```
        See `tests/unconforming/dateYearMonthUndefined.io` for a regression test.
- [ ] built-ins/Date/S15.9.3.1_A6_T2 — 3 arguments, (year, month, date)
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

        ```io
        > print(isNaN(new Date(1970, 0, undefined)))
        < true
        -
        ```
        See `tests/unconforming/dateYearMonthDateUndefined.io` for a regression test.
- [ ] built-ins/Date/S15.9.3.1_A6_T3 — 4 arguments, (year, month, date, hours)
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
- [ ] built-ins/Date/S15.9.3.1_A6_T4 — 5 arguments, (year, month, date, hours, minutes)
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
- [ ] built-ins/Date/S15.9.3.1_A6_T5 — 6 arguments, (year, month, date, hours, minutes, seconds)
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
- [ ] built-ins/Date/TimeClip_negative_zero — TimeClip converts negative zero to positive zero
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

       ```io
       > print(1/new Date(-0).getTime())
       < Infinity
       -
       ```

       See `tests/unconforming/dateTimeClipNegativeZero.io` for a regression test.
- [ ] built-ins/Date/prototype/setFullYear/15.9.5.40_1 — Date.prototype.setFullYear - Date.prototype is itself not an instance of Date

### Error
- [ ] built-ins/Error/S15.11.1.1_A1_T1 — Checking message property of different error objects
	> #### **15.11.1.1 Error (message)**
	> 
	> The [[Prototype]] property of the newly constructed object is set to the original Error prototype object, the one that is the initial value of **Error.prototype** (15.11.3.1).
	> 
	> The [[Class]] property of the newly constructed object is set to **"Error"**.
	> 
	> If the argument *message* is not **undefined**, the **message** property of the newly constructed object is set to ToString(*message*).
- [ ] built-ins/Error/S15.11.2.1_A1_T1 — Checking message property of different error objects
	> ## **15.11.2.1 new Error (message)**
	> 
	> The [[Prototype]] property of the newly constructed object is set to the original Error prototype object, the one that is the initial value of **Error.prototype** (15.11.3.1).
	> 
	> The [[Class]] property of the newly constructed Error object is set to **"Error"**.
	> 
	> If the argument *message* is not **undefined**, the **message** property of the newly constructed object is set to ToString(*message*).
- [ ] built-ins/Error/prototype/S15.11.4_A2 — Getting the value of the internal [[Class]] property using Error.prototype.toString() function
	> ## **15.11.4 Properties of the Error Prototype Object**
	> 
	> The Error prototype object is itself an Error object (its [[Class]] is **"Error"**).
	> 
	> The value of the internal [[Prototype]] property of the Error prototype object is the Object prototype object (15.2.3.1).
- [ ] built-ins/Error/prototype/name/15.11.4.2-1 — Error.prototype.name is not enumerable.
       > #### **15.11.4.2 Error.prototype.name**
       >
       > The initial value of **Error.prototype.name** is "**Error**".
       >
       > In every case, the **length** property of a built-in Function object described in this section has the attributes { ReadOnly, DontDelete, DontEnum }. Every other property described in this section has the attribute { DontEnum } (and no others) unless otherwise specified.

       NuXJS result: iterating an `Error` instance reveals the `name` property.
       Expected: `name` should not be enumerated.

       ```io
       > var e = new Error("msg")
       > var seen = false
       > for (var p in e) if (p === "name") seen = true
       > print(seen)
       < false
       -
       ```
       See `tests/unconforming/errorPrototypeNameEnumerable.io` for a regression test.
- [ ] built-ins/Error/prototype/toString/15.11.4.4-8-1 — Error.prototype.toString return the value of 'msg' when 'name' is empty string and 'msg' isn't undefined
       > #### **15.11.4.4 Error.prototype.toString ( )**
       >
       > Returns an implementation defined string.

       NuXJS result: `{name:"", message:"foo", toString:Error.prototype.toString}.toString()` yields `": foo"`.
       Expected: `"foo"` when `name` is empty and `message` is present (ES5 algorithm).
       ES3 leaves the exact format implementation-defined, so this discrepancy is not mandated by the specification.

       ```io
       > var e = {name:"", message:"foo", toString:Error.prototype.toString}
       > print(e.toString())
       < foo
       -
       ```

### Function
- [ ] built-ins/Function/prototype/S15.3.4_A5 — Checking if creating "new Function.prototype object" fails
	> ## **15.3.4 Properties of the Function Prototype Object**
	> 
	> The Function prototype object is itself a Function object (its [[Class]] is **"Function"**) that, when invoked, accepts any arguments and returns **undefined**.
	> 
	> The value of the internal [[Prototype]] property of the Function prototype object is the Object prototype object (15.3.2.1).
	> 
	> It is a function with an "empty body"; if it is invoked, it merely returns **undefined**.
	> 
	> The Function prototype object does not have a **valueOf** property of its own; however, it inherits the **valueOf** property from the Object prototype Object.

- [x] built-ins/Math/pow/applying-the-exp-operator_A7 — |base| = 1 and exponent = +∞ ⇒ NaN (§15.8.2.13, regression/mathPowSpecialCases.io)
- [x] built-ins/Math/pow/applying-the-exp-operator_A8 — |base| = 1 and exponent = −∞ ⇒ NaN (§15.8.2.13, regression/mathPowSpecialCases.io)

- [ ] built-ins/Number/S9.3.1_A2 — Strings with various WhiteSpaces convert to Number by explicit transformation
	> #### **9.3.1 ToNumber Applied to the String Type**
	> 
	> ToNumber applied to strings applies the following grammar to the input string. If the grammar cannot interpret the string as an expansion of *StringNumericLiteral*, then the result of ToNumber is **NaN**.
	> 
	> *StringNumericLiteral* **:::** *StrWhiteSpaceopt StrWhiteSpaceopt StrNumericLiteral StrWhiteSpaceopt*
	> 
	> *StrWhiteSpace* **:::** *StrWhiteSpaceChar StrWhiteSpaceopt*
	> 
	> *StrWhiteSpaceChar* **:::**
	> 
        > *<TAB> <SP> <NBSP> <FF> <VT> <CR> <LF> <LS> <PS> <USP> StrNumericLiteral* **:::** *StrDecimalLiteral*

       NuXJS result: `Number("\u16801")` returns `NaN` because `\u1680` isn’t treated as whitespace.
       Expected: the OGHAM SPACE MARK is a valid `StrWhiteSpaceChar`, so the conversion should yield `1`.

       ```io
       > print(Number("\u16801"))
       < 1
       -
       ```

       See `tests/unconforming/numberExplicitUSP.io` for a regression test.
- [ ] built-ins/Number/S9.3.1_A3_T1 — static string
	> #### **9.3.1 ToNumber Applied to the String Type**
	> 
	> ToNumber applied to strings applies the following grammar to the input string. If the grammar cannot interpret the string as an expansion of *StringNumericLiteral*, then the result of ToNumber is **NaN**.
	> 
	> *StringNumericLiteral* **:::** *StrWhiteSpaceopt StrWhiteSpaceopt StrNumericLiteral StrWhiteSpaceopt*
	> 
	> *StrWhiteSpace* **:::** *StrWhiteSpaceChar StrWhiteSpaceopt*
	> 
	> *StrWhiteSpaceChar* **:::**
	> 
        > *<TAB> <SP> <NBSP> <FF> <VT> <CR> <LF> <LS> <PS> <USP> StrNumericLiteral* **:::** *StrDecimalLiteral*

       NuXJS result: unary `+"\u16801"` produces `NaN`.
       Expected: `1` once `\u1680` is recognized as whitespace.

       ```io
       > print(+"\u16801")
       < 1
       -
       ```

       See `tests/unconforming/numberStaticUSP.io` for a regression test.
- [ ] built-ins/Number/S9.3.1_A3_T2 — dynamic string
> #### **9.3.1 ToNumber Applied to the String Type**
>
> ToNumber applied to strings applies the following grammar to the input string. If the grammar cannot interpret the string as an expansion of *StringNumericLiteral*, then the result of ToNumber is **NaN**.
>
> *StringNumericLiteral* **:::** *StrWhiteSpaceopt StrWhiteSpaceopt StrNumericLiteral StrWhiteSpaceopt*
>
> *StrWhiteSpace* **:::** *StrWhiteSpaceChar StrWhiteSpaceopt*
>
> *StrWhiteSpaceChar* **:::**
>
        > *<TAB> <SP> <NBSP> <FF> <VT> <CR> <LF> <LS> <PS> <USP> StrNumericLiteral* **:::** *StrDecimalLiteral*

       NuXJS result: `var s = "\u1680"; Number(s+"1")` yields `NaN`.
       Expected: concatenating `\u1680` with digits should parse as `1`.

       ```io
       > var s="\u1680";
       > print(Number(s+"1"))
       < 1
       -
       ```

       See `tests/unconforming/numberDynamicUSP.io` for a regression test.
- [ ] built-ins/Number/hexLiteralOverflow — `0x100000000` wraps to `0`
> #### **7.8.3 Numeric Literals**
>
> *NumericLiteral* **::** *DecimalLiteral HexIntegerLiteral*
> - The MV of *HexIntegerLiteral* **::** *HexIntegerLiteral HexDigit* is (the MV of *HexIntegerLiteral* times 16) plus the MV of *HexDigit*.
>
NuXJS result: `print(0x100000000)` and `print(Number("0x100000000"))` both yield `0`.
Expected: `4294967296`.
```io
> print(0x100000000)
< 4294967296
-
> print(Number("0x100000000"))
< 4294967296
-
```
See `tests/unconforming/hexLiteralOverflow.io` for a regression test.
- [ ] built-ins/Number/hugeDecimalExponent — extremely large exponents don't overflow
> #### **7.8.3 Numeric Literals**
>
> - The MV of *DecimalLiteral* **::** *DecimalIntegerLiteral* *ExponentPart* is the MV of *DecimalIntegerLiteral* times 10<sup>*e*</sup>, where *e* is the MV of *ExponentPart*.
> - The MV of *StrUnsignedDecimalLiteral* **::: Infinity** is 10<sup>10000</sup> (a value so large that it will round to **+**∞).
>
NuXJS result: `print(1e4294967296)` and `print(Number("1e4294967296"))` both return `1`.
Expected: `Infinity`.
```io
> print(1e4294967296)
< Infinity
-
> print(Number("1e4294967296"))
< Infinity
-
```
See `tests/unconforming/hugeDecimalExponent.io` for a regression test.

### Object
- [ ] built-ins/Object/prototype/hasOwnProperty/S15.2.4.5_A12 — Let O be the result of calling ToObject passing the this value as the argument.
	> #### **15.2.4.5 Object.prototype.hasOwnProperty (V)**
	> 
	> When the **hasOwnProperty** method is called with argument *V*, the following steps are taken:
	> 
	> - 1. Let *O* be this object.
	> - 2. Call ToString(*V*).
	> - 3. If *O* doesn't have a property with the name given by Result(2), return **false**.
	> - 4. Return **true**.
	> 
	> *NOTE*
	> 
        > *Unlike [[HasProperty]] (8.6.2.4), this method does not consider objects in the prototype chain.*
NuXJS result: `Object.prototype.hasOwnProperty.call(null, "x")` returns `false` instead of throwing.
Expected: `TypeError` because `null` cannot be converted to an object.
```io
> try { Object.prototype.hasOwnProperty.call(null, "x"); } catch (e) { print(e.name); }
< TypeError
-
```
See `tests/unconforming/hasOwnPropertyNullThis.io` for a regression test.
- [ ] built-ins/Object/prototype/hasOwnProperty/S15.2.4.5_A13 — Let O be the result of calling ToObject passing the this value as the argument.
	> #### **15.2.4.5 Object.prototype.hasOwnProperty (V)**
	> 
	> When the **hasOwnProperty** method is called with argument *V*, the following steps are taken:
	> 
	> - 1. Let *O* be this object.
	> - 2. Call ToString(*V*).
	> - 3. If *O* doesn't have a property with the name given by Result(2), return **false**.
	> - 4. Return **true**.
	> 
	> *NOTE*
	> 
        > *Unlike [[HasProperty]] (8.6.2.4), this method does not consider objects in the prototype chain.*
NuXJS result: `Object.prototype.hasOwnProperty.call(undefined, "x")` returns `false`.
Expected: `TypeError` because `undefined` cannot be converted to an object.
```io
> try { Object.prototype.hasOwnProperty.call(undefined, "x"); } catch (e) { print(e.name); }
< TypeError
-
```
See `tests/unconforming/hasOwnPropertyUndefinedThis.io` for a regression test.
- [ ] built-ins/Object/prototype/isPrototypeOf/S15.2.4.6_A12 — Let O be the result of calling ToObject passing the this value as the argument.
	> #### **15.2.4.6 Object.prototype.isPrototypeOf (V)**
	> 
	> When the **isPrototypeOf** method is called with argument *V*, the following steps are taken:
	> 
	> - 1. Let *O* be this object.
	> - 2. If *V* is not an object, return **false**.
	> - 3. Let *V* be the value of the [[Prototype]] property of *V*.
	> - 4. if *V* is **null**, return **false**
	> - 5. If *O* and *V* refer to the same object or if they refer to objects joined to each other (13.1.2), return **true**.
        > - 6. Go to step 3.
NuXJS result: `Object.prototype.isPrototypeOf.call(null, {})` returns `false`.
Expected: `TypeError` because `null` is not an object.
```io
> try { Object.prototype.isPrototypeOf.call(null, {}); } catch (e) { print(e.name); }
< TypeError
-
```
See `tests/unconforming/isPrototypeOfNullThis.io` for a regression test.
- [ ] built-ins/Object/prototype/isPrototypeOf/S15.2.4.6_A13 — Let O be the result of calling ToObject passing the this value as the argument.
	> #### **15.2.4.6 Object.prototype.isPrototypeOf (V)**
	> 
	> When the **isPrototypeOf** method is called with argument *V*, the following steps are taken:
	> 
	> - 1. Let *O* be this object.
	> - 2. If *V* is not an object, return **false**.
	> - 3. Let *V* be the value of the [[Prototype]] property of *V*.
	> - 4. if *V* is **null**, return **false**
	> - 5. If *O* and *V* refer to the same object or if they refer to objects joined to each other (13.1.2), return **true**.
        > - 6. Go to step 3.
NuXJS result: `Object.prototype.isPrototypeOf.call(undefined, {})` returns `false`.
Expected: `TypeError` because `undefined` is not an object.
```io
> try { Object.prototype.isPrototypeOf.call(undefined, {}); } catch (e) { print(e.name); }
< TypeError
-
```
See `tests/unconforming/isPrototypeOfUndefinedThis.io` for a regression test.
- [ ] built-ins/Object/prototype/propertyIsEnumerable/S15.2.4.7_A12 — Let O be the result of calling ToObject passing the this value as the argument.
	> #### **15.2.4.7 Object.prototype.propertyIsEnumerable (V)**
	> 
	> When the **propertyIsEnumerable** method is called with argument *V*, the following steps are taken:
	> 
	> - 1. Let *O* be this object.
	> - 2. Call ToString(*V*).
	> - 3. If *O* doesn't have a property with the name given by Result(2), return **false**.
	> - 4. If the property has the DontEnum attribute, return **false**.
        > - 5. Return **true**.
        >
        > ## *NOTE*
NuXJS result: `Object.prototype.propertyIsEnumerable.call(null, "x")` returns `false`.
Expected: `TypeError` because `null` cannot be converted to an object.
```io
> try { Object.prototype.propertyIsEnumerable.call(null, "x"); } catch (e) { print(e.name); }
< TypeError
-
```
See `tests/unconforming/propertyIsEnumerableNullThis.io` for a regression test.
- [ ] built-ins/Object/prototype/propertyIsEnumerable/S15.2.4.7_A13 — Let O be the result of calling ToObject passing the this value as the argument.
	> #### **15.2.4.7 Object.prototype.propertyIsEnumerable (V)**
	> 
	> When the **propertyIsEnumerable** method is called with argument *V*, the following steps are taken:
	> 
	> - 1. Let *O* be this object.
	> - 2. Call ToString(*V*).
	> - 3. If *O* doesn't have a property with the name given by Result(2), return **false**.
	> - 4. If the property has the DontEnum attribute, return **false**.
        > - 5. Return **true**.
        >
        > ## *NOTE*
NuXJS result: `Object.prototype.propertyIsEnumerable.call(undefined, "x")` returns `false`.
Expected: `TypeError` because `undefined` cannot be converted to an object.
```io
> try { Object.prototype.propertyIsEnumerable.call(undefined, "x"); } catch (e) { print(e.name); }
< TypeError
-
```
See `tests/unconforming/propertyIsEnumerableUndefinedThis.io` for a regression test.
- [ ] built-ins/Object/prototype/toLocaleString/S15.2.4.3_A12 — Let O be the result of calling ToObject passing the this value as the argument.
> ## **15.2.4.3 Object.prototype.toLocaleString ( )**
	> 
	> This function returns the result of calling **toString()**.
	> 
> ## *NOTE 1*
>
> *This function is provided to give all Objects a generic* **toLocaleString** *interface, even though not all may use it. Currently,* **Array***,* **Number***, and* **Date** *provide their own locale-sensitive* **toLocaleString** *methods.*
>
NuXJS result: `Object.prototype.toLocaleString.call(null)` and `call(undefined)` return `"[object Object]"`.
Expected: both calls should throw a `TypeError` because `null` and `undefined` are not objects.
```io
> try { Object.prototype.toLocaleString.call(null); } catch (e) { print(e.name); }
< TypeError
-
> try { Object.prototype.toLocaleString.call(undefined); } catch (e) { print(e.name); }
< TypeError
-
```
See `tests/unconforming/objectToLocaleStringNullThis.io` and `tests/unconforming/objectToLocaleStringUndefinedThis.io` for regression tests.
	> ## *NOTE 2*
	> 
	> *The first parameter to this function is likely to be used in a future version of this standard; it is recommended that implementations do not use this parameter position for anything else.*
- [ ] built-ins/Object/prototype/toLocaleString/S15.2.4.3_A13 — Let O be the result of calling ToObject passing the this value as the argument.
	> ## **15.2.4.3 Object.prototype.toLocaleString ( )**
	> 
	> This function returns the result of calling **toString()**.
	> 
	> ## *NOTE 1*
	> 
	> *This function is provided to give all Objects a generic* **toLocaleString** *interface, even though not all may use it. Currently,* **Array***,* **Number***, and* **Date** *provide their own locale-sensitive* **toLocaleString** *methods.*
	> 
	> ## *NOTE 2*
	> 
	> *The first parameter to this function is likely to be used in a future version of this standard; it is recommended that implementations do not use this parameter position for anything else.*
- [ ] built-ins/Object/prototype/toString/15.2.4.2-1-1 — Object.prototype.toString - '[object Undefined]' will be returned when 'this' value is undefined
- [ ] built-ins/Object/prototype/toString/15.2.4.2-1-2 — Object.prototype.toString - '[object Undefined]' will be returned when 'this' value is undefined
- [ ] built-ins/Object/prototype/toString/15.2.4.2-2-1 — Object.prototype.toString - '[object Null]' will be returned when 'this' value is null
- [ ] built-ins/Object/prototype/toString/15.2.4.2-2-2 — Object.prototype.toString - '[object Null]' will be returned when 'this' value is null
- [ ] built-ins/Object/prototype/valueOf/S15.2.4.4_A12 — Checking Object.prototype.valueOf invoked by the 'call' property.
	> #### **15.2.4.4 Object.prototype.valueOf ( )**
	> 
	> The **valueOf** method returns its **this** value. If the object is the result of calling the Object constructor with a host object (15.2.2.1), it is implementation-defined whether **valueOf** returns its **this** value or another value such as the host object originally passed to the constructor.
- [ ] built-ins/Object/prototype/valueOf/S15.2.4.4_A13 — Checking Object.prototype.valueOf invoked by the 'call' property.
	> #### **15.2.4.4 Object.prototype.valueOf ( )**
	> 
	> The **valueOf** method returns its **this** value. If the object is the result of calling the Object constructor with a host object (15.2.2.1), it is implementation-defined whether **valueOf** returns its **this** value or another value such as the host object originally passed to the constructor.
- [ ] built-ins/Object/prototype/valueOf/S15.2.4.4_A14 — Checking Object.prototype.valueOf invoked by the 'call' property.
	> #### **15.2.4.4 Object.prototype.valueOf ( )**
	> 
	> The **valueOf** method returns its **this** value. If the object is the result of calling the Object constructor with a host object (15.2.2.1), it is implementation-defined whether **valueOf** returns its **this** value or another value such as the host object originally passed to the constructor.
- [ ] built-ins/Object/prototype/valueOf/S15.2.4.4_A15 — Checking Object.prototype.valueOf when called as a global function.
	> #### **15.2.4.4 Object.prototype.valueOf ( )**
	> 
	> The **valueOf** method returns its **this** value. If the object is the result of calling the Object constructor with a host object (15.2.2.1), it is implementation-defined whether **valueOf** returns its **this** value or another value such as the host object originally passed to the constructor.


### RegExp
- [ ] built-ins/RegExp/S15.10.2.12_A1_T1 — WhiteSpace
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
NuXJS result: `/\s/.test("\u1680")` returns `false` and `/\S/.test("\u1680")` returns `true`.
Expected: `\u1680` belongs to *WhiteSpace* so `\s` should match and `\S` should not.
```io
> print(/\s/.test("\u1680"))
< true
-
> print(/\S/.test("\u1680"))
< false
-
```
See `tests/unconforming/regExpWhiteSpace.io` for a regression test.

- [ ] built-ins/RegExp/S15.10.2.12_A2_T1 — WhiteSpace
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
NuXJS result: `/\s/.test("\u2000")` returns `false` and `/\S/.test("\u2000")` returns `true`.
Expected: `\u2000` is classified as *WhiteSpace*, so `\s` should match and `\S` should not.
```io
> print(/\s/.test("\u2000"))
< true
-
> print(/\S/.test("\u2000"))
< false
-
```
See `tests/unconforming/regExpWhiteSpace2000.io` for a regression test.
- [ ] built-ins/RegExp/S15.10.2.8_A3_T15 — "see bug http:bugzilla.mozilla.org/show_bug.cgi?id=119909" — RangeError: Internal compiler limitations reached. Reduce code complexity.
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
- [ ] built-ins/RegExp/prototype/exec/S15.10.6.2_A1_T10 — String is 1.01 and RegExp is /1|12/
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
- [ ] built-ins/RegExp/prototype/exec/S15.10.6.2_A1_T11 — String is new Number(1.012) and RegExp is /2|12/
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
- [ ] built-ins/RegExp/prototype/exec/S15.10.6.2_A1_T12 — String is {toString:function(){return Math.PI;}} and RegExp is /\.14/
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
- [ ] built-ins/RegExp/prototype/exec/S15.10.6.2_A1_T13 — String is true and RegExp is /t[a-b|q-s]/
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
- [ ] built-ins/RegExp/prototype/exec/S15.10.6.2_A1_T14 — String is new Boolean and RegExp is /AL|se/
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
- [ ] built-ins/RegExp/prototype/exec/S15.10.6.2_A1_T15 — "String is {toString:function(){return false;}} and RegExp is /LS/i"
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
- [ ] built-ins/RegExp/prototype/exec/S15.10.6.2_A1_T17 — String is null and RegExp is /ll|l/
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
- [ ] built-ins/RegExp/prototype/exec/S15.10.6.2_A1_T18 — String is undefined and RegExp is /nd|ne/
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
- [ ] built-ins/RegExp/prototype/exec/S15.10.6.2_A1_T19 — String is void 0 and RegExp is /e{1}/
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
- [ ] built-ins/RegExp/prototype/exec/S15.10.6.2_A1_T2 — String is new String("123") and RegExp is /((1)|(12))((3)|(23))/
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
- [ ] built-ins/RegExp/prototype/exec/S15.10.6.2_A1_T20 — String is x and RegExp is /[a-f]d/, where x is undefined variable
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
- [ ] built-ins/RegExp/prototype/exec/S15.10.6.2_A1_T21 — String is function(){}() and RegExp is /[a-z]n/
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
- [ ] built-ins/RegExp/prototype/exec/S15.10.6.2_A1_T3 — String is new Object("abcdefghi") and RegExp is /a[a-z]{2,4}/
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
- [ ] built-ins/RegExp/prototype/exec/S15.10.6.2_A1_T4 — String is {toString:function(){return "abcdefghi";}} and RegExp is /a[a-z]{2,4}?/
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
- [ ] built-ins/RegExp/prototype/exec/S15.10.6.2_A1_T5 — String is {toString:function(){return {};}, valueOf:function(){return "aabaac";}} and RegExp is /(aa|aabaac|ba|b|c)* /
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

### String
- [ ] built-ins/String/prototype/indexOf/S15.5.4.7_A1_T11 — calling `indexOf` with Date object `this` yields wrong index
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
```io
> print(String.prototype.indexOf.call(new Date(0), "GMT"))
< 25
-
```
See `tests/unconforming/stringIndexOfDateThis.io` for a regression test.
- [ ] built-ins/String/prototype/replace/S15.5.4.11_A12 — `replace` should treat undefined `this` correctly
       > #### **15.5.4.11 String.prototype.replace (searchValue, replaceValue)**
       >
       > Let *string* denote the result of converting the **this** value to a string.
       >
       NuXJS result: `String.prototype.replace.call(undefined, "d", "D")` produces `[object Object]`.
       Expected: the **this** value `undefined` should convert to the string "undefined", yielding `"unDefineD"` after replacement.

       ```io
       > print(String.prototype.replace.call(undefined, "d", "D"))
       < unDefineD
       -
       ```
       See `tests/unconforming/stringReplaceUndefinedThis.io` for a regression test.
- [ ] built-ins/String/prototype/replace/S15.5.4.11_A1_T11 — replacing with objects whose `toString` throws
- [ ] built-ins/String/prototype/replace/S15.5.4.11_A1_T12 — replacing with object whose `valueOf` throws
- [ ] built-ins/String/prototype/replace/S15.5.4.11_A3_T1 — `$11` sequences ignored in computed `replaceValue`
       > #### **15.5.4.11 String.prototype.replace ( searchValue, replaceValue )**
       >
       > If *replaceValue* is not a function, ToString(*replaceValue*) is processed for substitution patterns.  The sequence `"$"` followed by one or two decimal digits *nn* (0 < *nn* ≤ *NCaptures*) is replaced by the *nn*-th captured substring.
       >
       NuXJS result: `var r = "$11" + 15; "xab".replace(/(x)/, r)` leaves the `$11` literal and returns `"$1115ab"`.
       Expected: `$11` should expand to capture `1` followed by `"1"`, producing `"x115ab"`.

       ```io
       > var r = "$11" + 15
       > print("xab".replace(/(x)/, r))
       < x115ab
       -
       ```
       See `tests/unconforming/stringReplace11Concat.io` for a regression test.
- [ ] built-ins/String/prototype/replace/S15.5.4.11_A3_T2 — `replaceValue` is "$11" + "15"
       > #### **15.5.4.11 String.prototype.replace ( searchValue, replaceValue )**
       >
       > If *replaceValue* is not a function, ToString(*replaceValue*) is processed for substitution patterns.  The sequence "\$" followed by one or two decimal digits *nn* (0 < *nn* ≤ *NCaptures*) is replaced by the *nn*-th captured substring.
       >
       NuXJS result: `var r = "$11" + "15"; "xab".replace(/(x)/, r)` yields `$1115ab`.
       Expected: `$11` should expand to capture `1` followed by "1", producing "x115ab".
       ```io
       > var r = "$11" + "15"
       > print("xab".replace(/(x)/, r))
       < x115ab
       -
       ```
       See `tests/unconforming/stringReplace11Plus15.io` for a regression test.
- [ ] built-ins/String/prototype/replace/S15.5.4.11_A3_T3 — `replaceValue` is "$11" + "A15"
       > #### **15.5.4.11 String.prototype.replace ( searchValue, replaceValue )**
       >
       > If *replaceValue* is not a function, ToString(*replaceValue*) is processed for substitution patterns.  The sequence "\$" followed by one or two decimal digits *nn* (0 < *nn* ≤ *NCaptures*) is replaced by the *nn*-th captured substring.
       >
       NuXJS result: `var r = "$11" + "A15"; "xab".replace(/(x)/, r)` returns `$11A15ab`.
       Expected: "x1A15ab" after expanding `$11` to capture `1` plus "1".
       ```io
       > var r = "$11" + "A15"
       > print("xab".replace(/(x)/, r))
       < x1A15ab
       -
       ```
       See `tests/unconforming/stringReplace11PlusA15.io` for a regression test.
- [ ] built-ins/String/prototype/replace/S15.5.4.11_A5_T1 — regex `/^(a+)\1*,\1+$/` with backreference
       > #### **15.10.2.9 AtomEscape**
       >
       > An escape sequence of the form "\\" followed by a nonzero decimal number *n* matches the result of the *n*th set of capturing parentheses.
       >
       NuXJS result: "aa,a".replace(/^(a+)\1*,\1+$/, "$1") leaves the string unchanged.
       Expected: backreference handling should collapse the match to "a".
       ```io
       > print("aa,a".replace(/^(a+)\1*,\1+$/, "$1"))
       < a
       -
       ```
       See `tests/unconforming/stringReplaceBackreference.io` for a regression test.
- [ ] built-ins/String/prototype/toLocaleLowerCase/special_casing_conditional — missing conditional Unicode mappings
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
NuXJS result: `print("\u0130".toLocaleLowerCase())` outputs `"i"`, omitting the required combining dot above.
Expected: `"i̇"` (letter *i* followed by a combining dot).
```io
> print("\u0130".toLocaleLowerCase())
< i̇
-
```
See `tests/unconforming/toLocaleLowerCaseSpecialCasing.io` for a regression test.
- [ ] built-ins/String/prototype/toLocaleLowerCase/supplementary_plane — fails to iterate over supplementary-plane code points
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
```io
> print("\uD835\uDD0A".toLocaleLowerCase())
< 𝔊
-
```
See `tests/unconforming/toLocaleLowerCaseSupplementaryPlane.io` for a regression test.
- [ ] built-ins/String/prototype/toLocaleUpperCase/special_casing — missing special Unicode casing mappings
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
NuXJS result: `print("i".toLocaleUpperCase())` outputs `"I"`, losing the required dot above.
Expected: `"İ"`.
```io
> print("i".toLocaleUpperCase())
< İ
-
```
See `tests/unconforming/toLocaleUpperCaseSpecialCasing.io` for a regression test.
- [ ] built-ins/String/prototype/toLocaleUpperCase/supplementary_plane — fails to iterate over supplementary-plane code points
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
```io
> print("\uD835\uDD24".toLocaleUpperCase())
< 𝔊
-
```
See `tests/unconforming/toLocaleUpperCaseSupplementaryPlane.io` for a regression test.
- [ ] built-ins/String/prototype/toLowerCase/special_casing — missing special Unicode lowercase mappings
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
NuXJS result: `print("\u0130".toLowerCase())` outputs `"i"`, omitting the combining dot.
Expected: `"i̇"` (letter *i* followed by a combining dot).
```io
> print("\u0130".toLowerCase())
< i̇
-
```
See `tests/unconforming/toLowerCaseSpecialCasing.io` for a regression test.
- [ ] built-ins/String/prototype/toLowerCase/special_casing_conditional — missing conditional lowercase mappings
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
NuXJS result: `print("ΟΣ".toLowerCase())` yields `"οσ"`, using the standard sigma.
Expected: `"ος"` with the final sigma `ς`.
```io
> print("ΟΣ".toLowerCase())
< ος
-
```
See `tests/unconforming/toLowerCaseSpecialCasingConditional.io` for a regression test.
- [ ] built-ins/String/prototype/toLowerCase/supplementary_plane — fails to iterate over supplementary-plane code points
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
```io
> print("\uD835\uDD0A".toLowerCase())
< 𝔊
-
```
See `tests/unconforming/toLowerCaseSupplementaryPlane.io` for a regression test.
- [ ] built-ins/String/prototype/toUpperCase/special_casing — missing special Unicode uppercase mappings
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
NuXJS result: `print("\u03C2".toUpperCase())` outputs `"S"`.
Expected: `"Σ"`.
```io
> print("\u03C2".toUpperCase())
< Σ
-
```
See `tests/unconforming/toUpperCaseSpecialCasing.io` for a regression test.
- [ ] built-ins/String/prototype/toUpperCase/supplementary_plane — fails to iterate over supplementary-plane code points
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
```io
> print("\uD835\uDD0A".toUpperCase())
< 𝔊
-
```
See `tests/unconforming/toUpperCaseSupplementaryPlane.io` for a regression test.
### parseFloat
- [ ] built-ins/parseFloat/S15.1.2.3_A2_T10 — "StrWhiteSpaceChar :: USP"
	> ## **15.1.2.3 parseFloat (string)**
	> 
	> The **parseFloat** function produces a number value dictated by interpretation of the contents of the *string* argument as a decimal literal.
	> 
	> When the **parseFloat** function is called, the following steps are taken:
	> 
	> - 1. Call ToString(*string*).
	> - 2. Compute a substring of Result(1) consisting of the leftmost character that is not a *StrWhiteSpaceChar* and all characters to the right of that character.(In other words, remove leading white space.)
        > - 3. If neither Result(2) nor any prefix of Result(2) satisfies the syntax of a *StrDecimalLiteral* (see 0), return **NaN**.
        > - 4. Compute the longest prefix of Result(2), which might be Result(2) itself, which satisfies the syntax of a *StrDecimalLiteral*.
        > - 5. Return the number value for the MV of Result(4).
        >
        > *StrWhiteSpaceChar* **:::** <TAB> <SP> <NBSP> <FF> <VT> <CR> <LF> <LS> <PS> <USP>

NuXJS result: `parseFloat("\u16801.5")` returns `NaN`.
Expected: `1.5`.

```io
> print(parseFloat("\u16801.5"))
< 1.5
-
```
See `tests/unconforming/parseFloatUSP.io` for a regression test.


### parseInt
- [ ] built-ins/parseInt/S15.1.2.2_A2_T10 — "StrWhiteSpaceChar :: USP"
	> #### **15.1.2.2 parseInt (string , radix)**
	> 
	> The **parseInt** function produces an integer value dictated by interpretation of the contents of the *string* argument according to the specified *radix*. Leading whitespace in the string is ignored. If *radix* is **undefined** or 0, it is assumed to be 10 except when the number begins with the character pairs **0x** or **0X**, in which case a radix of 16 is assumed. Any radix-16 number may also optionally begin with the character pairs **0x** or **0X**.
	> 
	> When the **parseInt** function is called, the following steps are taken:
	> 
	> - 1. Call ToString(*string*).
	> - 2. Let *S* be a newly created substring of Result(1) consisting of the first character that is not a *StrWhiteSpaceChar* and all characters following that character. (In other words, remove leading white space.)
	> - 3. Let *sign* be 1.
	> - 4. If *S* is not empty and the first character of *S* is a minus sign **-**, let *sign* be −1.
        > - 5. If *S* is not empty and the first character of *S* is a plus sign **+** or a minus sign **-**, then remove the first character from *S*.
        > - 6. Let *R* = ToInt32(*radix*).
        >
        > *StrWhiteSpaceChar* **:::** <TAB> <SP> <NBSP> <FF> <VT> <CR> <LF> <LS> <PS> <USP>

NuXJS result: `parseInt("\u1680123")` returns `NaN`.
Expected: `123`.

```io
> print(parseInt("\u1680123"))
< 123
-
```
See `tests/unconforming/parseIntUSP.io` for a regression test.

- [ ] built-ins/parseInt/S15.1.2.2_A5.2_T2 — ": 0X"
        > #### **15.1.2.2 parseInt (string , radix)**
        >
        > The **parseInt** function produces an integer value dictated by interpretation of the contents of the *string* argument according to the specified *radix*. Leading whitespace in the string is ignored. If *radix* is **undefined** or 0, it is assumed to be 10 except when the number begins with the character pairs **0x** or **0X**, in which case a radix of 16 is assumed. Any radix-16 number may also optionally begin with the character pairs **0x** or **0X**.
        >
        > When the **parseInt** function is called, the following steps are taken:
        >
        > - 1. Call ToString(*string*).
        > - 2. Let *S* be a newly created substring of Result(1) consisting of the first character that is not a *StrWhiteSpaceChar* and all characters following that character. (In other words, remove leading white space.)
        > - 3. Let *sign* be 1.
        > - 4. If *S* is not empty and the first character of *S* is a minus sign **-**, let *sign* be −1.
        > - 5. If *S* is not empty and the first character of *S* is a plus sign **+** or a minus sign **-**, then remove the first character from *S*.
        > - 6. Let *R* = ToInt32(*radix*).
NuXJS result: `parseInt("0X1")` returns `0`, ignoring the hexadecimal prefix.
Expected: strings starting with `0x` or `0X` must parse as base 16 when the radix is undefined or 0, producing `1` for `"0X1"`.
```io
> print(parseInt("0X1"))
< 1
-
> print(parseInt("0XA"))
< 10
-
```
See `tests/unconforming/parseInt0XPrefix.io` for a regression test.
- [ ] built-ins/parseInt/S15.1.2.2_A7.2_T3 — Checking algorithm for R = 16
        > #### **15.1.2.2 parseInt (string , radix)**
        >
        > The **parseInt** function produces an integer value dictated by interpretation of the contents of the *string* argument according to the specified *radix*. Leading whitespace in the string is ignored. If *radix* is **undefined** or 0, it is assumed to be 10 except when the number begins with the character pairs **0x** or **0X**, in which case a radix of 16 is assumed. Any radix-16 number may also optionally begin with the character pairs **0x** or **0X**.
        >
        > When the **parseInt** function is called, the following steps are taken:
NuXJS result: `parseInt("0X10", 16)` returns `0` instead of `16`.
Expected: with radix 16, uppercase `0X` prefixes are valid hexadecimal literals, so `parseInt("0X10", 16)` should be `16`.
```io
> print(parseInt("0X10", 16))
< 16
-
> print(parseInt("0XFF", 16))
< 255
-
```
See `tests/unconforming/parseIntRadix16Uppercase.io` for a regression test.
	> 
	> - 1. Call ToString(*string*).
	> - 2. Let *S* be a newly created substring of Result(1) consisting of the first character that is not a *StrWhiteSpaceChar* and all characters following that character. (In other words, remove leading white space.)
	> - 3. Let *sign* be 1.
	> - 4. If *S* is not empty and the first character of *S* is a minus sign **-**, let *sign* be −1.
	> - 5. If *S* is not empty and the first character of *S* is a plus sign **+** or a minus sign **-**, then remove the first character from *S*.
	> - 6. Let *R* = ToInt32(*radix*).

