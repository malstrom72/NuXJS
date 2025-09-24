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
> function outer() {
> var x = 1;
> function inner() { eval("var x = 3"); ++x; }
> inner();
> print(x);
> }
> outer();
< 2
-
> function test() {
> var x = 3, y = { x: 9 };
> function inner() { ++x; }
> with (y) { inner(); }
> print(x);
> }
> test();
< 4
-
> function test2() {
> var x = 3, y = { x: 9 };
> with (y) { function inner() { ++x; } }
> inner();
> print(x);
> }
> test2();
< 4
-
> function test3() {
> var x = 3, y = { x: 9 };
> with (y) {
> function inner() { ++x; }
> inner();
> }
> print(x);
> }
> test3();
< 4
-
> function outerAgain() {
> var x = 1234;
> function factory(box) {
> with (box) { return function inner() { return x; }; }
> }
> return factory;
> }
> print((outerAgain())({ x: 42 })());
< 42
-
> function moreOuter() {
> var x = 1293;
> function makeInner() {
> try { throw 2; }
> catch (x) { return function inner() { return x; }; }
> }
> return makeInner;
> }
> print((moreOuter())()());
< 2
-
