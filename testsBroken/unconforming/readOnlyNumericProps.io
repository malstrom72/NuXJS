// In NuXJ it is allowed to create an Array property with a numeric name even if a read-only property higher up in the
// prototype-chain has the same name. This is a side-effect of an important optimization concerning adding elements to
// arrays. Since creating your own read-only properties isn't a part of Ecmascript 3 standard (and no built-in object
// has read-only numerical properties), I'm going to let this pass.
> Object.defineProperty(Array.prototype, '123', { value: 456, writable: false })
> Object.defineProperty(Array.prototype, 'abc', { value: 'def', writable: false })
-
> a=[]
> print(a['abc'])
< def
-
> print(a[123])
< 456
-
> a['abc']='ghi'
> print(a['abc'])
< def
-
> a[123]=789
> print(a[123])
< 789
-
