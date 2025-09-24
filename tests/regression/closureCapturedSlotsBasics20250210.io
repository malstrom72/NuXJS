> function makeCounter(start) {
> var value = start;
> return {
> inc: function(step) { value += step; return value; },
> read: function() { return value; }
> };
> }
> var counter = makeCounter(4);
> print(counter.read());
< 4
> print(counter.inc(5));
< 9
> print(counter.read());
< 9
-
> function aliasParameter(value) {
> var args = arguments;
> return {
> set: function(v) { value = v; return args[0]; },
> read: function() { return value; },
> arg: function() { return args[0]; }
> };
> }
> var record = aliasParameter(11);
> print(record.read());
< 11
> print(record.arg());
< 11
> print(record.set(29));
< 29
> print(record.read());
< 29
> print(record.arg());
< 29
-
> function buildInner() {
> var outer = 1;
> return function(step) {
> var middle = step;
> return function(add) {
> outer += middle + add;
> return outer;
> };
> };
> }
> var inner = buildInner()(5);
> print(inner(1));
< 7
> print(inner(0));
< 12
-
