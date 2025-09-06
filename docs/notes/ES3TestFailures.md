# ES3 Test262 Failures Analysis
80 Test262 tests from the ES3 portion of Test262 still fail in NuXJS. All of these tests target ES3 semantics that NuXJS does not yet implement correctly.
| Feature | Spec Clause | Failures |
| --- | --- | ---:|
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

### Array
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
- [ ] built-ins/Array/S15.4_A1.1_T1 — Checking for boolean primitive
	> #### **15.4 Array Objects**
	> 
	> Array objects give special treatment to a certain class of property names. A property name *P* (in the form of a string value) is an *array index* if and only if ToString(ToUint32(*P*)) is equal to *P* and ToUint32(*P*) is not equal to 2<sup>32</sup>−1. Every Array object has a **length** property whose value is always a nonnegative integer less than 232. The value of the **length** property is numerically greater than the name of every property whose name is an array index; whenever a property of an Array object is created or changed, other properties are adjusted as necessary to maintain this invariant. Specifically, whenever a property is added whose name is an array index, the **length** property is changed, if necessary, to be one more than the numeric value of that array index; and whenever the **length** property is changed, every property whose name is an array index whose value is not smaller than the new length is automatically deleted. This constraint applies only to properties of the Array object itself and is unaffected by **length** or array index properties that may be inherited from its prototype.
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
- [ ] built-ins/Error/prototype/toString/15.11.4.4-8-1 — Error.prototype.toString return the value of 'msg' when 'name' is empty string and 'msg' isn't undefined

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
- [ ] built-ins/Object/prototype/toLocaleString/S15.2.4.3_A12 — Let O be the result of calling ToObject passing the this value as the argument.
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
- [ ] built-ins/String/prototype/replace/S15.5.4.11_A12 — `replace` should treat undefined `this` correctly
- [ ] built-ins/String/prototype/replace/S15.5.4.11_A1_T11 — replacing with objects whose `toString` throws
- [ ] built-ins/String/prototype/replace/S15.5.4.11_A1_T12 — replacing with object whose `valueOf` throws
- [ ] built-ins/String/prototype/replace/S15.5.4.11_A3_T1 — `replaceValue` is "$11" + 15
- [ ] built-ins/String/prototype/replace/S15.5.4.11_A3_T2 — `replaceValue` is "$11" + "15"
- [ ] built-ins/String/prototype/replace/S15.5.4.11_A3_T3 — `replaceValue` is "$11" + "A15"
- [ ] built-ins/String/prototype/replace/S15.5.4.11_A5_T1 — regex `/^(a+)\1*,\1+$/` with backreference
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
- [ ] built-ins/parseInt/S15.1.2.2_A7.2_T3 — Checking algorithm for R = 16
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

