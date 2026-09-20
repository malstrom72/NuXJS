// 15.9.1.15 gives the extended year a six-digit signed form, and 15.9.1.1 puts year zero inside the Date range, so
// +000000 is an ordinary instant and not a marker for "absent". The parser used to read the *value* zero as absent
// and go back for four digits from the middle of the string, so it answered NaN for a year the four-digit spelling
// of the same instant parsed fine. Which of the two spellings is in the format at all is asserted in
// tests/es5/dateParseRejectsInvalid.io; this file pins the instants. Every string ends in Z, so the machine's zone
// cannot reach these results.
> print(Date.parse("+000000-01-01T00:00:00.000Z") + " " + Date.parse("0000-01-01T00:00:00.000Z"))
< -62167219200000 -62167219200000
> print(Date.parse("+000000-06-15T12:00:00Z"))
< -62152833600000
-
// It round-trips through the formatter, which prints the four-digit spelling back.
> print(new Date(Date.parse("+000000-01-01T00:00:00.000Z")).toISOString())
< 0000-01-01T00:00:00.000Z
-
// A non-zero signed year was never affected, and neither sign loses its meaning at the boundary.
> print(Date.parse("+000001-01-01T00:00:00Z") + " " + Date.parse("-000001-01-01T00:00:00Z"))
< -62135596800000 -62198755200000
-
