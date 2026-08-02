// 11.13.1 evaluates the LeftHandSideExpression at step 1, *before* the right-hand side at step 2, and hands that
// same Reference to PutValue at step 4; 11.13.2 does the same at its steps 1 and 6, as do 11.3 and 11.4.4 for
// ++ and --. A Reference is a (base, name) pair, and 10.1.4 fixes the base to the scope object found at that
// moment. The engine used to keep only the name and look it up again at write time, so a right-hand side that
// deleted the binding retargeted the write to whatever the name resolved to next. That is still what the es3
// build does; see the es3only twin. V8 has the same deviation, so these expectations come from the spec text.
// The twin of each case with nothing moving is the control: it must be unaffected.
> function show(l, v) { print(l + ": " + v) }
-
// Simple assignment. No read of the target at all, but the reference is still captured before the right side.
> function simple() { var x = 0; var scope = { x: 1 }; with (scope) { x = (delete scope.x, 2) } return scope.x + "/" + x }
> show("simple", simple());
< simple: 2/0
> function simpleControl() { var x = 0; var scope = { x: 1 }; with (scope) { x = 2 } return scope.x + "/" + x }
> show("control", simpleControl());
< control: 2/0
-
// Compound assignment: the read happens through the captured reference too.
> function compound() { var x = 0; var scope = { x: 2 }; with (scope) { x += (delete scope.x, 3) } return scope.x + "/" + x }
> show("compound", compound());
< compound: 5/0
> function compoundControl() { var x = 0; var scope = { x: 2 }; with (scope) { x += 3 } return scope.x + "/" + x }
> show("control", compoundControl());
< control: 5/0
-
// A getter that deletes its own binding is the ES5 route to the same thing, and needs no explicit delete.
> function viaGetter() { var x = 0; var scope = { get x() { delete this.x; return 2 } }; with (scope) { x ^= 3 } return scope.x + "/" + x }
> show("getter", viaGetter());
< getter: 1/0
-
// Prefix and postfix ++/-- capture the reference the same way, and postfix still yields the old value.
> function pre() { var x = 0; var scope = { get x() { delete this.x; return 5 } }; with (scope) { ++x } return scope.x + "/" + x }
> show("prefix", pre());
< prefix: 6/0
> function post() { var x = 0; var scope = { get x() { delete this.x; return 5 } }; var r; with (scope) { r = x++ } return scope.x + "/" + x + "/" + r }
> show("postfix", post());
< postfix: 6/0/5
-
// A binding created by eval during the right-hand side must not capture the write either: the reference was
// taken when the outer one was the only one in scope.
> var g = 0;
> var innerG = (function () { g = (eval("var g;"), 1); return g })();
> show("evalDeclared", typeof innerG + "/" + g);
< evalDeclared: undefined/1
-
// Nesting works because the captured reference lives on the value stack, like a property base.
> function nested() { var a = 1, b = 10; var s = { a: 1, b: 10 }; with (s) { a += (b += 5, delete s.a, 2) } return s.a + "/" + s.b + "/" + a + "/" + b }
> show("nested", nested());
< nested: 3/15/1/10
-
// Declarative bindings cannot move, so locals and catch parameters take the unchanged path.
> function localPath() { var x = 1; x += (x = 5, 2); return x }
> show("local", localPath());
< local: 3
> function catchPath() { try { throw 7 } catch (e) { e += 1; return e } }
> show("catch", catchPath());
< catch: 8
-
// The global object is an object environment record too, so the same capture applies there.
> var gg = 1;
> (function () { gg = (delete this.gg, 4) })();
> show("global", typeof gg + "/" + gg);
< global: number/4
-
// Strict mode still rejects assigning to eval and arguments, which is checked on the same path.
> try { eval('"use strict"; eval = 1;'); print("no error") } catch (e) { print(e.name) }
< SyntaxError
> try { eval('"use strict"; arguments++;'); print("no error") } catch (e) { print(e.name) }
< SyntaxError
-
