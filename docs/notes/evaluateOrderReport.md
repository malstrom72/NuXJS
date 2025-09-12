NuXJS documentation, compatibility notes, and standard-library guidelines consistently warn that the engine does not fully adhere to strict ES3 evaluation order. Comparison with the Edition 3 specification shows the following:
•Early implicit conversions – in ES3, operands are fully evaluated before any `toString`/`valueOf` is invoked (for example, steps 1–6 of the addition operator). NuXJS may trigger these conversions sooner.
•Member-expression calls – NuXJS evaluates the object and argument expressions before resolving the property, which matches ES3’s algorithm but differs from ES5’s later reversal.
•Assignments – ES3 requires evaluating the left-hand side prior to the right-hand side; NuXJS resolves the right-hand side first.
•Property access – ES3 coerces the base object before converting the property key, while NuXJS converts the key first, allowing its `toString`/`valueOf` to run earlier.
•Project guidelines explicitly warn contributors to avoid relying on these non-ES3 evaluation orders.

### Test262 coverage (externals/test262)
After running `python2 externals/test262-master/tools/packaging/test262.py --non_strict_only --command "./output/NuXJS -s" --tests externals/test262-master/ <test-path>` on the bundled tests, NuXJS passes most ES3 cases.  Tests targeting assignment order and property key coercion fail, while later language features fail with syntax errors.


**ES3 features – pass**
•Function call arguments: `S11.2.4_A1.4_T1.js` – `S11.2.4_A1.4_T4.js` confirm left-to-right argument evaluation.
•Arithmetic operators: `S11.6.1_A2.3_T1.js`, `S11.6.1_A2.4_T1.js` (addition); `S11.6.2_A2.3_T1.js` (subtraction); `S11.5.1_A2.3_T1.js` (multiplication); `S11.5.2_A2.3_T1.js` (division); `S11.5.3_A2.4_T1.js` (modulus).
•Bitwise & shifts: `S11.7.1_A2.3_T1.js` (<<); `S11.7.2_A2.4_T1.js` (>>); `S11.7.3_A2.3_T1.js` (>>>); `S11.10.2_A2.4_T1.js` (^).
•Comparisons & membership: `S11.8.1_A2.4_T1.js` (<); `S11.8.2_A2.3_T1.js`, `S11.8.2_A2.4_T1.js` (> with ToNumber + operand order); `test/language/expressions/greater-than/11.8.2-1.js` – `11.8.2-4.js` (>); `test/language/expressions/less-than-or-equal/11.8.3-1.js` – `11.8.3-5.js` (<=); `S11.8.7_A2.4_T1.js` (in); `S11.9.4_A2.4_T1.js` (===); `S11.9.2_A2.4_T1.js` (!=).
Each file above reported “passed in non-strict mode”.

**Not ES3 features – fail or skipped**
•`test/language/expressions/exponentiation/exp-operator-evaluation-order.js` – exponentiation operator was added after ES3 and triggers a SyntaxError.
•`test/language/expressions/template-literal/evaluation-order.js` – template literals are an ES2015 feature and trigger a SyntaxError.

These tests confirm NuXJS’s left-to-right operand evaluation for ES3 constructs.

**NuXJS deviations – targeted tests**
•Early conversions: `language/expressions/addition/S11.6.1_A2.3_T1.js` – passes, leaving NuXJS’s earlier coercions unexercised.
•Assignments: `language/expressions/assignment/S11.13.1_A7_T1.js` – `S11.13.1_A7_T4.js` – fail because NuXJS evaluates the right-hand side before the left-hand side.
•Property access: `language/expressions/postfix-increment/S11.3.1_A6_T1.js` – fails when `toString` on the property key runs before `ToObject` on the base.
