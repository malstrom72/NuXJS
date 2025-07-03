var a = []; 
f=function(n) { for (var i = 0; i < n; ++i) a[i] = "" + i * 1234; };
print("1st phase");
for (var j = 0; j < 2; ++j) f(500000);
for (var i = 0; i < 500000; i += 10000) print(i + ': ' + a[i]);
var b = []; 
f=function(n) { for (var i = 0; i < n; ++i) b[i] = "" + i * 1234; };
print("2nd phase");
for (var j = 0; j < 500; ++j) f(10000);
