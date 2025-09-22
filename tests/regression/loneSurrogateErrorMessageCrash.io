// Regression for lone surrogate handling in String::toUTF8String.
// The engine should surface TypeError messages without aborting and
// preserve the offending code units through the WTF-8 encoder.
> var high = String.fromCharCode(0xD9DD);
> var low = String.fromCharCode(0xDC00);
> var pair = String.fromCharCode(0xD800) + low;
> var doubleHigh = String.fromCharCode(0xD800) + String.fromCharCode(0xD800);
> var status = [];
> try {
> 	(high)();
> } catch (e) {
> 	status.push(e instanceof TypeError);
> 	status.push(e.toString().indexOf(high) !== -1);
> }
> print(status.join(","));
< true,true
> print(high.length + ":" + high.charCodeAt(0));
< 1:55773
> print(low.length + ":" + low.charCodeAt(0));
< 1:56320
> print(pair.length + ":" + pair.charCodeAt(0) + "," + pair.charCodeAt(1));
< 2:55296,56320
> print(doubleHigh.length + ":" + doubleHigh.charCodeAt(0) + "," + doubleHigh.charCodeAt(1));
< 2:55296,55296
-
