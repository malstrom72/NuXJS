var db = read('UnicodeData-2.1.8.txt');
var lines = db.split('\n');

var include = [ 'Lu', 'Ll', 'Lt', 'Lm', 'Lo', 'Nl' ];
var set = { };
for (var i = 0; i < include.length; ++i) set[include[i]] = true;

var lastOrdinal = -1;
var ranges = [ ];
var currentRange = null;
for (var i = 0; i < lines.length; ++i) {
	var cols = lines[i].split(';');
	var ordinal = parseInt('0x' + cols[0]);
	if (ordinal <= lastOrdinal) {
		throw new Error("Badly sorted");
	}
	lastOrdinal = ordinal;
	if (cols[2]	in set) {
		print(lines[i]);
		if (!currentRange) {
			currentRange = { start: ordinal, end: ordinal }
		} else if (ordinal == currentRange.end + 1) {
			currentRange.end = ordinal;
		} else {
			ranges.push(currentRange);
			currentRange = { start: ordinal, end: ordinal }
		}
	}
}

if (currentRange) {
	ranges.push(currentRange);
}
for (var i = 0; i < ranges.length; ++i) {
	print(ranges[i].start.toString(16) + "->" + ranges[i].end.toString(16));
}

