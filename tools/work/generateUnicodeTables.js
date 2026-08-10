/***

	Regenerates every Unicode derived table in the engine and writes it back into the sources, so that
	the case mappings, the identifier classification and the white space set always come from one and
	the same Unicode version. Run it from this directory with NuXJS itself, never with node:

		../../output/NuXJS generateUnicodeTables.js            rewrites the generated blocks in place
		../../output/NuXJS generateUnicodeTables.js --check    reports drift, changes nothing

	buildAndTest.sh runs --check, so a hand edited table or a forgotten regeneration fails the build.
	To move to another Unicode version, drop its UnicodeData and SpecialCasing files here, rename them
	after the version, change VERSION below and run without --check.

***/

var VERSION = '3.0.0';
var UNICODE_DATA = 'UnicodeData-' + VERSION + '.txt';
var SPECIAL_CASING = 'SpecialCasing-' + VERSION + '.txt';

var CPP_PATH = '../../src/NuXJS.cpp';
var JS_PATH = '../../src/stdlib.js';

// 7.6 UnicodeLetter, and the categories IdentifierPart adds on top of it.
var LEADING_CATEGORIES = [ 'Lu', 'Ll', 'Lt', 'Lm', 'Lo', 'Nl' ];
var PART_CATEGORIES = [ 'Lu', 'Ll', 'Lt', 'Lm', 'Lo', 'Nl', 'Mn', 'Mc', 'Nd', 'Pc' ];

/*
	7.2 white space that is not category Zs, plus the 7.3 line terminators, which every caller wants
	together with white space. ES5.1 adds 0xFEFF here; ES3 deliberately does not have it.
*/
var FIXED_WHITE_SPACE = [ 0x09, 0x0B, 0x0C, 0x0A, 0x0D, 0x2028, 0x2029 ];

/*
	ES5 7.2 moved the byte order mark out of the 7.1 format control set and into WhiteSpace proper.
	It is the only white space character the two editions disagree about, so both engines are emitted
	from one set rather than kept as two hand written lists.
*/
var ES5_EXTRA_WHITE_SPACE = [ 0xFEFF ];

/*
	ES5 7.6 IdentifierPart also takes <ZWNJ> and <ZWJ>, which are category Cf and so in none of the categories
	above. ES3 7.1 strips every Cf character from the source instead, so the es5 build gets its own part table.
*/
var ES5_EXTRA_IDENTIFIER_PART = [ 0x200C, 0x200D ];

var CHUNK_SIZE = 8;						// Int32s per 256 character block of the identifier bitmaps
var CPP_WRAP = 119, JS_WRAP = 576;		// generated data is exempt from the 120 column rule

var ARGUMENTS = arguments;

/* --- reading the database --- */

var dataLines = read(UNICODE_DATA).split('\n');

function eachDataLine(visit) {
	var lastOrdinal = -1;
	for (var i = 0; i < dataLines.length; ++i) {
		var cols = dataLines[i].split(';');
		if (cols.length > 13) {
			var ordinal = parseInt('0x' + cols[0]);
			if (ordinal <= lastOrdinal) {
				throw new Error('Badly sorted: ' + dataLines[i]);
			}
			/*
				Large blocks are abbreviated to a First> / Last> pair rather than listed character by
				character, so a Last> line stands for everything since the First> line just above it.
			*/
			visit(cols[1].indexOf(', Last>') > 0 ? lastOrdinal : ordinal, ordinal, cols);
			lastOrdinal = ordinal;
		}
	}
}

/* --- case tables --- */

