// ES3 15.3.4.3 step 2: apply throws unless argArray is an Array or an Arguments object, so a plain object is
// refused by class. ES5.1 step 3 takes any object, which is why this lives here; the twin is
// tests/es5/functionApplyGeneric.io.
> function test() { return arguments.length; }
> try { test.apply(null, { 'wrong': 'type of object' }); } catch (e) { print(e); }
< TypeError: Argument list has wrong type
-
