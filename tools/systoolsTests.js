/*
	systoolsTests.js

	A port of PikaScript's systoolsTests.pika to NuXJS. Exercises systools.js (UNIX branch).

	Run it with the NuXJS command-line tool, e.g. from the repository root:
		output/NuXJS tools/systoolsTests.js

	The number of scratch files (and how many are created slowly, to test time-ordering) can be overridden
	with the environment variables SYSTOOLS_TEST_FILES and SYSTOOLS_SLOW_FILES (defaults 500 and 5, matching
	the original). The slow files add a 2-second delay each, so lower them for a quick run.
*/

// Locate and load systools.js next to this script (works regardless of the current directory).
var SCRIPT_PATH = (typeof arguments !== "undefined" && arguments.length > 0) ? arguments[0] : "";
var SCRIPT_DIR = SCRIPT_PATH.substring(0, Math.max(SCRIPT_PATH.lastIndexOf("/"), SCRIPT_PATH.lastIndexOf("\\")) + 1);
load(SCRIPT_DIR + "systools.js");

function assert(cond, msg) {
	if (!cond) throw "Assertion failed" + (msg !== undefined ? ": " + msg : "");
}

function padHex(n, width) {
	var s = (n >>> 0).toString(16);
	while (s.length < width) s = "0" + s;
	return s;
}

function repeatStr(c, n) {
	var s = "";
	while (n > 0) {
		if (n & 1) s += c;
		c += c;
		n >>= 1;
	}
	return s;
}

function expectThrow(fn, msg) {
	var threw = false;
	try { fn(); } catch (x) { threw = true; }
	assert(threw, msg);
}

function setKey(s) { return "#" + s; }

