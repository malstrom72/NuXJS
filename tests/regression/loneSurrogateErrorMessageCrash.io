// Regression for lone surrogate handling in String::toUTF8String.
// The engine should surface TypeError messages without aborting and
// preserve the offending code units through the WTF-8 encoder.
> var high = String.fromCharCode(0xD9DD);
> var low = String.fromCharCode(0xDC00);
> var pair = String.fromCharCode(0xD800) + low;
> var doubleHigh = String.fromCharCode(0xD800) + String.fromCharCode(0xD800);
> var samples = [
>        { label: "high", value: high },
>        { label: "low", value: low },
>        { label: "pair", value: pair },
>        { label: "doubleHigh", value: doubleHigh }
> ];
> var status = [];
> for (var i = 0; i < samples.length; ++i) {
>        var entry = samples[i];
>        try {
>                (entry.value)();
>        } catch (e) {
>                status.push(entry.label + ":" + (e instanceof TypeError));
>                status.push(entry.label + ":" + (typeof e.toString() === "string" && e.toString().length > 0));
>        }
> }
> print(status.join(","));
< high:true,high:true,low:true,low:true,pair:true,pair:true,doubleHigh:true,doubleHigh:true
> print(high.length + ":" + high.charCodeAt(0));
< 1:55773
> print(low.length + ":" + low.charCodeAt(0));
< 1:56320
> print(pair.length + ":" + pair.charCodeAt(0) + "," + pair.charCodeAt(1));
< 2:55296,56320
> print(doubleHigh.length + ":" + doubleHigh.charCodeAt(0) + "," + doubleHigh.charCodeAt(1));
< 2:55296,55296
> var roundTripHigh = String.fromCharCode(0xD800).toString();
> var roundTripLow = String.fromCharCode(0xDC00).toString();
> print(roundTripHigh.length + ":" + roundTripHigh.charCodeAt(0));
< 1:55296
> print(roundTripLow.length + ":" + roundTripLow.charCodeAt(0));
< 1:56320
> var mix = String.fromCharCode(0xD800) + "ok" + String.fromCharCode(0xDC00);
>        try {
>                (mix)();
>        } catch (e) {
>                print(e.toString().indexOf(mix) !== -1);
>        }
< true
