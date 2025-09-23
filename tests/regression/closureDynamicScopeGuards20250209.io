> function captureWith(o) {
> with (o) {
> return function() { return foo; };
> }
> }
> var withTarget = { foo: 7 };
> var readFromWith = captureWith(withTarget);
> withTarget.foo = 42;
> print(readFromWith());
< 42
-
> function captureCatch(value) {
> try {
> throw value;
> } catch (e) {
> return function() { return e; };
> }
> }
> print(captureCatch("thrown value")());
< thrown value
-
> function captureEval() {
> eval("var dynamicSlot = 'eval value';");
> return function() { return dynamicSlot; };
> }
> print(captureEval()());
< eval value
-
