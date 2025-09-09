# Numeric Parsing Spec References

This note lists ES3 sections that specify the behavior checked by tests under `tests/unconforming` and their
corresponding Test262 coverage.

- `arrayIndexTooLarge.io` — ES3 §15.4 "Array Objects" defines an array index as property name `P` with
`ToString(ToUint32(P)) == P` and `ToUint32(P) ≠ 2^32-1`; "4294967296" is therefore not an array index. Test262
checks this behavior in `built-ins/Array/S15.4_A1.1_T3.js`.
