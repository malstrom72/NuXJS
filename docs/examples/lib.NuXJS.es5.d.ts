/////////////////////////////
/// NuXJS es5 build additions
/////////////////////////////
// Layer this file on top of lib.NuXJS.d.ts (both via --lib) when targeting the es5 build (NUXJS_ES5).
// The es3 build does not provide these members; leaving this file out makes TypeScript reject them.

interface PropertyDescriptor {
  get?(): any;
  set?(v: any): void;
}

interface PropertyDescriptorMap {
  [key: PropertyKey]: PropertyDescriptor;
}

interface ObjectConstructor {
  /**
   * Gets the own property descriptor of the specified object.
   * @param o Object that contains the property.
   * @param p Name of the property.
   */
  getOwnPropertyDescriptor(o: any, p: PropertyKey): PropertyDescriptor | undefined;

  /**
   * Returns the names of the own properties of an object, enumerable and non-enumerable alike.
   * @param o Object that contains the own properties.
   */
  getOwnPropertyNames(o: any): string[];

  /**
   * Creates an object that has the specified prototype or that has null prototype.
   * @param o Object to use as a prototype. May be null.
   * @param properties JavaScript object that contains one or more property descriptors.
   */
  create(o: object | null, properties?: PropertyDescriptorMap & ThisType<any>): any;

  /**
   * Adds one or more properties to an object, and/or modifies attributes of existing properties.
   * @param o Object on which to add or modify the properties.
   * @param properties JavaScript object that contains one or more descriptor objects. Each descriptor object describes a data property or an accessor property.
   */
  defineProperties(o: any, properties: PropertyDescriptorMap & ThisType<any>): any;

  /**
   * Prevents the modification of attributes of existing properties, and prevents the addition of new properties.
   * @param o Object on which to lock the attributes.
   */
  seal<T>(o: T): T;

  /**
   * Prevents the modification of existing property attributes and values, and prevents the addition of new properties.
   * @param o Object on which to lock the attributes.
   */
  freeze<T>(o: T): Readonly<T>;

  /**
   * Prevents the addition of new properties to an object.
   * @param o Object to make non-extensible.
   */
  preventExtensions<T>(o: T): T;

  /**
   * Returns true if existing property attributes cannot be modified in an object and new properties cannot be added to the object.
   * @param o Object to test.
   */
  isSealed(o: any): boolean;

  /**
   * Returns true if existing property attributes and values cannot be modified in an object, and new properties cannot be added to the object.
   * @param o Object to test.
   */
  isFrozen(o: any): boolean;

  /**
   * Returns a value that indicates whether new properties can be added to an object.
   * @param o Object to test.
   */
  isExtensible(o: any): boolean;

  /**
   * Returns the names of the enumerable string properties and methods of an object.
   * @param o Object that contains the properties and methods.
   */
  keys(o: object): string[];
}

interface Function {
  /**
   * For a given function, creates a bound function that has the same body as the original function.
   * The this object of the bound function is associated with the specified object, and has the specified initial parameters.
   * @param thisArg An object to which the this keyword can refer inside the new function.
   * @param argArray A list of arguments to be passed to the new function.
   */
  bind(this: Function, thisArg: any, ...argArray: any[]): any;
}

interface String {
  /** Removes the leading and trailing white space and line terminator characters from a string. */
  trim(): string;
}