function buildCaseTables() {
	var lowerToUpper = {}, upperToLower = {}, bidirectional = {}, a;

	var casingLines = read(SPECIAL_CASING).split('\n');
	for (var i = 0; i < casingLines.length; ++i) {
		// code; lower; title; upper; (condition)? # name  -- conditional and locale entries are skipped
		var m = casingLines[i].match(/^([0-9A-Z]{4});\s*([ 0-9A-Z]+);[ 0-9A-Z ]+;\s*([ 0-9A-Z ]+); #/i);
		if (m) {
			if (m[1] !== m[2]) upperToLower[m[1]] = m[2].replace(/ /g, '\\u');
			if (m[1] !== m[3]) lowerToUpper[m[1]] = m[3].replace(/ /g, '\\u');
		}
	}

	eachDataLine(function (from, ordinal, cols) {
		if (from === ordinal) {			// abbreviated blocks are caseless, so only single entries matter
			if (cols[12] && lowerToUpper[cols[0]] === undefined) lowerToUpper[cols[0]] = cols[12];
			if (cols[13] && upperToLower[cols[0]] === undefined) upperToLower[cols[0]] = cols[13];
		}
	});

	// Characters that round trip go into one shared table, halving what the other two have to hold.
	for (a in upperToLower) {
		if (upperToLower[a] && lowerToUpper[upperToLower[a]] === a) {
			bidirectional[a] = upperToLower[a];
			delete lowerToUpper[upperToLower[a]];
			delete upperToLower[a];
		}
	}
	for (a in lowerToUpper) {
		if (lowerToUpper[a] && upperToLower[lowerToUpper[a]] === a) {
			bidirectional[upperToLower[a]] = a;
			delete upperToLower[lowerToUpper[a]];
			delete lowerToUpper[a];
		}
	}
	return { lowerToUpper: lowerToUpper, upperToLower: upperToLower, bidirectional: bidirectional };
}

var ASCII_LETTERS = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';

// Spells a code point as it should appear inside a JavaScript string literal, shortest form first.
function jsEscape(hex) {
	var code = parseInt('0x' + hex);
	if (ASCII_LETTERS.indexOf(String.fromCharCode(code)) >= 0) return String.fromCharCode(code);
	var digits = hex.toLowerCase();
	while (digits.length < 4) digits = '0' + digits;
	return (code < 0x100 ? '\\x' + digits.substr(2) : '\\u' + digits);
}

function jsEscapeAll(hexes) {
	var parts = hexes.split('\\u'), s = '';
	for (var i = 0; i < parts.length; ++i) if (parts[i] !== '') s += jsEscape(parts[i]);
	return s;
}

function emitJSTable(declaration, table) {
	var codes = [], c;
	for (c in table) if (c.length === 4) codes.push(c);
	codes.sort();

	var out = ['\t' + declaration + ' {'], line = '', count = 0, form = 0;
	for (var i = 0; i < codes.length; ++i) {
		var f = jsEscape(codes[i]), t = jsEscapeAll(table[codes[i]]);
		var entry = (f.length === 1 ? "'" + f + "'" : '"' + f + '"') + ':"' + t + '"'
				+ (i + 1 < codes.length ? ',' : '');
		// Wrap on width, and where the keys change escape form, so that the character blocks line up.
		if (line.length + entry.length > JS_WRAP || (f.length !== form && count >= 2)) {
			out.push('\t\t' + line);
			line = '';
			count = 0;
		}
		line += entry;
		++count;
		form = f.length;
	}
	out.push('\t\t' + line, '\t};');
	return out.join('\n');
}

/* --- identifier bitmaps --- */

function setBit(bits, index) {
	var i = Math.floor(index / 32);
	bits[i] |= (1 << (index - i * 32));
}

function testBit(bits, index) {
	var i = Math.floor(index / 32);
	return (bits[i] & (1 << (index - i * 32))) != 0;
}

function buildBitMask(categories, extras) {
	var set = {}, bits = [], i;
	for (i = 0; i < categories.length; ++i) set[categories[i]] = true;
	for (i = 0; i < 65536 / 32; ++i) bits[i] = 0;
	setBit(bits, '$'.charCodeAt(0));
	setBit(bits, '_'.charCodeAt(0));
	for (i = 0; i < extras.length; ++i) setBit(bits, extras[i]);
	eachDataLine(function (from, ordinal, cols) {
		if (cols[2] in set) for (var c = from; c <= ordinal; ++c) setBit(bits, c);
	});
	return bits;
}

// Blocks of 256 characters that share a bit pattern share one chunk of the mask array.
function buildLookup(bits, data) {
	var offsets = [];
	for (var i = 0; i < bits.length; i += CHUNK_SIZE) {
		var k = 0;
		for (var j = 0; j < data.length; ++j) {
			while (k < CHUNK_SIZE && j + k < data.length && data[j + k] == bits[i + k]) ++k;
			if (k == CHUNK_SIZE || j + k == data.length) break;
			k = 0;
		}
		offsets[i / CHUNK_SIZE] = j;
		for (var l = k; l < CHUNK_SIZE; ++l) data.push(bits[i + l]);
	}
	return offsets;
}

function testLookup(data, offsets, character) {
	var i = Math.floor(character / (CHUNK_SIZE * 32));
	var j = character - i * (CHUNK_SIZE * 32);
	var k = Math.floor(j / 32);
	return (data[offsets[i] + k] & (1 << (j - k * 32))) != 0;
}

// Wrapped lines for one range of a table. A trailing comma everywhere is what lets a range stand on its own.
function tableLines(values, from, to) {
	var lines = [], line = '';
	for (var i = from; i < to; ++i) {
		// INT32_MIN has no literal form in C++, so it is spelled as an expression.
		var piece = (values[i] === -2147483648 ? '-2147483647-1' : '' + values[i]) + ',';
		if (line !== '' && 1 + line.length + piece.length > CPP_WRAP) {
			lines.push('\t' + line);
			line = '';
		}
		line += piece;
	}
	if (line !== '') {
		lines.push('\t' + line);
	}
	return lines;
}

/*
	`es5Values` is the same table as the es5 build wants it. The two agree almost everywhere, so only the runs
	that differ go under a guard and the rest is emitted once.
*/
function emitCppTable(declaration, values, es5Values) {
	var es5 = (es5Values === undefined ? values : es5Values);
	var n = Math.max(values.length, es5.length), out = [declaration.replace('$N', values.length) + ' = {'], i = 0;
	while (i < n) {
		var j = i, same = (values[i] === es5[i]);
		while (j < n && (values[j] === es5[j]) === same) ++j;
		if (same) {
			out = out.concat(tableLines(values, i, j));
		} else {
			out = out.concat(['#if NUXJS_ES5'], tableLines(es5, i, Math.min(j, es5.length)));
			if (i < values.length) {
				out = out.concat(['#else'], tableLines(values, i, Math.min(j, values.length)));
			}
			out.push('#endif');
		}
		i = j;
	}
	out.push('};');
	return out.join('\n');
}

/* --- white space --- */

function buildWhiteSpace() {
	var codes = [], seen = {}, i;
	for (i = 0; i < FIXED_WHITE_SPACE.length; ++i) seen[FIXED_WHITE_SPACE[i]] = true;
	eachDataLine(function (from, ordinal, cols) {
		if (cols[2] === 'Zs') for (var c = from; c <= ordinal; ++c) seen[c] = true;
	});
	for (i = 0; i <= 0xFFFF; ++i) if (seen[i]) codes.push(i);
	return codes;
}

var NAMED = { 0x09: 't', 0x0A: 'n', 0x0B: 'v', 0x0C: 'f', 0x0D: 'r' };

// The set is small and read by humans, so it is spelled the way one would write it by hand.
function charLiteral(code, quote) {
	if (NAMED[code] !== undefined) return '\\' + NAMED[code];
	if (code >= 0x20 && code < 0x7F) return (String.fromCharCode(code) === quote ? '\\' : '') + String.fromCharCode(code);
	var digits = code.toString(16);
	while (digits.length < (code < 0x100 ? 2 : 4)) digits = '0' + digits;
	return (code < 0x100 ? '\\x' : '\\u') + digits;
}

function emitCppWhiteSpace(codes) {
	var labels = [], i;
	for (i = 0; i < codes.length; ++i) {
		var code = codes[i];
		labels.push('case ' + (code < 0x80 ? "'" + charLiteral(code, "'") + "'"
				: '0x' + code.toString(16).toUpperCase()) + ':');
	}
	var out = ['/*', '\tWhiteSpace of 7.2 plus LineTerminator of 7.3, which every caller here wants together.'
			, '\t<USP> is category Zs of Unicode ' + VERSION + ', so U+200B counts and U+180E does not, unlike in'
			, '\tlater Unicode versions.', '*/', 'static bool isWhiteSpace(Char c) {', '\tswitch (c) {'];
	var line = '';
	for (i = 0; i < labels.length; ++i) {
		if (line !== '' && 2 + line.length + 1 + labels[i].length > CPP_WRAP) {
			out.push('\t\t' + line);
			line = '';
		}
		line += (line === '' ? '' : ' ') + labels[i];
	}
	out.push('\t\t' + line);
	out.push('#if NUXJS_ES5');
	line = '';
	for (i = 0; i < ES5_EXTRA_WHITE_SPACE.length; ++i) {
		line += (line === '' ? '' : ' ') + 'case 0x' + ES5_EXTRA_WHITE_SPACE[i].toString(16).toUpperCase() + ':';
	}
	out.push('\t\t' + line, '#endif', '\t\t\treturn true;', '\t\tdefault: return false;', '\t}', '}');
	return out.join('\n');
}

function whiteSpaceLiteral(codes) {
	var s = '';
	for (var i = 0; i < codes.length; ++i) s += charLiteral(codes[i], '"');
	return '\t\t, WHITE_SPACES = "' + s + '";';
}

function emitJSWhiteSpace(codes) {
	var both = codes.concat(ES5_EXTRA_WHITE_SPACE);
	both.sort(function (a, b) { return a - b });
	return ['\t\t// 7.2 WhiteSpace and 7.3 LineTerminator, <USP> being Zs of Unicode ' + VERSION + '.'
			, '//#if !ES5', whiteSpaceLiteral(codes), '//#else', whiteSpaceLiteral(both), '//#endif'].join('\n');
}

/* --- splicing --- */

// Replaces everything between the two markers, which stay put, so the anchors survive regeneration.
function splice(source, name, replacement, path) {
	var begin = source.indexOf('generated: ' + name);
	if (begin < 0) throw new Error('No "generated: ' + name + '" marker in ' + path);
	begin = source.indexOf('\n', begin) + 1;
	var end = source.indexOf('end generated: ' + name, begin);
	if (end < 0) throw new Error('No "end generated: ' + name + '" marker in ' + path);
	end = source.lastIndexOf('\n', end) + 1;
	return source.substring(0, begin) + replacement + '\n' + source.substring(end);
}

/* --- main --- */

var caseTables = buildCaseTables();
var data = [];
var leadingBits = buildBitMask(LEADING_CATEGORIES, []);
var partBits = buildBitMask(PART_CATEGORIES, []);
var partES5Bits = buildBitMask(PART_CATEGORIES, ES5_EXTRA_IDENTIFIER_PART);
var leadingOffsets = buildLookup(leadingBits, data);
var partOffsets = buildLookup(partBits, data);
// buildLookup only ever appends, so taking the es5 table last leaves the es3 mask array a prefix of this one.
var es3MaskCount = data.length;
var partES5Offsets = buildLookup(partES5Bits, data);
var whiteSpace = buildWhiteSpace();

for (var ch = 0; ch < 65536; ++ch) {
	if (testLookup(data, partOffsets, ch) !== testBit(partBits, ch)
			|| testLookup(data, leadingOffsets, ch) !== testBit(leadingBits, ch)
			|| testLookup(data, partES5Offsets, ch) !== testBit(partES5Bits, ch)) {
		throw new Error('Identifier lookup disagrees with the bitmap at ' + ch);
	}
}

var cppBlock = emitCppTable('const Int32 UNICODE_MASKS[]', data.slice(0, es3MaskCount), data) + '\n\n'
		+ emitCppTable('const UInt16 IDENTIFIER_START_OFFSETS[$N]', leadingOffsets) + '\n\n'
		+ emitCppTable('const UInt16 IDENTIFIER_PART_OFFSETS[$N]', partOffsets, partES5Offsets) + '\n\n'
		+ emitCppWhiteSpace(whiteSpace);

var jsBlock = emitJSTable('lowerToUpper =', caseTables.lowerToUpper) + '\n'
		+ emitJSTable('upperToLower =', caseTables.upperToLower) + '\n'
		+ emitJSTable('var c, BIDIRECTIONAL =', caseTables.bidirectional);

var cppSource = read(CPP_PATH), jsSource = read(JS_PATH);
var newCpp = splice(cppSource, 'unicode tables', cppBlock, CPP_PATH);
var newJS = splice(splice(jsSource, 'case tables', jsBlock, JS_PATH)
		, 'white space', emitJSWhiteSpace(whiteSpace), JS_PATH);

var checking = (ARGUMENTS.length > 1 && ARGUMENTS[1] === '--check');
var stale = [];
if (newCpp !== cppSource) stale.push(CPP_PATH);
if (newJS !== jsSource) stale.push(JS_PATH);

if (checking) {
	if (stale.length > 0) {
		print('Unicode tables are stale in ' + stale.join(' and ')
				+ '. Run tools/work/generateUnicodeTables.js to regenerate them.');
		throw new Error('stale Unicode tables');
	}
	print('Unicode tables are up to date with Unicode ' + VERSION + '.');
} else if (stale.length === 0) {
	print('Unicode tables already up to date with Unicode ' + VERSION + '.');
} else {
	write(CPP_PATH, newCpp);
	write(JS_PATH, newJS);
	print('Wrote Unicode ' + VERSION + ' tables to ' + stale.join(' and ') + '.');
}
