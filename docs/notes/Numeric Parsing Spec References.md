# Numeric Parsing Spec References

This note lists ES3 sections that specify the behavior checked by tests under `tests/unconforming`.

- `hexLiteralOverflow.io` — ES3 §7.8.3 "Numeric Literals" specifies `HexIntegerLiteral :: 0x HexDigit HexDigit*`
	without a digit limit; `0x100000000` therefore evaluates to `4294967296`.
- `hugeDecimalExponent.io` — ES3 §7.8.3 defines `ExponentPart :: (e|E) [+|-]? DecimalDigits` with no size limit;
	`1e4294967296` must evaluate to `Infinity`.
- `arrayIndexTooLarge.io` — ES3 §15.4 "Array Objects" defines an array index as property name `P` with
	`ToString(ToUint32(P)) == P` and `ToUint32(P) ≠ 2^32-1`; "4294967296" is therefore not an array index.
