var chunkSize = 8;
var unicodeDataLines = read('UnicodeData-2.1.8.txt').split('\n');

function setBit(bits, index) {
	var i = Math.floor(index / 32);
	bits[i] |= (1 << (index - i * 32));
}

function testBit(bits, index) {
	var i = Math.floor(index / 32);
	return (bits[i] & (1 << (index - i * 32))) != 0;
}

function buildBitMask(includeCategories) {
	var set = { };
	for (var i = 0; i < includeCategories.length; ++i) {
		set[includeCategories[i]] = true;
	}

	var lastOrdinal = -1;
	var bits = [ ];
	for (var i = 0; i < 65536 / 32; ++i) {
		bits[i] = 0;
	}
	setBit(bits, '$'.charCodeAt(0));
	setBit(bits, '_'.charCodeAt(0));
	for (var i = 0; i < unicodeDataLines.length; ++i) {
		var cols = unicodeDataLines[i].split(';');
		var ordinal = parseInt('0x' + cols[0]);
		if (ordinal <= lastOrdinal) {
			throw new Error("Badly sorted");
		}
		lastOrdinal = ordinal;
		if (cols[2]	in set) {
			setBit(bits, ordinal);
		}
	}
	return bits;
}

function buildLookup(bits, data) {
	var offsets = [ ];
	for (var i = 0; i < bits.length; i += chunkSize) {
		var k = 0;
		for (var j = 0; j < data.length; ++j) {
			while (k < chunkSize && j + k < data.length && data[j + k] == bits[i + k]) {
				++k;
			}
			if (k == chunkSize || j + k == data.length) {
				break;
			}
			k = 0;
		}
		offsets[i / chunkSize] = j;
		for (var l = k; l < chunkSize; ++l) {
			data.push(bits[i + l]);
		}
	}

	return offsets;
}

function testLookup(data, offsets, character) {
	var i = Math.floor(character / (chunkSize * 32));
	var offset = offsets[i];
	var j = character - i * (chunkSize * 32);
	var k = Math.floor(j / 32);
	return (data[offset + k] & (1 << (j - k * 32))) != 0;
}

var data = [ ];

var leadingBits = buildBitMask([ 'Lu', 'Ll', 'Lt', 'Lm', 'Lo', 'Nl' ]);
var bits = buildBitMask([ 'Lu', 'Ll', 'Lt', 'Lm', 'Lo', 'Nl', 'Mn', 'Mc', 'Nd', 'Pc' ]);

var leadingOffsets = buildLookup(leadingBits, data);
var offsets = buildLookup(bits, data);

var maxOffset = 0;
for (var i = 0; i < offsets.length; ++i) {
	maxOffset = Math.max(maxOffset, offsets[i]);
}

print('data: '+data);
print('leadingOffsets: '+leadingOffsets);
print('offsets: '+offsets);

print(data.length + '=' + data.length * 4);
print(offsets.length + '=' + offsets.length * (maxOffset >= 256 ? 2 : 1));
print('=' + (data.length * 4 + 2 * (offsets.length * (maxOffset >= 256 ? 2 : 1))));

for (var ch = 0; ch < 65536; ++ch) {
	if (testLookup(data, offsets, ch) !== testBit(bits, ch)) {
		throw new Error("Error on " + ch);
	}
	if (testLookup(data, leadingOffsets, ch) !== testBit(leadingBits, ch)) {
		throw new Error("Error on " + ch);
	}
}

/*
print(data.length);
var s = '';
for (var i = 0; i < data.length; ++i) {
	if (s != '') {
		s += ',';
	}
	s += '0x' + (data[i] ? (data[i] >>> 0) : 0).toString(16);
}
print(s);
*/
