var LOG2 = 0.69314718055994530942
var LOG2R = 1.44269504088896340736
var LOG10R = 0.43429448190325182765
var E = 2.71828182845904523536
var HALF_PI = 1.57079632679489661923
var PI = 3.14159265358979323846
var TWICE_PI = PI * 2.0
var COS_EPSILON = 1.0e-6

function abs(x) {
    return (x < 0 ? -x : x);
}

/*
    Derived from:
    
              oo
             =====  n
         x   \     x
        e  =  >    --
             /     n!
             =====
             n = 0
    
    ... which is the same as:
        
        1   x   x x   x x x
        - + - + --- + ----- + ...
        1   1   1*2   1*2*3
    
    ... which is the same as:
    
        1   x   x x   x x x
        - + - + - - + - - - + ...
        1   1   1 2   1 2 3
        
    Negative x yields huge floating point precision problems so we negate x before and do 1.0 / y afterwards instead.
*/
function exp(x) {
    var m = abs(x);
    var a = 1.0;
    var n = 1.0;
    var y = 1.0;
    do {
        var t = y;
        a *= m / n;
        y += a;
        n += 1.0;
    } while (y != t);
    return (x < 0.0 ? 1.0 / y : y);
}

/*
    Derived from:
    
                      oo
                     =====            n
                     \         n + 1 x
        log(1 + x) =  >    (-1)      --
                     /                n
                     =====
                     n = 1

    Taylor for log is only reliable between -0.5 and 0.5, so we scale beforehand.
*/
function log(x)
{
    if (x <= 0.0 || x >= 1.0e38) {
        throw("Domain error");
    }
    var b = 0.0;
    while (x < 0.5) { x *= 2.0; b -= LOG2; }
    while (x > 1.5) { x *= 0.5; b += LOG2; }
    x = 1.0 - x;
    var a = -1.0;
    var n = 1.0;
    var y = 0.0;
    do {
        t = y;
        a *= x;
        y += a / n;
        n += 1.0;
    } while (y != t);
    return y + b;
}

print(exp(-0.1));
print(exp(22.1));
print(log(1.1));
print(log(429039122.1));

print(log(exp(1)));
print(log(exp(2)));
print(log(exp(3)));
print(log(exp(4)));

for (var f = 0; f < 10; f += 0.0001) {
    if (abs(log(exp(f)) - f) > f * 0.00000001) {
        throw("Precision error");
    }
}
