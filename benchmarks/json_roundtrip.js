if (typeof print !== "function") {
	var print = function(value) {
		console.log(value);
	};
}

function mix(hash, value) {
	hash ^= value;
	hash = (hash * 16777619) | 0;
	return hash;
}

function hashString(str) {
	var h = 0;
	for (var i = 0; i < str.length; ++i) {
		h = (h * 33 + str.charCodeAt(i)) | 0;
	}
	return h;
}

function checksum(value) {
	if (value === null) {
		return 0x9e3779b9 | 0;
	}

	var type = typeof value;
	if (type === "number") {
		if (value !== value) {
			return 0x7fc00000 | 0;
		}
		var scaled = Math.floor(value * 1000000);
		return (scaled ^ (scaled >>> 16)) | 0;
	}
	if (type === "string") {
		return hashString(value);
	}
	if (type === "boolean") {
		return value ? 0x51f15f : 0x1a1a1a;
	}
	if (type === "object") {
		var result = 0x811c9dc5;
		if (Array.isArray(value)) {
			for (var i = 0; i < value.length; ++i) {
				result = mix(result, checksum(value[i]));
			}
			return result;
		}

		var keys = Object.keys(value);
		keys.sort();
		for (var j = 0; j < keys.length; ++j) {
			var key = keys[j];
			result = mix(result, hashString(key));
			result = mix(result, checksum(value[key]));
		}
		return result;
	}
	return 0x27d4eb2d;
}

function makeDeepChain(depth) {
	var node = {
		level: depth,
		label: "depth-" + depth,
		values: [depth, depth * depth, depth + 0.5]
	};
	if (depth === 0) {
		node.terminal = true;
		return node;
	}
	node.child = makeDeepChain(depth - 1);
	return node;
}

var textBlock = "The quick brown fox jumps over the lazy dog multiple times to generate diverse text data for the benchmark. " +
"This paragraph also includes numbers like 12345 and 67890, along with punctuation!";
var textTokens = textBlock.split(" ");

function makeNested(level) {
	var node = {
		id: level,
		title: "Node-" + level,
		flags: {
			primary: (level & 1) === 0,
			archived: (level % 3) === 0
		},
		values: []
	};
	for (var i = 0; i < 3; ++i) {
		if (level === 0) {
			node.values.push({
					index: i,
					label: "Leaf-" + i,
					weights: [i, i + 0.5, i + 1.5],
					text: textTokens.slice(0, (i % textTokens.length) + 3).join(" ")
				});
		} else {
			node.values.push(makeNested(level - 1));
		}
	}
	return node;
}

function createLargeCollection(count) {
	var list = [];
	for (var i = 0; i < count; ++i) {
		list.push({
				id: i,
				name: "Record " + i,
				active: (i & 1) === 0,
				values: [i, i * 1.5, (i % 5) / 3, Math.sin(i / 5)],
				tags: textTokens.slice(0, (i % textTokens.length) + 1),
				metrics: {
					min: i,
					max: i * 100,
					avg: (i * 100 + 50) / 3,
					offset: i - 7
				},
				nested: {
					path: makeDeepChain(3),
					index: i % 10
				}
			});
	}
	return {
		collection: list,
		summary: {
			count: count,
			description: textBlock,
			timestamp: "2024-05-01T12:00:00Z"
		}
	};
}

var smallDocument = {
	header: {
		id: 101,
		version: 3,
		title: "Telemetry Packet",
		source: "sensor-array",
		flags: { validated: true, acknowledged: false }
	},
	data: {
		sequence: [1, 3, 5, 7, 9],
		ratio: 0.123456,
		metadata: {
			description: textTokens.slice(0, 12).join(" "),
			priority: "high",
			created: "2024-05-12T08:15:30Z"
		}
	},
	nested: makeDeepChain(8)
};

var nestedDocument = makeNested(3);
var largeCollection = createLargeCollection(120);

var payloads = [
	{ name: "flat-small", data: smallDocument, iterations: 6000 },
	{ name: "nested-tree", data: nestedDocument, iterations: 300 },
	{ name: "large-collection", data: largeCollection, iterations: 60 }
];

function runBenchmark(entry) {
	var json = JSON.stringify(entry.data);
	var total = 0x811c9dc5;
	for (var i = 0; i < entry.iterations; ++i) {
		var parsed = JSON.parse(json);
		total = mix(total, checksum(parsed));
		json = JSON.stringify(parsed);
	}
	print(entry.name + ": length=" + json.length + " checksum=" + (total >>> 0));
}

for (var i = 0; i < payloads.length; ++i) {
	runBenchmark(payloads[i]);
}
