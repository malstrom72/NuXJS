# Numeric Parsing Spec References

This note lists ES3 sections that specify the behavior checked by tests under `tests/unconforming` and their
corresponding Test262 coverage.

- `hexLiteralOverflow.io` — ES3 §7.8.3 "Numeric Literals" specifies `HexIntegerLiteral :: 0x HexDigit HexDigit*`
	without a digit limit; `0x100000000` therefore evaluates to `4294967296`. Test262 exercises the same scenario in
	`built-ins/parseInt/S15.1.2.2_A7.2_T3.js`.
- `hugeDecimalExponent.io` — ES3 §7.8.3 defines `ExponentPart :: (e|E) [+|-]? DecimalDigits` with no size limit;
	`1e4294967296` must evaluate to `Infinity`.
- `arrayIndexTooLarge.io` — ES3 §15.4 "Array Objects" defines an array index as property name `P` with
	`ToString(ToUint32(P)) == P` and `ToUint32(P) ≠ 2^32-1`; "4294967296" is therefore not an array index. Test262
	checks this behavior in `built-ins/Array/S15.4_A1.1_T3.js`.
