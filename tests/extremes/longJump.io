// Skipping an if-block of more than 2^23 code words must throw a RangeError. Each x++ compiles to 7 code words.
> var body = "x++;x++;x++;x++;x++;";
> for (var i = 0; i < 18; ++i) { body += body; }
> try { new Function("if (x) {" + body + "}"); } catch (e) { print(e.name + ": " + e.message); }
< RangeError: Internal compiler limitations reached. Reduce code complexity.
-
// The case test and the case body each fit, but the jump from the test back to the body spans over 2^23 code words.
> var body = "x++;x++;x++;x++;x++;";
> var test = "x++,x++,x++,x++,x++,";
> for (var i = 0; i < 17; ++i) { body += body; test += test; }
> var source = "switch (x) { case (" + test + "1): " + body + " }";
> try { new Function(source); } catch (e) { print(e.name + ": " + e.message); }
< RangeError: Internal compiler limitations reached. Reduce code complexity.
-
// A short switch after more than 2^23 code words must compile, since only its own jumps count.
> var body = "x++;x++;x++;x++;x++;";
> for (var i = 0; i < 18; ++i) { body += body; }
> print(new Function("x", body + " switch (typeof x) { case 'number': return 'case'; } return 'after';")(0));
< case
