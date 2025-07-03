function test(n) {
  var a = [];
  for (var i = 0; i < n; ++i) {
    a[i] = Math.sin(Math.PI * i / 10000.0) / 3.0;
  }
  var d = 0.0;
  for (var i = 0; i < n; ++i) {
    d += Math.pow(a[i] - a[n - 1 - i], 2);
  }
  return d;
}
print(test(1000000));
