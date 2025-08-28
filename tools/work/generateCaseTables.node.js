/***

	type SpecialCasing-2.1.8.txt UnicodeData-2.1.8.txt | node generateCaseTables.node.js > tables.js

***/

const readline = require("readline");

const rl = readline.createInterface({
	input: process.stdin,
});

var lowerToUpper = {};
var upperToLower = {};
var names = {};
var skipped = 0;

function exportTable(name, table) {
	var l = [];
	for (var c in table)
		if (c.length === 4) l.push(c);
		else skipped++;

	l.sort();
	console.log("var " + name + " = {");
	for (var i in l) {
		var f = decode("\\u" + l[i].toLowerCase());
		var t = decode("\\u" + table[l[i]].toLowerCase());
		console.log('\t"' + f + '":"' + t + '",' + "                         ".substr(f.length + t.length) + " // " + names[l[i]]);
	}
	console.log("};\n");
}

rl.on("line", (line) => {
	// code;name;<ignore*10>;uppercase;lowercase;<ignore>
	var m = line.match(/^([0-9a-z]{4,6});([^;]*);(?:[^;]*;){10}([0-9a-z]{4,6})?;([0-9a-z]{4,6})?;[^;]*$/i);
	if (m && m.length === 5) {
		if (names[m[1]] === undefined) names[m[1]] = m[2];
		if (m[3] && lowerToUpper[m[1]] === undefined) lowerToUpper[m[1]] = m[3];
		if (m[4] && upperToLower[m[1]] === undefined) upperToLower[m[1]] = m[4];
	} else if (line.match(/^(#.*|\S*)$/)) {
		// comment
	} else {
		m = line.match(/^([0-9A-Z]{4});\s*([ 0-9A-Z]+);[ 0-9A-Z ]+;\s*([ 0-9A-Z ]+); # (.*)$/i);
		if (m && m.length === 5) {
			names[m[1]] = m[4] + " (SpecialCase)";
			if (m[1] !== m[2]) upperToLower[m[1]] = m[2].replace(/ /g, "\\u");
			if (m[1] !== m[3]) lowerToUpper[m[1]] = m[3].replace(/ /g, "\\u");
		} else console.warn("Skipping line: " + line);
	}
}).on("close", () => {
	var a,
		bidirectional = {};
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
	exportTable("lowerToUpper", lowerToUpper);
	exportTable("upperToLower", upperToLower);
	exportTable("bidirectional", bidirectional);
	if (skipped) console.warn("Skipped " + skipped + " characters (outside range \\u0000 - \\uffff)");
	process.exit(0);
});

// output optimization of printable ASCII characters
function decode(s) {
	return s
		.replace(/\\u00/gi, "\\x")
		.replace(/\\x41/gi, "A")
		.replace(/\\x42/gi, "B")
		.replace(/\\x43/gi, "C")
		.replace(/\\x44/gi, "D")
		.replace(/\\x45/gi, "E")
		.replace(/\\x46/gi, "F")
		.replace(/\\x47/gi, "G")
		.replace(/\\x48/gi, "H")
		.replace(/\\x49/gi, "I")
		.replace(/\\x4A/gi, "J")
		.replace(/\\x4B/gi, "K")
		.replace(/\\x4C/gi, "L")
		.replace(/\\x4D/gi, "M")
		.replace(/\\x4E/gi, "N")
		.replace(/\\x4F/gi, "O")
		.replace(/\\x50/gi, "P")
		.replace(/\\x51/gi, "Q")
		.replace(/\\x52/gi, "R")
		.replace(/\\x53/gi, "S")
		.replace(/\\x54/gi, "T")
		.replace(/\\x55/gi, "U")
		.replace(/\\x56/gi, "V")
		.replace(/\\x57/gi, "W")
		.replace(/\\x58/gi, "X")
		.replace(/\\x59/gi, "Y")
		.replace(/\\x5A/gi, "Z")
		.replace(/\\x61/gi, "a")
		.replace(/\\x62/gi, "b")
		.replace(/\\x63/gi, "c")
		.replace(/\\x64/gi, "d")
		.replace(/\\x65/gi, "e")
		.replace(/\\x66/gi, "f")
		.replace(/\\x67/gi, "g")
		.replace(/\\x68/gi, "h")
		.replace(/\\x69/gi, "i")
		.replace(/\\x6A/gi, "j")
		.replace(/\\x6B/gi, "k")
		.replace(/\\x6C/gi, "l")
		.replace(/\\x6D/gi, "m")
		.replace(/\\x6E/gi, "n")
		.replace(/\\x6F/gi, "o")
		.replace(/\\x70/gi, "p")
		.replace(/\\x71/gi, "q")
		.replace(/\\x72/gi, "r")
		.replace(/\\x73/gi, "s")
		.replace(/\\x74/gi, "t")
		.replace(/\\x75/gi, "u")
		.replace(/\\x76/gi, "v")
		.replace(/\\x77/gi, "w")
		.replace(/\\x78/gi, "x")
		.replace(/\\x79/gi, "y")
		.replace(/\\x7A/gi, "z");
}
