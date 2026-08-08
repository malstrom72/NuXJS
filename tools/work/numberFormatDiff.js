/*
	Differential test for Number.prototype.toFixed / toExponential / toPrecision, which round on the exact decimal
	expansion built in src/stdlib.js. Reruns that expansion here and compares against the built-ins over generated
	doubles, both spread over the exponent range and built as m * 2^-k so the cut lands on a true half-way tie.

	W is digits packed per array element. This runs under NuXJS, so the built-in it compares against IS
	src/stdlib.js: at the shipped width both sides are the same algorithm and a pass proves little. W=1 is the
	signal, being a different computation of the same number. Run it.

	Usage: NuXJS -s tools/work/numberFormatDiff.js [values-per-width] [W ...]
*/
var POW10 = [1, 10, 100, 1e3, 1e4, 1e5, 1e6, 1e7, 1e8];
var TWO53 = 9007199254740991;

// Largest k with B * base^k under 2^53, i.e. the most one pass can absorb and stay exact.
function capFor(B, base) {
	var k = 0, f = 1;
	while (f * base * B <= TWO53) { f *= base; ++k; }
	return k;
}

var CAP5 = [], CAP2 = [];
for (var w = 1; w <= 8; ++w) { CAP5[w] = capFor(POW10[w], 5); CAP2[w] = capFor(POW10[w], 2); }

function carryDigits(digits, factor, carry, from, B) {
	for (var d, i = from, n = digits.length; i < n || carry; ++i) {
		digits[i] = d = (carry += (i < n ? digits[i] : 0) * factor) % B;
		carry = (carry - d) / B;
	}
}

function exactDigits(val, W) {
	var B = POW10[W], shift = 0, i, digit, base, cap, digits = [];
	for (; val % 1; --shift) val *= 2;
	for (; val > TWO53; ++shift) val /= 2;
	for (i = 0; val; val = (val - digit) / B) digits[i++] = digit = val % B;
	base = (shift < 0 ? 5 : 2);
	cap = (shift < 0 ? CAP5[W] : CAP2[W]);
	for (i = Math.abs(shift); i > cap; i -= cap) carryDigits(digits, Math.pow(base, cap), 0, 0, B);
	if (i > 0) carryDigits(digits, Math.pow(base, i), 0, 0, B);
	digits.fraction = (shift < 0 ? -shift : 0);
	return digits;
}

function leftPad(s, l) { var n = (s = "00000000000000000000" + s).length; return s.substring(n - l, n); }

function digitCount(e, W) { return (e.length ? (e.length - 1) * W + ('' + e[e.length - 1]).length : 0); }

function digitString(digits, place, W) {
	var B = POW10[W], from = (place > 0 ? place : 0), s = '', i, n, v;
	var li = Math.floor(from / W), off = from % W, pi = Math.floor((from - 1) / W);
	if (from > 0 && Math.floor(digits[pi] / POW10[(from - 1) % W]) % 10 >= 5) {
		carryDigits(digits, 1, POW10[off], li, B);
	}
	if (li < (n = digits.length)) {		// read after the bump, which can have grown the array
		for (i = n; --i > li; ) s += (i === n - 1 ? '' + digits[i] : leftPad('' + digits[i], W));
		v = Math.floor(digits[li] / POW10[off]);
		s += (li === n - 1 ? '' + v : leftPad('' + v, W - off));
	}
	while (place++ < 0) s += '0';
	return s;
}

function placePoint(s, exponent) {
	return (exponent < 0 ? '0.' + leftPad('', -exponent - 1) + s
			: exponent + 1 >= s.length ? s
			: s.substring(0, exponent + 1) + '.' + s.substring(exponent + 1, s.length));
}

function myToFixed(val, f, W) {
	var sign = '', s, e;
	if (val !== val || val <= -1e21 || val >= 1e21) return '' + val;
	if (val < 0) { val = -val; sign = '-'; }
	s = (val >= 5e-21 ? digitString(e = exactDigits(val, W), e.fraction - f, W) : leftPad('', f)) || '0';
	return sign + placePoint(s, s.length - 1 - f);
}

