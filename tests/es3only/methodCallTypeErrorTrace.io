// Split from regression/stackTraceVerbatim.io: ES3 resolves the callee after the arguments, so the
// TypeError for a non-callable method call maps to the position after ')'. (ES5 twin: tests/es5.)
> try { ({}).notAFunction(); } catch (err) { print(err.stack) }
< TypeError: notAFunction is not a function
<     at <anonymous>:1:26
-
