// Split from regression/stackTraceVerbatim.io: ES5 11.2.3 fetches the callee before evaluating the
// arguments, so the TypeError for a non-callable method call maps to the position after '('.
> try { ({}).notAFunction(); } catch (err) { print(err.stack) }
< TypeError: notAFunction is not a function
<     at <anonymous>:1:25
-
