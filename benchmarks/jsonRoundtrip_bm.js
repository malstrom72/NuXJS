if (typeof print !== "function") {
    var print = console.log;
}

function buildUserProfile() {
    return {
        id: "user-2048",
        name: "Ada Lovelace",
        roles: ["admin", "analyst", "reviewer"],
        preferences: {
            notifications: {
                email: true,
                sms: false,
                digest: "weekly"
            },
            dashboard: {
                layout: "wide",
                widgets: [
                    { key: "throughput", visible: true },
                    { key: "errors", visible: true },
                    { key: "latency", visible: false }
                ]
            }
        },
        lastLogin: "2024-02-01T09:30:00Z"
    };
}

function buildTelemetryBatch(count) {
    var events = [];
    for (var i = 0; i < count; ++i) {
        events.push({
            id: "evt-" + i,
            type: i % 3 === 0 ? "click" : (i % 3 === 1 ? "view" : "navigate"),
            success: i % 10 !== 0,
            payload: {
                path: "/dashboard/" + (i % 7),
                coords: { x: (i * 37) % 1920, y: (i * 53) % 1080 },
                timing: {
                    start: i * 3,
                    end: i * 3 + (i % 13)
                },
                metadata: {
                    cohort: "group-" + (i % 4),
                    experiment: i % 5 === 0 ? "variant" : "control",
                    tags: ["tag" + (i % 5), "tag" + (i % 7), "tag" + (i % 11)]
                }
            }
        });
    }
    return {
        batchId: "batch-telemetry-" + count,
        generatedAt: "2024-02-01T00:00:00Z",
        region: "us-east",
        events: events
    };
}

function buildDeepTree(levels, fanout) {
    function create(level) {
        if (level === levels) {
            return {
                leaf: true,
                payload: {
                    value: level,
                    label: "leaf-" + level
                }
            };
        }

        var children = [];
        for (var j = 0; j < fanout; ++j) {
            children.push(create(level + 1));
        }

        return {
            level: level,
            nodeId: "node-" + level + "-" + fanout,
            summary: {
                weight: level * 17 + fanout,
                flags: [level % 2 === 0, fanout > 2, level === 0]
            },
            children: children
        };
    }

    return { root: create(0) };
}

function buildMatrixCollection(sets, rows, cols) {
    var matrices = [];
    for (var s = 0; s < sets; ++s) {
        var matrix = [];
        for (var r = 0; r < rows; ++r) {
            var row = [];
            for (var c = 0; c < cols; ++c) {
                var value = ((r * 31 + c * 17 + s * 13) % 1000) / 1000;
                row.push(value);
            }
            matrix.push(row);
        }
        matrices.push({
            id: "matrix-" + s,
            rows: rows,
            cols: cols,
            values: matrix
        });
    }
    return {
        generatedAt: "2024-02-01T12:00:00Z",
        type: "metric-grid",
        datasets: matrices
    };
}

function computeChecksum(str) {
    var hash = 2166136261 >>> 0;
    for (var i = 0; i < str.length; ++i) {
        hash ^= str.charCodeAt(i) & 0xff;
        hash = (hash * 16777619) >>> 0;
    }
    return hash >>> 0;
}

function runRoundtrip(payload) {
    var iterations = payload.iterations;
    var current = payload.json;
    var totalLength = 0;

    for (var i = 0; i < iterations; ++i) {
        var parsed = JSON.parse(current);
        current = JSON.stringify(parsed);
        totalLength += current.length;
    }

    var checksum = computeChecksum(current);
    print(payload.name + ": iterations=" + iterations +
        " total=" + totalLength +
        " len=" + current.length +
        " checksum=" + checksum);
}

var payloads = [
    // Iteration counts scaled to keep the benchmark comfortably within NuXJS's default execution time window.
    { name: "userProfile", json: JSON.stringify(buildUserProfile()), iterations: 1000 },
    { name: "telemetryBatch", json: JSON.stringify(buildTelemetryBatch(60)), iterations: 200 },
    { name: "deepTree", json: JSON.stringify(buildDeepTree(5, 3)), iterations: 40 },
    { name: "matrixCollection", json: JSON.stringify(buildMatrixCollection(6, 12, 12)), iterations: 27 }
];

for (var i = 0; i < payloads.length; ++i) {
    runRoundtrip(payloads[i]);
}