function numberToString(num, d, eNotationBelow, W) {
	var sign = '', e, n, exponent, s;
	if (num < 0) { num = -num; sign = '-'; }
	n = digitCount(e = exactDigits(num, W), W);
	exponent = (n ? n - 1 - e.fraction : 0);
	s = digitString(e, n - d - 1, W);
	if (s.length > d + 1) { s = s.substring(0, d + 1); ++exponent; }
	if (exponent >= eNotationBelow && exponent <= d) return sign + placePoint(s, exponent);
	return sign + placePoint(s, 0) + (exponent >= 0 ? 'e+' : 'e') + exponent;
}

function myToExponential(val, d, W) { return (isFinite(val) ? numberToString(val, d, Infinity, W) : '' + val); }
function myToPrecision(val, p, W) { return (isFinite(val) ? numberToString(val, p - 1, -6, W) : '' + val); }

function randomDouble() {
	var v;
	do { v = Math.random() * TWO53 * Math.pow(2, rnd(2098) - 1074); } while (!isFinite(v) || v === 0);
	return (Math.random() < 0.5 ? -v : v);
}

// m odd, so the exact expansion ends in a 5 at fraction digit k: cutting at k-1 is a true tie.
function tieDouble(k) {
	var v = (2 * rnd(2097151) + 1) * Math.pow(2, -k);
	return (Math.random() < 0.5 ? -v : v);
}

var CORPUS = [
	0, 1, -1, 0.1, 0.35, 0.5, 1.5, 2.5, 8.5, 9.5, 9.99, 9.995, 0.000001, 1e-7, 5e-21, 1e-21, 1e20, 1e21,
	1.7976931348623157e308, 5e-324, 2.2250738585072014e-308, 4.35, 1.005, 1234.5678, 123456789012345678901,
	0.30000000000000004, 1 / 3, 2 / 3, 1e-100, 1e-300, 900719925474099.1,
	99999999.5, 9.999999999999998, 0.9999999999999999, 1e8, 1e8 - 0.5, 12345678.87654321
];

var failures = 0;

function compare(val, method, arg, got, want) {
	if (got !== want && ++failures <= 10) {
		print("  MISMATCH (" + val + ")." + method + "(" + arg + "): got " + got + " want " + want);
	}
}

function clamp(v, lo, hi) { return (v < lo ? lo : v > hi ? hi : v); }

function checkValue(val, f, d, p, W) {
	compare(val, "toFixed", f, myToFixed(val, f, W), val.toFixed(f));
	compare(val, "toExponential", d, myToExponential(val, d, W), val.toExponential(d));
	compare(val, "toPrecision", p, myToPrecision(val, p, W), val.toPrecision(p));
}

function rnd(n) { return Math.floor(Math.random() * n); }

var COUNT = (arguments.length > 1 ? +arguments[1] : 20000);
var WIDTHS = [];
for (var i = 2; i < arguments.length; ++i) WIDTHS.push(+arguments[i]);
if (!WIDTHS.length) WIDTHS = [1, 8];

for (var wi = 0; wi < WIDTHS.length; ++wi) {
	var W = WIDTHS[wi], total = 0, n, t, val, k, dc;
	var before = failures;

	for (n = 0; n < CORPUS.length; ++n) {
		for (var a = 0; a <= 20; ++a) checkValue(CORPUS[n], a, a, a + 1, W);
		total += 21 * 3;
	}
	for (n = 0; n < COUNT; ++n) {
		checkValue(randomDouble(), rnd(21), rnd(21), 1 + rnd(21), W);
		total += 3;
	}
	// Aim the cut at the terminating 5, then one digit past it for the neighbouring non-tie.
	for (n = 0; n < COUNT; ++n) {
		val = tieDouble(k = 1 + rnd(20));
		dc = digitCount(exactDigits(val < 0 ? -val : val, 1), 1);
		for (t = 0; t < 2; ++t) {
			checkValue(val, clamp(k - 1 + t, 0, 20), clamp(dc - 2 + t, 0, 20), clamp(dc - 1 + t, 1, 21), W);
		}
		total += 6;
	}

	print("W=" + W + "  " + (total - (failures - before)) + "/" + total + " match"
			+ (failures > before ? "   *** " + (failures - before) + " MISMATCHES ***" : "   ok"));
}

print(failures === 0 ? "PASS" : "FAIL (" + failures + " mismatches)");
