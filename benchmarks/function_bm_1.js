function a(x) {
    function b(y) {
        function c(z) {
            return y + z;
        }
        return x + y + c(x * y);
    }
    return x + b(x * x);
}

for (var i = 0; i < 1000000; ++i) {
    var v = a(i);
}