(function () {
	var SLOW_FILE_COUNT = +(getenv("SYSTOOLS_SLOW_FILES") !== undefined ? getenv("SYSTOOLS_SLOW_FILES") : "5");
	var TEST_FILE_COUNT = +(getenv("SYSTOOLS_TEST_FILES") !== undefined ? getenv("SYSTOOLS_TEST_FILES") : "500");

	print("Current working dir: " + currentDir());

	// ---- path helpers (PikaScript's void is the empty string; here absent components are "") ----
	assert(appendDirSlash("abcd" + DIR_SLASH) === "abcd" + DIR_SLASH);
	assert(appendDirSlash("abcd") === "abcd/");

	assert(dirOfPath("abcd") === "");
	assert(dirOfPath("abcd.efg") === "");
	assert(dirOfPath("hijk/") === "hijk/");
	assert(dirOfPath("hijk" + DIR_SLASH + "abcd") === "hijk" + DIR_SLASH);
	assert(dirOfPath("hijk/abcd") === "hijk/");
	assert(dirOfPath("hijk/abcd.efg") === "hijk/");
	assert(dirOfPath("hijk.lmn/abcd") === "hijk.lmn/");
	assert(dirOfPath("hijk.lmn/abcd.efg") === "hijk.lmn/");
	assert(dirOfPath("hijk.lmn/abcd.efg.xyz") === "hijk.lmn/");

	assert(filenameOfPath("abcd") === "abcd");
	assert(filenameOfPath("abcd.efg") === "abcd.efg");
	assert(filenameOfPath("hijk/") === "");
	assert(filenameOfPath("hijk" + DIR_SLASH + "abcd") === "abcd");
	assert(filenameOfPath("hijk/abcd") === "abcd");
	assert(filenameOfPath("hijk/abcd.efg") === "abcd.efg");
	assert(filenameOfPath("hijk.lmn/abcd") === "abcd");
	assert(filenameOfPath("hijk.lmn/abcd.efg") === "abcd.efg");
	assert(filenameOfPath("hijk.lmn/abcd.efg.xyz") === "abcd.efg.xyz");

	assert(basenameOfPath("abcd") === "abcd");
	assert(basenameOfPath("abcd.efg") === "abcd");
	assert(basenameOfPath("hijk/") === "");
	assert(basenameOfPath("hijk" + DIR_SLASH + "abcd") === "abcd");
	assert(basenameOfPath("hijk/abcd") === "abcd");
	assert(basenameOfPath("hijk/abcd.efg") === "abcd");
	assert(basenameOfPath("hijk.lmn/abcd") === "abcd");
	assert(basenameOfPath("hijk.lmn/abcd.efg") === "abcd");
	assert(basenameOfPath("hijk.lmn/abcd.efg.xyz") === "abcd.efg");

	assert(extensionOfPath("abcd") === "");
	assert(extensionOfPath("abcd.efg") === ".efg");
	assert(extensionOfPath("hijk/") === "");
	assert(extensionOfPath("hijk" + DIR_SLASH + "abcd") === "");
	assert(extensionOfPath("hijk/abcd") === "");
	assert(extensionOfPath("hijk/abcd.efg") === ".efg");
	assert(extensionOfPath("hijk.lmn/abcd") === "");
	assert(extensionOfPath("hijk.lmn/abcd.efg") === ".efg");
	assert(extensionOfPath("hijk.lmn/abcd.efg.xyz") === ".xyz");

	function checkSplit(full, d, n, e) {
		var r = splitPath(full);
		return r.dir === d && r.name === n && r.ext === e;
	}
	assert(checkSplit("abcd", "", "abcd", ""));
	assert(checkSplit("abcd.efg", "", "abcd", ".efg"));
	assert(checkSplit("hijk/", "hijk/", "", ""));
	assert(checkSplit("hijk" + DIR_SLASH + "abcd", "hijk" + DIR_SLASH, "abcd", ""));
	assert(checkSplit("hijk/abcd", "hijk/", "abcd", ""));
	assert(checkSplit("hijk/abcd.efg", "hijk/", "abcd", ".efg"));
	assert(checkSplit("hijk.lmn/abcd", "hijk.lmn/", "abcd", ""));
	assert(checkSplit("hijk.lmn/abcd.efg", "hijk.lmn/", "abcd", ".efg"));
	assert(checkSplit("hijk.lmn/abcd.efg.xyz", "hijk.lmn/", "abcd.efg", ".xyz"));
	assert(checkSplit("hij?k.lmn/ab*cd.efg.xyz", "hij?k.lmn/", "ab*cd.efg", ".xyz"));

	if (PLATFORM === "UNIX") {
		assert(dirOfPath("hijk\\.lmn/abcd") === "hijk\\.lmn/");
		assert(basenameOfPath("hijk.lmn/abc:d.efg") === "abc:d");
		assert(extensionOfPath("hijk.lmn/abcd.efg.xy\\z") === ".xy\\z");
		assert(checkSplit("hi:j?k.lmn/ab*cd.ef\\g.xyz", "hi:j?k.lmn/", "ab*cd.ef\\g", ".xyz"));
	}

	// ---- timing ----
	var t = time();
	print("2 seconds delay");
	sleep(2);
	assert(time() > t && time() < t + 5);

	// ---- directory / file operations ----
	var testDir = TEMP_DIR + "systools test " + time() + "/";
	if (!pathExists(testDir)) makeDir(testDir);
	assert(pathExists(testDir));
	expectThrow(function () { makeDir(testDir); }, "expected makeDir to fail");

	makeDir(testDir + "oneDeep");
	makeDir(testDir + "oneDeep/twoDeep");
	assert(pathExists(testDir + "oneDeep/twoDeep"));
	removeDir(testDir + "oneDeep/twoDeep");
	assert(!pathExists(testDir + "oneDeep/twoDeep"));
	assert(pathExists(testDir + "oneDeep"));
	makeDir(testDir + "oneDeep/twoDeep");
	assert(pathExists(testDir + "oneDeep/twoDeep"));
	makeDir(testDir + "oneDeep/twoDeep/threeDeep");
	assert(pathExists(testDir + "oneDeep/twoDeep/threeDeep"));
	write(testDir + "oneDeep/twoDeep/afile", "hubbahubba");
	assert(pathExists(testDir + "oneDeep/twoDeep/afile"));
	wipeTempDir(testDir + "oneDeep/twoDeep");
	assert(!pathExists(testDir + "oneDeep/twoDeep/threeDeep"));
	assert(!pathExists(testDir + "oneDeep/twoDeep/afile"));
	assert(!pathExists(testDir + "oneDeep/twoDeep"));
	wipeTempDir(testDir + "doesntexist"); // must not fail
	removeDir(testDir + "oneDeep");
	assert(!pathExists(testDir + "oneDeep"));

	var wipeMsg = "";
	try { wipeTempDir("/somewherenottemp/cantwipethis"); } catch (x) { wipeMsg = x; }
	assert(wipeMsg === "Cannot wipe directories that are not temporary");

	write(testDir + "testfile1.txt", "abracadabra");
	assert(read(testDir + "testfile1.txt") === "abracadabra");
	assert(pathExists(testDir + "testfile1.txt"));
	assert(pathExists(testDir + "*.txt"));
	assert(pathExists(testDir + "testfile?.txt"));
	eraseFile(testDir + "testfile2.txt");
	renameFile(testDir + "testfile1.txt", "testfile2.txt");
	assert(!pathExists(testDir + "testfile1.txt"));
	assert(pathExists(testDir + "testfile2.txt"));

	// ---- generate scratch files with unique ids ----
	var y = 2463534242;
	var usedIds = {};
	function nextId() {
		for (;;) {
			y ^= (y << 13);
			y ^= (y >>> 17);
			y ^= (y << 5);
			var id = padHex((y >>> 0) & 0xFFFFF, 6);
			if (!usedIds.hasOwnProperty(setKey(id))) { usedIds[setKey(id)] = true; return id; }
		}
	}
	var fileIDs = [];
	var fileContents = [];
	var fileIDsReverse = {};
	var i;
	for (i = 0; i < TEST_FILE_COUNT; ++i) {
		fileIDs[i] = nextId();
		var letter = String.fromCharCode(Math.floor(Math.random() * 26) + "a".charCodeAt(0));
		fileContents[i] = repeatStr(letter, Math.floor(Math.random() * 2001));
		fileIDsReverse[setKey(fileIDs[i])] = i;
	}

	print("Creating " + TEST_FILE_COUNT + " test files (first " + SLOW_FILE_COUNT + " with 2 secs delay in between)...");
	var nt = time();
	for (i = 0; i < TEST_FILE_COUNT; ++i) {
		write(testDir + "testfile " + fileIDs[i] + ".test", fileContents[i]);
		if (i < SLOW_FILE_COUNT) sleep(2);
		var now = time();
		if (now > nt) { nt = now + 1; print((i + 1) + "..."); }
	}
	print(i + "!");
	for (i = 0; i < TEST_FILE_COUNT; ++i) {
		assert(read(testDir + "testfile " + fileIDs[i] + ".test") === fileContents[i]);
	}

	print("Checking that dir() finds all files...");
	var found = {};
	dir(testDir, function (name) {
		assert(name.toUpperCase() === "TESTFILE2.TXT" || extensionOfPath(name) === ".test"
				, "name.toUpperCase() === 'TESTFILE2.TXT' || extensionOfPath(name) === '.test' (" + name + ")");
		found[setKey(name.toUpperCase())] = true;
	});
	for (i = 0; i < TEST_FILE_COUNT; ++i) {
		assert(found.hasOwnProperty(setKey(("testfile " + fileIDs[i] + ".test").toUpperCase())));
	}

	found = {};
	dir(testDir + "testfile*.test", function (name) {
		assert(extensionOfPath(name) === ".test", "extensionOfPath(name) === '.test' (" + name + ")");
		found[setKey(name.toUpperCase())] = true;
	});
	for (i = 0; i < TEST_FILE_COUNT; ++i) {
		assert(found.hasOwnProperty(setKey(("testfile " + fileIDs[i] + ".test").toUpperCase())));
	}

	var count = 0;
	var foundName = "";
	dir(testDir.substring(0, testDir.length - 1), function (name) { ++count; foundName = name; });
	assert(count === 1);
	assert(foundName.charAt(foundName.length - 1) === "/");
	assert(removeDirSlash(foundName).toUpperCase()
			=== filenameOfPath(removeDirSlash(testDir)).toUpperCase());

	print("Checking that sort-order 'name' works...");
	var last;
	last = undefined;
	dir(testDir + "testfile*.test", function (name) {
		assert(last === undefined || name > last, "(last === undefined || name > last)");
		last = name;
	}, "name", false);
	last = undefined;
	dir(testDir + "testfile*.test", function (name) {
		assert(last === undefined || name < last, "(last === undefined || name < last)");
		last = name;
	}, "name", true);

	print("Checking that sort-order 'time' works...");
	i = 0;
	dir(testDir + "testfile*.test", function (name) {
		var u = name.toUpperCase();
		assert(i >= SLOW_FILE_COUNT || u === ("testfile " + fileIDs[i] + ".test").toUpperCase());
		i++;
	}, "time", false);
	assert(i === TEST_FILE_COUNT);
	dir(testDir + "testfile*.test", function (name) {
		var u = name.toUpperCase();
		--i;
		assert(i >= SLOW_FILE_COUNT || u === ("testfile " + fileIDs[i] + ".test").toUpperCase());
	}, "time", true);
	assert(i === 0);

	print("Checking that sort-order 'size' works...");
	var idRe = /^testfile ([0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F])\.test$/;
	var lastLen = 0;
	dir(testDir + "testfile*.test", function (name) {
		var m = idRe.exec(name);
		assert(m !== null, "id match (" + name + ")");
		var l = fileContents[fileIDsReverse[setKey(m[1])]].length;
		assert(l >= lastLen);
		lastLen = l;
	}, "size", false);
	dir(testDir + "testfile*.test", function (name) {
		var m = idRe.exec(name);
		assert(m !== null, "id match (" + name + ")");
		var l = fileContents[fileIDsReverse[setKey(m[1])]].length;
		assert(l <= lastLen);
		lastLen = l;
	}, "size", true);

	print("Erasing all test files...");
	eraseFile(testDir + "testfile *.test");
	copyFile(testDir + "testfile2.txt", testDir + "testfile3.txt");
	assert(pathExists(testDir + "testfile*.txt"));
	assert(read(testDir + "testfile3.txt") === "abracadabra");

	try { makeDir(testDir + "sub"); } catch (x) {}
	assert(pathExists(testDir + "sub"));
	copyFile(testDir + "testfile2.txt", testDir + "sub/testfile4.txt");
	assert(read(testDir + "sub/testfile4.txt") === "abracadabra");
	moveFile(testDir + "sub/testfile4.txt", testDir + "testfile5.txt");
	assert(!pathExists(testDir + "sub/testfile4.txt"));
	assert(pathExists(testDir + "testfile5.txt"));
	moveFile(testDir + "testfile5.txt", testDir + "sub/testfile4.txt");
	assert(pathExists(testDir + "sub/testfile4.txt"));
	assert(!pathExists(testDir + "testfile5.txt"));

	print("Another 2 seconds delay");
	sleep(2);
	write(testDir + "sub/testfile6.txt", "hocuspocus");
	concatFiles(testDir + "testfile2.txt", testDir + "sub/testfile6.txt", testDir + "testfile2.txt"
			, testDir + "concatted");
	assert(read(testDir + "concatted") === "abracadabrahocuspocusabracadabra");
	eraseFile(testDir + "concatted");

	print("Size of testfile2.txt: " + fileSize(testDir + "testfile2.txt"));
	print("Size of testfile6.txt: " + fileSize(testDir + "sub/testfile6.txt"));

	print("Creating big file");
	var s = "All work and no play makes Jack a dull boy";
	while (s.length < 2048 * 1024) s += s;
	write(testDir + "bigfile.txt", s);
	assert(fileSize(testDir + "bigfile.txt") === s.length);
	print("File size matches (" + s.length + " bytes)");
	s = "";
	eraseFile(testDir + "bigfile.txt");

	assert(isFileNewer(testDir + "sub/testfile6.txt", testDir + "sub/testfile4.txt"));
	assert(isFileNewer(testDir + "sub/testfile6.txt", testDir + "sub/notexisting.txt"));
	assert(!isFileNewer(testDir + "sub/testfile4.txt", testDir + "sub/testfile6.txt"));
	assert(!isFileNewer(testDir + "sub/notexisting.txt", testDir + "sub/testfile4.txt"));

	eraseFile(testDir + "testfile2.txt");
	eraseFile(testDir + "testfile3.txt");
	eraseFile(testDir + "sub/testfile4.txt");
	eraseFile(testDir + "sub/testfile6.txt");
	assert(!pathExists(testDir + "testfile2.txt"));
	assert(!pathExists(testDir + "testfile3.txt"));
	assert(!pathExists(testDir + "testfile*.txt"));
	assert(!pathExists(testDir + "sub/testfile4.txt"));
	removeDir(testDir + "sub");
	dir(testDir + "testfile*.test", function () { assert(false); });
	removeDir(testDir);
	assert(!pathExists(testDir));
	expectThrow(function () { removeDir(testDir); }, "expected removeDir to fail");

	print("OK!");
})();
