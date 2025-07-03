y = 0;
for (var j = 0; j < 10000; ++j)
	for (var i = 0; i < 100; ++i)
		eval("y = y + i * 3");
print(y)
