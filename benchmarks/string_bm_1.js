var s = "magnus lidstrom";
for (var j = 0; j < 1000000; ++j) {
	for (var i = 0; s[i] !== (void 0); ++i);
}
x = '';
for (var i = 0; s[i] !== (void 0); ++i) x += s[i];
print(x);
