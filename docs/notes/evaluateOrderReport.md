NuXJS documentation, compatibility notes, and standard-library guidelines consistently warn that the engine does not fully adhere to strict ES3 evaluation order. Comparison with the Edition 3 specification shows the following:
•Early implicit conversions – in ES3, operands are fully evaluated before any `toString`/`valueOf` is invoked (for example, steps 1–6 of the addition operator). NuXJS may trigger these conversions sooner.
•Member-expression calls – NuXJS evaluates the object and argument expressions before resolving the property, which matches ES3’s algorithm but differs from ES5’s later reversal.
•Assignments – ES3 requires evaluating the left-hand side prior to the right-hand side; NuXJS resolves the right-hand side first.
•Property access – ES3 coerces the base object before converting the property key, while NuXJS converts the key first, allowing its `toString`/`valueOf` to run earlier.
•Project guidelines explicitly warn contributors to avoid relying on these non-ES3 evaluation orders.

### Test262 coverage (externals/test262)
The following tables list every referenced Test262 evaluation-order case. Paths are relative to the Test262 `test/` directory.

#### Targeted assignment and property tests
| Test file | What it checks | Result |
| --- | --- | --- |
| language/expressions/assignment/S11.13.1_A7_T1.js | `base[prop] = expr` with `base` null; left side should run before right side | fail |
| language/expressions/assignment/S11.13.1_A7_T2.js | `base` undefined variant of the above | fail |
| language/expressions/assignment/S11.13.1_A7_T3.js | property key coercion throws before evaluating right side | pass |
| language/expressions/assignment/S11.13.1_A7_T4.js | property key coercion executed only once | pass |
| language/expressions/postfix-increment/S11.3.1_A6_T1.js | `base[prop]++` with `base` null should evaluate reference once | fail |

#### ES3 evaluation order tests
| Test file | What it checks | Result |
| --- | --- | --- |
| language/expressions/call/S11.2.4_A1.4_T1.js | first argument assignment visible to later arguments | pass |
| language/expressions/call/S11.2.4_A1.4_T2.js | first argument evaluated before second, triggering ReferenceError | pass |
| language/expressions/call/S11.2.4_A1.4_T3.js | arguments `x=1,y=x,x+y` evaluated left to right | pass |
| language/expressions/call/S11.2.4_A1.4_T4.js | first argument throwing prevents evaluation of second | pass |
| language/expressions/addition/S11.6.1_A2.3_T1.js | ToNumber on left operand runs before right | pass |
| language/expressions/addition/S11.6.1_A2.4_T1.js | assignments inside `+` are evaluated left to right | pass |
| language/expressions/subtraction/S11.6.2_A2.3_T1.js | ToNumber on left operand runs before right | pass |
| language/expressions/multiplication/S11.5.1_A2.3_T1.js | ToNumber on left operand runs before right | pass |
| language/expressions/division/S11.5.2_A2.3_T1.js | ToNumber on left operand runs before right | pass |
| language/expressions/modulus/S11.5.3_A2.4_T1.js | assignments inside `%` are evaluated left to right | pass |
| language/expressions/left-shift/S11.7.1_A2.3_T1.js | ToNumber on left operand runs before right | pass |
| language/expressions/right-shift/S11.7.2_A2.4_T1.js | assignments inside `>>` are evaluated left to right | pass |
| language/expressions/unsigned-right-shift/S11.7.3_A2.3_T1.js | ToNumber on left operand runs before right | pass |
| language/expressions/bitwise-xor/S11.10.2_A2.4_T1.js | assignments inside `^` are evaluated left to right | pass |
| language/expressions/less-than/S11.8.1_A2.4_T1.js | assignments inside `<` are evaluated left to right | pass |
| language/expressions/greater-than/S11.8.2_A2.3_T1.js | ToNumber left operand before right in `>` | pass |
| language/expressions/greater-than/S11.8.2_A2.4_T1.js | assignments inside `>` are evaluated left to right | pass |
| language/expressions/greater-than/11.8.2-1.js | left `valueOf` runs before right `valueOf` in `>` | pass |
| language/expressions/greater-than/11.8.2-2.js | left `valueOf` runs before right `toString` in `>` | pass |
| language/expressions/greater-than/11.8.2-3.js | left `toString` runs before right `valueOf` in `>` | pass |
| language/expressions/greater-than/11.8.2-4.js | left `toString` runs before right `toString` in `>` | pass |
| language/expressions/less-than-or-equal/11.8.3-1.js | left `valueOf` runs before right `valueOf` in `<=` | pass |
| language/expressions/less-than-or-equal/11.8.3-2.js | left `valueOf` runs before right `toString` in `<=` | pass |
| language/expressions/less-than-or-equal/11.8.3-3.js | left `toString` runs before right `valueOf` in `<=` | pass |
| language/expressions/less-than-or-equal/11.8.3-4.js | left `toString` runs before right `toString` in `<=` | pass |
| language/expressions/less-than-or-equal/11.8.3-5.js | mixed coercions still evaluate left side first in `<=` | pass |
| language/expressions/in/S11.8.7_A2.4_T1.js | assignments inside `in` are evaluated left to right | pass |
| language/expressions/strict-equals/S11.9.4_A2.4_T1.js | assignments inside `===` are evaluated left to right | pass |
| language/expressions/does-not-equals/S11.9.2_A2.4_T1.js | assignments inside `!=` are evaluated left to right | pass |

#### Non-ES3 features
| Test file | What it checks | Result |
| --- | --- | --- |
| language/expressions/exponentiation/exp-operator-evaluation-order.js | evaluation order for `**` operator (ES2016) | SyntaxError |
| language/expressions/template-literal/evaluation-order.js | evaluation order for template literals (ES2015) | SyntaxError |

These tests confirm NuXJS’s left-to-right operand evaluation for ES3 constructs, with assignment targets and property access remaining outliers.