interface Array<T> {
  /**
   * Returns the index of the first occurrence of a value in an array, or -1 if it is not present.
   * @param searchElement The value to locate in the array.
   * @param fromIndex The array index at which to begin the search. If fromIndex is omitted, the search starts at index 0.
   */
  indexOf(searchElement: T, fromIndex?: number): number;
  /**
   * Returns the index of the last occurrence of a specified value in an array, or -1 if it is not present.
   * @param searchElement The value to locate in the array.
   * @param fromIndex The array index at which to begin searching backward. If fromIndex is omitted, the search starts at the last index in the array.
   */
  lastIndexOf(searchElement: T, fromIndex?: number): number;
  /**
   * Determines whether all the members of an array satisfy the specified test.
   * @param predicate A function that accepts up to three arguments. The every method calls the predicate function for each element in the array until the predicate returns a value which is coercible to the Boolean value false, or until the end of the array.
   * @param thisArg An object to which the this keyword can refer in the predicate function. If thisArg is omitted, undefined is used as the this value.
   */
  every(predicate: (value: T, index: number, array: T[]) => unknown, thisArg?: any): boolean;
  /**
   * Determines whether the specified callback function returns true for any element of an array.
   * @param predicate A function that accepts up to three arguments. The some method calls the predicate function for each element in the array until the predicate returns a value which is coercible to the Boolean value true, or until the end of the array.
   * @param thisArg An object to which the this keyword can refer in the predicate function. If thisArg is omitted, undefined is used as the this value.
   */
  some(predicate: (value: T, index: number, array: T[]) => unknown, thisArg?: any): boolean;
  /**
   * Performs the specified action for each element in an array.
   * @param callbackfn A function that accepts up to three arguments. forEach calls the callbackfn function one time for each element in the array.
   * @param thisArg An object to which the this keyword can refer in the callbackfn function. If thisArg is omitted, undefined is used as the this value.
   */
  forEach(callbackfn: (value: T, index: number, array: T[]) => void, thisArg?: any): void;
  /**
   * Calls a defined callback function on each element of an array, and returns an array that contains the results.
   * @param callbackfn A function that accepts up to three arguments. The map method calls the callbackfn function one time for each element in the array.
   * @param thisArg An object to which the this keyword can refer in the callbackfn function. If thisArg is omitted, undefined is used as the this value.
   */
  map<U>(callbackfn: (value: T, index: number, array: T[]) => U, thisArg?: any): U[];
  /**
   * Returns the elements of an array that meet the condition specified in a callback function.
   * @param predicate A function that accepts up to three arguments. The filter method calls the predicate function one time for each element in the array.
   * @param thisArg An object to which the this keyword can refer in the predicate function. If thisArg is omitted, undefined is used as the this value.
   */
  filter(predicate: (value: T, index: number, array: T[]) => unknown, thisArg?: any): T[];
  /**
   * Calls the specified callback function for all the elements in an array. The return value of the callback function is the accumulated result, and is provided as an argument in the next call to the callback function.
   * @param callbackfn A function that accepts up to four arguments. The reduce method calls the callbackfn function one time for each element in the array.
   * @param initialValue If initialValue is specified, it is used as the initial value to start the accumulation. The first call to the callbackfn function provides this value as an argument instead of an array value.
   */
  reduce(callbackfn: (previousValue: T, currentValue: T, currentIndex: number, array: T[]) => T): T;
  reduce<U>(callbackfn: (previousValue: U, currentValue: T, currentIndex: number, array: T[]) => U, initialValue: U): U;
  /**
   * Calls the specified callback function for all the elements in an array, in descending order. The return value of the callback function is the accumulated result, and is provided as an argument in the next call to the callback function.
   * @param callbackfn A function that accepts up to four arguments. The reduceRight method calls the callbackfn function one time for each element in the array.
   * @param initialValue If initialValue is specified, it is used as the initial value to start the accumulation. The first call to the callbackfn function provides this value as an argument instead of an array value.
   */
  reduceRight(callbackfn: (previousValue: T, currentValue: T, currentIndex: number, array: T[]) => T): T;
  reduceRight<U>(callbackfn: (previousValue: U, currentValue: T, currentIndex: number, array: T[]) => U, initialValue: U): U;
}

interface DateConstructor {
  /** Returns the number of milliseconds elapsed since midnight, January 1, 1970 Universal Coordinated Time (UTC). */
  now(): number;
}

interface Date {
  // Annex B (B.2.4 - B.2.6)
  /** Returns the year of the specified date minus 1900. */
  getYear(): number;
  /** Sets the year of the Date object, interpreting values from 0 to 99 as 1900 + year. */
  setYear(year: number): number;
  /** Returns a date converted to a string using Universal Coordinated Time (UTC); the same function object as toUTCString. */
  toGMTString(): string;
}

/**
 * Gets the unencoded version of an encoded Uniform Resource Identifier (URI).
 * @param encodedURI A value representing an encoded URI.
 */
declare function decodeURI(encodedURI: string): string;

/**
 * Gets the unencoded version of an encoded component of a Uniform Resource Identifier (URI).
 * @param encodedURIComponent A value representing an encoded URI component.
 */
declare function decodeURIComponent(encodedURIComponent: string): string;

/**
 * Encodes a text string as a valid Uniform Resource Identifier (URI).
 * @param uri A value representing an unencoded URI.
 */
declare function encodeURI(uri: string): string;

/**
 * Encodes a text string as a valid component of a Uniform Resource Identifier (URI).
 * @param uriComponent A value representing an unencoded URI component.
 */
declare function encodeURIComponent(uriComponent: string): string;
