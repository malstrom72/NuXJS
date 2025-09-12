NuXJS documentation, compatibility notes, and standard-library guidelines consistently warn that the engine does not fully adhere to strict ES3 evaluation order. Known deviations include:
	•	Early implicit conversions – valueOf / toString may run earlier than ES3 specifies.
	•	Member-expression evaluation – base object and arguments are evaluated before property selection (ES3 style).
	•	Assignments – right-hand side is resolved before the left-hand reference.
	•	Property access – property key may be converted before the base object.
	•	Guidelines explicitly tell contributors to avoid “non-ES3 evaluation order.”

The bundled ECMAScript 5.1 spec notes that Edition 3 had partially right-to-left ordering for > and <=, later changed to left-to-right.

Test262 coverage (bundled under externals/):
	•	Function call arguments:
S11.2.4_A1.4_T1.js – S11.2.4_A1.4_T4.js verify arguments are evaluated left-to-right (using side effects / exceptions).
	•	Arithmetic operators:
S11.6.1_A2.3_T1.js, S11.6.1_A2.4_T1.js (addition)
S11.6.2_A2.3_T1.js (subtraction)
S11.5.1_A2.3_T1.js (multiplication)
S11.5.2_A2.3_T1.js (division)
S11.5.3_A2.4_T1.js (modulus)
	•	Bitwise & shifts:
S11.7.1_A2.3_T1.js (<<)
S11.7.2_A2.4_T1.js (>>)
S11.7.3_A2.3_T1.js (>>>)
S11.10.2_A2.4_T1.js (^)
	•	Comparisons & membership:
S11.8.1_A2.4_T1.js (<)
S11.8.2_A2.3_T1.js, S11.8.2_A2.4_T1.js (> with ToNumber + operand order)
test/language/expressions/greater-than/11.8.2-1.js … 11.8.2-4.js (>)
test/language/expressions/less-than-or-equal/11.8.3-1.js … 11.8.3-5.js (<=)
S11.8.7_A2.4_T1.js (in)
S11.9.4_A2.4_T1.js (===)
S11.9.2_A2.4_T1.js (!=)
	•	Post-ES3 tests still present:
test/language/expressions/exponentiation/exp-operator-evaluation-order.js
test/language/expressions/template-literal/evaluation-order.js

Together, these tests confirm left-to-right operand evaluation and correct coercion order for ES3 features, while highlighting the areas where NuXJS intentionally diverges.