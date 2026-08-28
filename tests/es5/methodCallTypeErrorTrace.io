// Split from regression/stackTraceVerbatim.io: ES5 11.2.3 fetches the callee before evaluating the
// arguments and diagnoses not-callable only after they have run (steps 3-5), so the TypeError is the call's
// and maps to the close of the argument list. The fetch keeps the name for the message.
> try { ({}).notAFunction(); } catch (err) { print(err.stack) }
< TypeError: notAFunction is not a function
<     at <anonymous>:1:26
-
