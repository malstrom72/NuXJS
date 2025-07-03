> var valueStrings = [
>     'undefined', 'null', 'false', 'true', '0', '1', '-128', '1234.5678', '-1.0e+7', 'NaN', 'Infinity', '""', '"str"'
>     , '"-128"', '"1.0"', '"  +1234  "', '"string"', '"5tring"'
>     , '({valueOf:function(){return "-128"}})','({valueOf:function(){return null}})'
>     , 'new Boolean(true)', 'new Number(1234.5678)', 'new String("str")'
> ];
>    
> var values = [ ];
> for (var i = 0; i < valueStrings.length; ++i) {
>     values[i] = eval(valueStrings[i]);
> }
> 
> function testOneOperator(op) {    
> 	print(op);
> 	for (var i = 0; i < values.length; ++i) {
> 	    var a = values[i];
> 	    var results = "";
> 	    for (var j = 0; j < values.length; ++j) {
> 	        var b = values[j];
> 	        var r;
> 	        try {
> 	            r = eval('a' + op + 'b');
> 	            if (typeof r === 'number') {
> 	                r = r.toPrecision(5);
> 	            }
> 	        }
> 	        catch (e) {
> 	            r = e;
> 	        }
> 	        if (results !== "") {
> 	            results += " ";
> 	        }
> 	        results += r;
> 	    }
> 	    results = valueStrings[i] + ": " + results;
> 	    print(results);
> 	}
> 	print("");
> }
-
> testOneOperator("==")
< ==
< undefined: true true false false false false false false false false false false false false false false false false false false false false false
< null: true true false false false false false false false false false false false false false false false false false false false false false
< false: false false true false true false false false false false false true false false false false false false false false false false false
< true: false false false true false true false false false false false false false false true false false false false false true false false
< 0: false false true false true false false false false false false true false false false false false false false false false false false
< 1: false false false true false true false false false false false false false false true false false false false false true false false
< -128: false false false false false false true false false false false false false true false false false false true false false false false
< 1234.5678: false false false false false false false true false false false false false false false false false false false false false true false
< -1.0e+7: false false false false false false false false true false false false false false false false false false false false false false false
< NaN: false false false false false false false false false false false false false false false false false false false false false false false
< Infinity: false false false false false false false false false false true false false false false false false false false false false false false
< "": false false true false true false false false false false false true false false false false false false false false false false false
< "str": false false false false false false false false false false false false true false false false false false false false false false true
< "-128": false false false false false false true false false false false false false true false false false false true false false false false
< "1.0": false false false true false true false false false false false false false false true false false false false false true false false
< "  +1234  ": false false false false false false false false false false false false false false false true false false false false false false false
< "string": false false false false false false false false false false false false false false false false true false false false false false false
< "5tring": false false false false false false false false false false false false false false false false false true false false false false false
< ({valueOf:function(){return "-128"}}): false false false false false false true false false false false false false true false false false false true false false false false
< ({valueOf:function(){return null}}): false false false false false false false false false false false false false false false false false false false true false false false
< new Boolean(true): false false false true false true false false false false false false false false true false false false false false true false false
< new Number(1234.5678): false false false false false false false true false false false false false false false false false false false false false true false
< new String("str"): false false false false false false false false false false false false true false false false false false false false false false true
< 
-
> testOneOperator("!=")
< !=
< undefined: false false true true true true true true true true true true true true true true true true true true true true true
< null: false false true true true true true true true true true true true true true true true true true true true true true
< false: true true false true false true true true true true true false true true true true true true true true true true true
< true: true true true false true false true true true true true true true true false true true true true true false true true
< 0: true true false true false true true true true true true false true true true true true true true true true true true
< 1: true true true false true false true true true true true true true true false true true true true true false true true
< -128: true true true true true true false true true true true true true false true true true true false true true true true
< 1234.5678: true true true true true true true false true true true true true true true true true true true true true false true
< -1.0e+7: true true true true true true true true false true true true true true true true true true true true true true true
< NaN: true true true true true true true true true true true true true true true true true true true true true true true
< Infinity: true true true true true true true true true true false true true true true true true true true true true true true
< "": true true false true false true true true true true true false true true true true true true true true true true true
< "str": true true true true true true true true true true true true false true true true true true true true true true false
< "-128": true true true true true true false true true true true true true false true true true true false true true true true
< "1.0": true true true false true false true true true true true true true true false true true true true true false true true
< "  +1234  ": true true true true true true true true true true true true true true true false true true true true true true true
< "string": true true true true true true true true true true true true true true true true false true true true true true true
< "5tring": true true true true true true true true true true true true true true true true true false true true true true true
< ({valueOf:function(){return "-128"}}): true true true true true true false true true true true true true false true true true true false true true true true
< ({valueOf:function(){return null}}): true true true true true true true true true true true true true true true true true true true false true true true
< new Boolean(true): true true true false true false true true true true true true true true false true true true true true false true true
< new Number(1234.5678): true true true true true true true false true true true true true true true true true true true true true false true
< new String("str"): true true true true true true true true true true true true false true true true true true true true true true false
< 
-
> testOneOperator("===")
< ===
< undefined: true false false false false false false false false false false false false false false false false false false false false false false
< null: false true false false false false false false false false false false false false false false false false false false false false false
< false: false false true false false false false false false false false false false false false false false false false false false false false
< true: false false false true false false false false false false false false false false false false false false false false false false false
< 0: false false false false true false false false false false false false false false false false false false false false false false false
< 1: false false false false false true false false false false false false false false false false false false false false false false false
< -128: false false false false false false true false false false false false false false false false false false false false false false false
< 1234.5678: false false false false false false false true false false false false false false false false false false false false false false false
< -1.0e+7: false false false false false false false false true false false false false false false false false false false false false false false
< NaN: false false false false false false false false false false false false false false false false false false false false false false false
< Infinity: false false false false false false false false false false true false false false false false false false false false false false false
< "": false false false false false false false false false false false true false false false false false false false false false false false
< "str": false false false false false false false false false false false false true false false false false false false false false false false
< "-128": false false false false false false false false false false false false false true false false false false false false false false false
< "1.0": false false false false false false false false false false false false false false true false false false false false false false false
< "  +1234  ": false false false false false false false false false false false false false false false true false false false false false false false
< "string": false false false false false false false false false false false false false false false false true false false false false false false
< "5tring": false false false false false false false false false false false false false false false false false true false false false false false
< ({valueOf:function(){return "-128"}}): false false false false false false false false false false false false false false false false false false true false false false false
< ({valueOf:function(){return null}}): false false false false false false false false false false false false false false false false false false false true false false false
< new Boolean(true): false false false false false false false false false false false false false false false false false false false false true false false
< new Number(1234.5678): false false false false false false false false false false false false false false false false false false false false false true false
< new String("str"): false false false false false false false false false false false false false false false false false false false false false false true
< 
-
> testOneOperator("!==")
< !==
< undefined: false true true true true true true true true true true true true true true true true true true true true true true
< null: true false true true true true true true true true true true true true true true true true true true true true true
< false: true true false true true true true true true true true true true true true true true true true true true true true
< true: true true true false true true true true true true true true true true true true true true true true true true true
< 0: true true true true false true true true true true true true true true true true true true true true true true true
< 1: true true true true true false true true true true true true true true true true true true true true true true true
< -128: true true true true true true false true true true true true true true true true true true true true true true true
< 1234.5678: true true true true true true true false true true true true true true true true true true true true true true true
< -1.0e+7: true true true true true true true true false true true true true true true true true true true true true true true
< NaN: true true true true true true true true true true true true true true true true true true true true true true true
< Infinity: true true true true true true true true true true false true true true true true true true true true true true true
< "": true true true true true true true true true true true false true true true true true true true true true true true
< "str": true true true true true true true true true true true true false true true true true true true true true true true
< "-128": true true true true true true true true true true true true true false true true true true true true true true true
< "1.0": true true true true true true true true true true true true true true false true true true true true true true true
< "  +1234  ": true true true true true true true true true true true true true true true false true true true true true true true
< "string": true true true true true true true true true true true true true true true true false true true true true true true
< "5tring": true true true true true true true true true true true true true true true true true false true true true true true
< ({valueOf:function(){return "-128"}}): true true true true true true true true true true true true true true true true true true false true true true true
< ({valueOf:function(){return null}}): true true true true true true true true true true true true true true true true true true true false true true true
< new Boolean(true): true true true true true true true true true true true true true true true true true true true true false true true
< new Number(1234.5678): true true true true true true true true true true true true true true true true true true true true true false true
< new String("str"): true true true true true true true true true true true true true true true true true true true true true true false
< 
-
> testOneOperator("<")
< <
< undefined: false false false false false false false false false false false false false false false false false false false false false false false
< null: false false false true false true false true false false true false false false true true false false false false true true false
< false: false false false true false true false true false false true false false false true true false false false false true true false
< true: false false false false false false false true false false true false false false false true false false false false false true false
< 0: false false false true false true false true false false true false false false true true false false false false true true false
< 1: false false false false false false false true false false true false false false false true false false false false false true false
< -128: false true true true true true false true false false true true false false true true false false false true true true false
< 1234.5678: false false false false false false false false false false true false false false false false false false false false false false false
< -1.0e+7: false true true true true true true true false false true true false true true true false false true true true true false
< NaN: false false false false false false false false false false false false false false false false false false false false false false false
< Infinity: false false false false false false false false false false false false false false false false false false false false false false false
< "": false false false true false true false true false false true false true true true true true true true false true true true
< "str": false false false false false false false false false false false false false false false false true false false false false false false
< "-128": false true true true true true false true false false true false true false true false true true false true true true true
< "1.0": false false false false false false false true false false true false true false false false true true false false false true true
< "  +1234  ": false false false false false false false true false false true false true true true false true true true false false true true
< "string": false false false false false false false false false false false false false false false false false false false false false false false
< "5tring": false false false false false false false false false false false false true false false false true false false false false false true
< ({valueOf:function(){return "-128"}}): false true true true true true false true false false true false true false true false true true false true true true true
< ({valueOf:function(){return null}}): false false false true false true false true false false true false false false true true false false false false true true false
< new Boolean(true): false false false false false false false true false false true false false false false true false false false false false true false
< new Number(1234.5678): false false false false false false false false false false true false false false false false false false false false false false false
< new String("str"): false false false false false false false false false false false false false false false false true false false false false false false
< 
-
> testOneOperator("<=")
< <=
< undefined: false false false false false false false false false false false false false false false false false false false false false false false
< null: false true true true true true false true false false true true false false true true false false false true true true false
< false: false true true true true true false true false false true true false false true true false false false true true true false
< true: false false false true false true false true false false true false false false true true false false false false true true false
< 0: false true true true true true false true false false true true false false true true false false false true true true false
< 1: false false false true false true false true false false true false false false true true false false false false true true false
< -128: false true true true true true true true false false true true false true true true false false true true true true false
< 1234.5678: false false false false false false false true false false true false false false false false false false false false false true false
< -1.0e+7: false true true true true true true true true false true true false true true true false false true true true true false
< NaN: false false false false false false false false false false false false false false false false false false false false false false false
< Infinity: false false false false false false false false false false true false false false false false false false false false false false false
< "": false true true true true true false true false false true true true true true true true true true true true true true
< "str": false false false false false false false false false false false false true false false false true false false false false false true
< "-128": false true true true true true true true false false true false true true true false true true true true true true true
< "1.0": false false false true false true false true false false true false true false true false true true false false true true true
< "  +1234  ": false false false false false false false true false false true false true true true true true true true false false true true
< "string": false false false false false false false false false false false false false false false false true false false false false false false
< "5tring": false false false false false false false false false false false false true false false false true true false false false false true
< ({valueOf:function(){return "-128"}}): false true true true true true true true false false true false true true true false true true true true true true true
< ({valueOf:function(){return null}}): false true true true true true false true false false true true false false true true false false false true true true false
< new Boolean(true): false false false true false true false true false false true false false false true true false false false false true true false
< new Number(1234.5678): false false false false false false false true false false true false false false false false false false false false false true false
< new String("str"): false false false false false false false false false false false false true false false false true false false false false false true
< 
-
> testOneOperator(">")
< >
< undefined: false false false false false false false false false false false false false false false false false false false false false false false
< null: false false false false false false true false true false false false false true false false false false true false false false false
< false: false false false false false false true false true false false false false true false false false false true false false false false
< true: false true true false true false true false true false false true false true false false false false true true false false false
< 0: false false false false false false true false true false false false false true false false false false true false false false false
< 1: false true true false true false true false true false false true false true false false false false true true false false false
< -128: false false false false false false false false true false false false false false false false false false false false false false false
< 1234.5678: false true true true true true true false true false false true false true true true false false true true true false false
< -1.0e+7: false false false false false false false false false false false false false false false false false false false false false false false
< NaN: false false false false false false false false false false false false false false false false false false false false false false false
< Infinity: false true true true true true true true true false false true false true true true false false true true true true false
< "": false false false false false false true false true false false false false false false false false false false false false false false
< "str": false false false false false false false false false false false true false true true true false true true false false false false
< "-128": false false false false false false false false true false false true false false false true false false false false false false false
< "1.0": false true true false true false true false true false false true false true false true false false true true false false false
< "  +1234  ": false true true true true true true false true false false true false false false false false false false true true false false
< "string": false false false false false false false false false false false true true true true true false true true false false false true
< "5tring": false false false false false false false false false false false true false true true true false false true false false false false
< ({valueOf:function(){return "-128"}}): false false false false false false false false true false false true false false false true false false false false false false false
< ({valueOf:function(){return null}}): false false false false false false true false true false false false false true false false false false true false false false false
< new Boolean(true): false true true false true false true false true false false true false true false false false false true true false false false
< new Number(1234.5678): false true true true true true true false true false false true false true true true false false true true true false false
< new String("str"): false false false false false false false false false false false true false true true true false true true false false false false
< 
-
> testOneOperator(">=")
< >=
< undefined: false false false false false false false false false false false false false false false false false false false false false false false
< null: false true true false true false true false true false false true false true false false false false true true false false false
< false: false true true false true false true false true false false true false true false false false false true true false false false
< true: false true true true true true true false true false false true false true true false false false true true true false false
< 0: false true true false true false true false true false false true false true false false false false true true false false false
< 1: false true true true true true true false true false false true false true true false false false true true true false false
< -128: false false false false false false true false true false false false false true false false false false true false false false false
< 1234.5678: false true true true true true true true true false false true false true true true false false true true true true false
< -1.0e+7: false false false false false false false false true false false false false false false false false false false false false false false
< NaN: false false false false false false false false false false false false false false false false false false false false false false false
< Infinity: false true true true true true true true true false true true false true true true false false true true true true false
< "": false true true false true false true false true false false true false false false false false false false true false false false
< "str": false false false false false false false false false false false true true true true true false true true false false false true
< "-128": false false false false false false true false true false false true false true false true false false true false false false false
< "1.0": false true true true true true true false true false false true false true true true false false true true true false false
< "  +1234  ": false true true true true true true false true false false true false false false true false false false true true false false
< "string": false false false false false false false false false false false true true true true true true true true false false false true
< "5tring": false false false false false false false false false false false true false true true true false true true false false false false
< ({valueOf:function(){return "-128"}}): false false false false false false true false true false false true false true false true false false true false false false false
< ({valueOf:function(){return null}}): false true true false true false true false true false false true false true false false false false true true false false false
< new Boolean(true): false true true true true true true false true false false true false true true false false false true true true false false
< new Number(1234.5678): false true true true true true true true true false false true false true true true false false true true true true false
< new String("str"): false false false false false false false false false false false true true true true true false true true false false false true
< 
-
> testOneOperator("+")
< +
< undefined: NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN undefined undefinedstr undefined-128 undefined1.0 undefined  +1234   undefinedstring undefined5tring undefined-128 NaN NaN NaN undefinedstr
< null: NaN 0.0000 0.0000 1.0000 0.0000 1.0000 -128.00 1234.6 -1.0000e+7 NaN Infinity null nullstr null-128 null1.0 null  +1234   nullstring null5tring null-128 0.0000 1.0000 1234.6 nullstr
< false: NaN 0.0000 0.0000 1.0000 0.0000 1.0000 -128.00 1234.6 -1.0000e+7 NaN Infinity false falsestr false-128 false1.0 false  +1234   falsestring false5tring false-128 0.0000 1.0000 1234.6 falsestr
< true: NaN 1.0000 1.0000 2.0000 1.0000 2.0000 -127.00 1235.6 -1.0000e+7 NaN Infinity true truestr true-128 true1.0 true  +1234   truestring true5tring true-128 1.0000 2.0000 1235.6 truestr
< 0: NaN 0.0000 0.0000 1.0000 0.0000 1.0000 -128.00 1234.6 -1.0000e+7 NaN Infinity 0 0str 0-128 01.0 0  +1234   0string 05tring 0-128 0.0000 1.0000 1234.6 0str
< 1: NaN 1.0000 1.0000 2.0000 1.0000 2.0000 -127.00 1235.6 -1.0000e+7 NaN Infinity 1 1str 1-128 11.0 1  +1234   1string 15tring 1-128 1.0000 2.0000 1235.6 1str
< -128: NaN -128.00 -128.00 -127.00 -128.00 -127.00 -256.00 1106.6 -1.0000e+7 NaN Infinity -128 -128str -128-128 -1281.0 -128  +1234   -128string -1285tring -128-128 -128.00 -127.00 1106.6 -128str
< 1234.5678: NaN 1234.6 1234.6 1235.6 1234.6 1235.6 1106.6 2469.1 -9.9988e+6 NaN Infinity 1234.5678 1234.5678str 1234.5678-128 1234.56781.0 1234.5678  +1234   1234.5678string 1234.56785tring 1234.5678-128 1234.6 1235.6 2469.1 1234.5678str
< -1.0e+7: NaN -1.0000e+7 -1.0000e+7 -1.0000e+7 -1.0000e+7 -1.0000e+7 -1.0000e+7 -9.9988e+6 -2.0000e+7 NaN Infinity -10000000 -10000000str -10000000-128 -100000001.0 -10000000  +1234   -10000000string -100000005tring -10000000-128 -1.0000e+7 -1.0000e+7 -9.9988e+6 -10000000str
< NaN: NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaNstr NaN-128 NaN1.0 NaN  +1234   NaNstring NaN5tring NaN-128 NaN NaN NaN NaNstr
< Infinity: NaN Infinity Infinity Infinity Infinity Infinity Infinity Infinity Infinity NaN Infinity Infinity Infinitystr Infinity-128 Infinity1.0 Infinity  +1234   Infinitystring Infinity5tring Infinity-128 Infinity Infinity Infinity Infinitystr
< "": undefined null false true 0 1 -128 1234.5678 -10000000 NaN Infinity  str -128 1.0   +1234   string 5tring -128 null true 1234.5678 str
< "str": strundefined strnull strfalse strtrue str0 str1 str-128 str1234.5678 str-10000000 strNaN strInfinity str strstr str-128 str1.0 str  +1234   strstring str5tring str-128 strnull strtrue str1234.5678 strstr
< "-128": -128undefined -128null -128false -128true -1280 -1281 -128-128 -1281234.5678 -128-10000000 -128NaN -128Infinity -128 -128str -128-128 -1281.0 -128  +1234   -128string -1285tring -128-128 -128null -128true -1281234.5678 -128str
< "1.0": 1.0undefined 1.0null 1.0false 1.0true 1.00 1.01 1.0-128 1.01234.5678 1.0-10000000 1.0NaN 1.0Infinity 1.0 1.0str 1.0-128 1.01.0 1.0  +1234   1.0string 1.05tring 1.0-128 1.0null 1.0true 1.01234.5678 1.0str
< "  +1234  ":   +1234  undefined   +1234  null   +1234  false   +1234  true   +1234  0   +1234  1   +1234  -128   +1234  1234.5678   +1234  -10000000   +1234  NaN   +1234  Infinity   +1234     +1234  str   +1234  -128   +1234  1.0   +1234    +1234     +1234  string   +1234  5tring   +1234  -128   +1234  null   +1234  true   +1234  1234.5678   +1234  str
< "string": stringundefined stringnull stringfalse stringtrue string0 string1 string-128 string1234.5678 string-10000000 stringNaN stringInfinity string stringstr string-128 string1.0 string  +1234   stringstring string5tring string-128 stringnull stringtrue string1234.5678 stringstr
< "5tring": 5tringundefined 5tringnull 5tringfalse 5tringtrue 5tring0 5tring1 5tring-128 5tring1234.5678 5tring-10000000 5tringNaN 5tringInfinity 5tring 5tringstr 5tring-128 5tring1.0 5tring  +1234   5tringstring 5tring5tring 5tring-128 5tringnull 5tringtrue 5tring1234.5678 5tringstr
< ({valueOf:function(){return "-128"}}): -128undefined -128null -128false -128true -1280 -1281 -128-128 -1281234.5678 -128-10000000 -128NaN -128Infinity -128 -128str -128-128 -1281.0 -128  +1234   -128string -1285tring -128-128 -128null -128true -1281234.5678 -128str
< ({valueOf:function(){return null}}): NaN 0.0000 0.0000 1.0000 0.0000 1.0000 -128.00 1234.6 -1.0000e+7 NaN Infinity null nullstr null-128 null1.0 null  +1234   nullstring null5tring null-128 0.0000 1.0000 1234.6 nullstr
< new Boolean(true): NaN 1.0000 1.0000 2.0000 1.0000 2.0000 -127.00 1235.6 -1.0000e+7 NaN Infinity true truestr true-128 true1.0 true  +1234   truestring true5tring true-128 1.0000 2.0000 1235.6 truestr
< new Number(1234.5678): NaN 1234.6 1234.6 1235.6 1234.6 1235.6 1106.6 2469.1 -9.9988e+6 NaN Infinity 1234.5678 1234.5678str 1234.5678-128 1234.56781.0 1234.5678  +1234   1234.5678string 1234.56785tring 1234.5678-128 1234.6 1235.6 2469.1 1234.5678str
< new String("str"): strundefined strnull strfalse strtrue str0 str1 str-128 str1234.5678 str-10000000 strNaN strInfinity str strstr str-128 str1.0 str  +1234   strstring str5tring str-128 strnull strtrue str1234.5678 strstr
< 
-
> testOneOperator("-")
< -
< undefined: NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN
< null: NaN 0.0000 0.0000 -1.0000 0.0000 -1.0000 128.00 -1234.6 1.0000e+7 NaN -Infinity 0.0000 NaN 128.00 -1.0000 -1234.0 NaN NaN 128.00 0.0000 -1.0000 -1234.6 NaN
< false: NaN 0.0000 0.0000 -1.0000 0.0000 -1.0000 128.00 -1234.6 1.0000e+7 NaN -Infinity 0.0000 NaN 128.00 -1.0000 -1234.0 NaN NaN 128.00 0.0000 -1.0000 -1234.6 NaN
< true: NaN 1.0000 1.0000 0.0000 1.0000 0.0000 129.00 -1233.6 1.0000e+7 NaN -Infinity 1.0000 NaN 129.00 0.0000 -1233.0 NaN NaN 129.00 1.0000 0.0000 -1233.6 NaN
< 0: NaN 0.0000 0.0000 -1.0000 0.0000 -1.0000 128.00 -1234.6 1.0000e+7 NaN -Infinity 0.0000 NaN 128.00 -1.0000 -1234.0 NaN NaN 128.00 0.0000 -1.0000 -1234.6 NaN
< 1: NaN 1.0000 1.0000 0.0000 1.0000 0.0000 129.00 -1233.6 1.0000e+7 NaN -Infinity 1.0000 NaN 129.00 0.0000 -1233.0 NaN NaN 129.00 1.0000 0.0000 -1233.6 NaN
< -128: NaN -128.00 -128.00 -129.00 -128.00 -129.00 0.0000 -1362.6 9.9999e+6 NaN -Infinity -128.00 NaN 0.0000 -129.00 -1362.0 NaN NaN 0.0000 -128.00 -129.00 -1362.6 NaN
< 1234.5678: NaN 1234.6 1234.6 1233.6 1234.6 1233.6 1362.6 0.0000 1.0001e+7 NaN -Infinity 1234.6 NaN 1362.6 1233.6 0.56780 NaN NaN 1362.6 1234.6 1233.6 0.0000 NaN
< -1.0e+7: NaN -1.0000e+7 -1.0000e+7 -1.0000e+7 -1.0000e+7 -1.0000e+7 -9.9999e+6 -1.0001e+7 0.0000 NaN -Infinity -1.0000e+7 NaN -9.9999e+6 -1.0000e+7 -1.0001e+7 NaN NaN -9.9999e+6 -1.0000e+7 -1.0000e+7 -1.0001e+7 NaN
< NaN: NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN
< Infinity: NaN Infinity Infinity Infinity Infinity Infinity Infinity Infinity Infinity NaN NaN Infinity NaN Infinity Infinity Infinity NaN NaN Infinity Infinity Infinity Infinity NaN
< "": NaN 0.0000 0.0000 -1.0000 0.0000 -1.0000 128.00 -1234.6 1.0000e+7 NaN -Infinity 0.0000 NaN 128.00 -1.0000 -1234.0 NaN NaN 128.00 0.0000 -1.0000 -1234.6 NaN
< "str": NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN
< "-128": NaN -128.00 -128.00 -129.00 -128.00 -129.00 0.0000 -1362.6 9.9999e+6 NaN -Infinity -128.00 NaN 0.0000 -129.00 -1362.0 NaN NaN 0.0000 -128.00 -129.00 -1362.6 NaN
< "1.0": NaN 1.0000 1.0000 0.0000 1.0000 0.0000 129.00 -1233.6 1.0000e+7 NaN -Infinity 1.0000 NaN 129.00 0.0000 -1233.0 NaN NaN 129.00 1.0000 0.0000 -1233.6 NaN
< "  +1234  ": NaN 1234.0 1234.0 1233.0 1234.0 1233.0 1362.0 -0.56780 1.0001e+7 NaN -Infinity 1234.0 NaN 1362.0 1233.0 0.0000 NaN NaN 1362.0 1234.0 1233.0 -0.56780 NaN
< "string": NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN
< "5tring": NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN
< ({valueOf:function(){return "-128"}}): NaN -128.00 -128.00 -129.00 -128.00 -129.00 0.0000 -1362.6 9.9999e+6 NaN -Infinity -128.00 NaN 0.0000 -129.00 -1362.0 NaN NaN 0.0000 -128.00 -129.00 -1362.6 NaN
< ({valueOf:function(){return null}}): NaN 0.0000 0.0000 -1.0000 0.0000 -1.0000 128.00 -1234.6 1.0000e+7 NaN -Infinity 0.0000 NaN 128.00 -1.0000 -1234.0 NaN NaN 128.00 0.0000 -1.0000 -1234.6 NaN
< new Boolean(true): NaN 1.0000 1.0000 0.0000 1.0000 0.0000 129.00 -1233.6 1.0000e+7 NaN -Infinity 1.0000 NaN 129.00 0.0000 -1233.0 NaN NaN 129.00 1.0000 0.0000 -1233.6 NaN
< new Number(1234.5678): NaN 1234.6 1234.6 1233.6 1234.6 1233.6 1362.6 0.0000 1.0001e+7 NaN -Infinity 1234.6 NaN 1362.6 1233.6 0.56780 NaN NaN 1362.6 1234.6 1233.6 0.0000 NaN
< new String("str"): NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN
< 
-
> testOneOperator("*")
< *
< undefined: NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN
< null: NaN 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 NaN NaN 0.0000 NaN 0.0000 0.0000 0.0000 NaN NaN 0.0000 0.0000 0.0000 0.0000 NaN
< false: NaN 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 NaN NaN 0.0000 NaN 0.0000 0.0000 0.0000 NaN NaN 0.0000 0.0000 0.0000 0.0000 NaN
< true: NaN 0.0000 0.0000 1.0000 0.0000 1.0000 -128.00 1234.6 -1.0000e+7 NaN Infinity 0.0000 NaN -128.00 1.0000 1234.0 NaN NaN -128.00 0.0000 1.0000 1234.6 NaN
< 0: NaN 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 NaN NaN 0.0000 NaN 0.0000 0.0000 0.0000 NaN NaN 0.0000 0.0000 0.0000 0.0000 NaN
< 1: NaN 0.0000 0.0000 1.0000 0.0000 1.0000 -128.00 1234.6 -1.0000e+7 NaN Infinity 0.0000 NaN -128.00 1.0000 1234.0 NaN NaN -128.00 0.0000 1.0000 1234.6 NaN
< -128: NaN 0.0000 0.0000 -128.00 0.0000 -128.00 16384 -1.5802e+5 1.2800e+9 NaN -Infinity 0.0000 NaN 16384 -128.00 -1.5795e+5 NaN NaN 16384 0.0000 -128.00 -1.5802e+5 NaN
< 1234.5678: NaN 0.0000 0.0000 1234.6 0.0000 1234.6 -1.5802e+5 1.5242e+6 -1.2346e+10 NaN Infinity 0.0000 NaN -1.5802e+5 1234.6 1.5235e+6 NaN NaN -1.5802e+5 0.0000 1234.6 1.5242e+6 NaN
< -1.0e+7: NaN 0.0000 0.0000 -1.0000e+7 0.0000 -1.0000e+7 1.2800e+9 -1.2346e+10 1.0000e+14 NaN -Infinity 0.0000 NaN 1.2800e+9 -1.0000e+7 -1.2340e+10 NaN NaN 1.2800e+9 0.0000 -1.0000e+7 -1.2346e+10 NaN
< NaN: NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN
< Infinity: NaN NaN NaN Infinity NaN Infinity -Infinity Infinity -Infinity NaN Infinity NaN NaN -Infinity Infinity Infinity NaN NaN -Infinity NaN Infinity Infinity NaN
< "": NaN 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 NaN NaN 0.0000 NaN 0.0000 0.0000 0.0000 NaN NaN 0.0000 0.0000 0.0000 0.0000 NaN
< "str": NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN
< "-128": NaN 0.0000 0.0000 -128.00 0.0000 -128.00 16384 -1.5802e+5 1.2800e+9 NaN -Infinity 0.0000 NaN 16384 -128.00 -1.5795e+5 NaN NaN 16384 0.0000 -128.00 -1.5802e+5 NaN
< "1.0": NaN 0.0000 0.0000 1.0000 0.0000 1.0000 -128.00 1234.6 -1.0000e+7 NaN Infinity 0.0000 NaN -128.00 1.0000 1234.0 NaN NaN -128.00 0.0000 1.0000 1234.6 NaN
< "  +1234  ": NaN 0.0000 0.0000 1234.0 0.0000 1234.0 -1.5795e+5 1.5235e+6 -1.2340e+10 NaN Infinity 0.0000 NaN -1.5795e+5 1234.0 1.5228e+6 NaN NaN -1.5795e+5 0.0000 1234.0 1.5235e+6 NaN
< "string": NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN
< "5tring": NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN
< ({valueOf:function(){return "-128"}}): NaN 0.0000 0.0000 -128.00 0.0000 -128.00 16384 -1.5802e+5 1.2800e+9 NaN -Infinity 0.0000 NaN 16384 -128.00 -1.5795e+5 NaN NaN 16384 0.0000 -128.00 -1.5802e+5 NaN
< ({valueOf:function(){return null}}): NaN 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 NaN NaN 0.0000 NaN 0.0000 0.0000 0.0000 NaN NaN 0.0000 0.0000 0.0000 0.0000 NaN
< new Boolean(true): NaN 0.0000 0.0000 1.0000 0.0000 1.0000 -128.00 1234.6 -1.0000e+7 NaN Infinity 0.0000 NaN -128.00 1.0000 1234.0 NaN NaN -128.00 0.0000 1.0000 1234.6 NaN
< new Number(1234.5678): NaN 0.0000 0.0000 1234.6 0.0000 1234.6 -1.5802e+5 1.5242e+6 -1.2346e+10 NaN Infinity 0.0000 NaN -1.5802e+5 1234.6 1.5235e+6 NaN NaN -1.5802e+5 0.0000 1234.6 1.5242e+6 NaN
< new String("str"): NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN
< 
-
> testOneOperator("/")
< /
< undefined: NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN
< null: NaN NaN NaN 0.0000 NaN 0.0000 0.0000 0.0000 0.0000 NaN 0.0000 NaN NaN 0.0000 0.0000 0.0000 NaN NaN 0.0000 NaN 0.0000 0.0000 NaN
< false: NaN NaN NaN 0.0000 NaN 0.0000 0.0000 0.0000 0.0000 NaN 0.0000 NaN NaN 0.0000 0.0000 0.0000 NaN NaN 0.0000 NaN 0.0000 0.0000 NaN
< true: NaN Infinity Infinity 1.0000 Infinity 1.0000 -0.0078125 0.00081000 -1.0000e-7 NaN 0.0000 Infinity NaN -0.0078125 1.0000 0.00081037 NaN NaN -0.0078125 Infinity 1.0000 0.00081000 NaN
< 0: NaN NaN NaN 0.0000 NaN 0.0000 0.0000 0.0000 0.0000 NaN 0.0000 NaN NaN 0.0000 0.0000 0.0000 NaN NaN 0.0000 NaN 0.0000 0.0000 NaN
< 1: NaN Infinity Infinity 1.0000 Infinity 1.0000 -0.0078125 0.00081000 -1.0000e-7 NaN 0.0000 Infinity NaN -0.0078125 1.0000 0.00081037 NaN NaN -0.0078125 Infinity 1.0000 0.00081000 NaN
< -128: NaN -Infinity -Infinity -128.00 -Infinity -128.00 1.0000 -0.10368 0.000012800 NaN 0.0000 -Infinity NaN 1.0000 -128.00 -0.10373 NaN NaN 1.0000 -Infinity -128.00 -0.10368 NaN
< 1234.5678: NaN Infinity Infinity 1234.6 Infinity 1234.6 -9.6451 1.0000 -0.00012346 NaN 0.0000 Infinity NaN -9.6451 1234.6 1.0005 NaN NaN -9.6451 Infinity 1234.6 1.0000 NaN
< -1.0e+7: NaN -Infinity -Infinity -1.0000e+7 -Infinity -1.0000e+7 78125 -8100.0 1.0000 NaN 0.0000 -Infinity NaN 78125 -1.0000e+7 -8103.7 NaN NaN 78125 -Infinity -1.0000e+7 -8100.0 NaN
< NaN: NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN
< Infinity: NaN Infinity Infinity Infinity Infinity Infinity -Infinity Infinity -Infinity NaN NaN Infinity NaN -Infinity Infinity Infinity NaN NaN -Infinity Infinity Infinity Infinity NaN
< "": NaN NaN NaN 0.0000 NaN 0.0000 0.0000 0.0000 0.0000 NaN 0.0000 NaN NaN 0.0000 0.0000 0.0000 NaN NaN 0.0000 NaN 0.0000 0.0000 NaN
< "str": NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN
< "-128": NaN -Infinity -Infinity -128.00 -Infinity -128.00 1.0000 -0.10368 0.000012800 NaN 0.0000 -Infinity NaN 1.0000 -128.00 -0.10373 NaN NaN 1.0000 -Infinity -128.00 -0.10368 NaN
< "1.0": NaN Infinity Infinity 1.0000 Infinity 1.0000 -0.0078125 0.00081000 -1.0000e-7 NaN 0.0000 Infinity NaN -0.0078125 1.0000 0.00081037 NaN NaN -0.0078125 Infinity 1.0000 0.00081000 NaN
< "  +1234  ": NaN Infinity Infinity 1234.0 Infinity 1234.0 -9.6406 0.99954 -0.00012340 NaN 0.0000 Infinity NaN -9.6406 1234.0 1.0000 NaN NaN -9.6406 Infinity 1234.0 0.99954 NaN
< "string": NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN
< "5tring": NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN
< ({valueOf:function(){return "-128"}}): NaN -Infinity -Infinity -128.00 -Infinity -128.00 1.0000 -0.10368 0.000012800 NaN 0.0000 -Infinity NaN 1.0000 -128.00 -0.10373 NaN NaN 1.0000 -Infinity -128.00 -0.10368 NaN
< ({valueOf:function(){return null}}): NaN NaN NaN 0.0000 NaN 0.0000 0.0000 0.0000 0.0000 NaN 0.0000 NaN NaN 0.0000 0.0000 0.0000 NaN NaN 0.0000 NaN 0.0000 0.0000 NaN
< new Boolean(true): NaN Infinity Infinity 1.0000 Infinity 1.0000 -0.0078125 0.00081000 -1.0000e-7 NaN 0.0000 Infinity NaN -0.0078125 1.0000 0.00081037 NaN NaN -0.0078125 Infinity 1.0000 0.00081000 NaN
< new Number(1234.5678): NaN Infinity Infinity 1234.6 Infinity 1234.6 -9.6451 1.0000 -0.00012346 NaN 0.0000 Infinity NaN -9.6451 1234.6 1.0005 NaN NaN -9.6451 Infinity 1234.6 1.0000 NaN
< new String("str"): NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN
< 
-
> testOneOperator("%")
< %
< undefined: NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN
< null: NaN NaN NaN 0.0000 NaN 0.0000 0.0000 0.0000 0.0000 NaN 0.0000 NaN NaN 0.0000 0.0000 0.0000 NaN NaN 0.0000 NaN 0.0000 0.0000 NaN
< false: NaN NaN NaN 0.0000 NaN 0.0000 0.0000 0.0000 0.0000 NaN 0.0000 NaN NaN 0.0000 0.0000 0.0000 NaN NaN 0.0000 NaN 0.0000 0.0000 NaN
< true: NaN NaN NaN 0.0000 NaN 0.0000 1.0000 1.0000 1.0000 NaN 1.0000 NaN NaN 1.0000 0.0000 1.0000 NaN NaN 1.0000 NaN 0.0000 1.0000 NaN
< 0: NaN NaN NaN 0.0000 NaN 0.0000 0.0000 0.0000 0.0000 NaN 0.0000 NaN NaN 0.0000 0.0000 0.0000 NaN NaN 0.0000 NaN 0.0000 0.0000 NaN
< 1: NaN NaN NaN 0.0000 NaN 0.0000 1.0000 1.0000 1.0000 NaN 1.0000 NaN NaN 1.0000 0.0000 1.0000 NaN NaN 1.0000 NaN 0.0000 1.0000 NaN
< -128: NaN NaN NaN 0.0000 NaN 0.0000 0.0000 -128.00 -128.00 NaN -128.00 NaN NaN 0.0000 0.0000 -128.00 NaN NaN 0.0000 NaN 0.0000 -128.00 NaN
< 1234.5678: NaN NaN NaN 0.56780 NaN 0.56780 82.568 0.0000 1234.6 NaN 1234.6 NaN NaN 82.568 0.56780 0.56780 NaN NaN 82.568 NaN 0.56780 0.0000 NaN
< -1.0e+7: NaN NaN NaN 0.0000 NaN 0.0000 0.0000 -0.82000 0.0000 NaN -1.0000e+7 NaN NaN 0.0000 0.0000 -898.00 NaN NaN 0.0000 NaN 0.0000 -0.82000 NaN
< NaN: NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN
< Infinity: NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN
< "": NaN NaN NaN 0.0000 NaN 0.0000 0.0000 0.0000 0.0000 NaN 0.0000 NaN NaN 0.0000 0.0000 0.0000 NaN NaN 0.0000 NaN 0.0000 0.0000 NaN
< "str": NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN
< "-128": NaN NaN NaN 0.0000 NaN 0.0000 0.0000 -128.00 -128.00 NaN -128.00 NaN NaN 0.0000 0.0000 -128.00 NaN NaN 0.0000 NaN 0.0000 -128.00 NaN
< "1.0": NaN NaN NaN 0.0000 NaN 0.0000 1.0000 1.0000 1.0000 NaN 1.0000 NaN NaN 1.0000 0.0000 1.0000 NaN NaN 1.0000 NaN 0.0000 1.0000 NaN
< "  +1234  ": NaN NaN NaN 0.0000 NaN 0.0000 82.000 1234.0 1234.0 NaN 1234.0 NaN NaN 82.000 0.0000 0.0000 NaN NaN 82.000 NaN 0.0000 1234.0 NaN
< "string": NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN
< "5tring": NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN
< ({valueOf:function(){return "-128"}}): NaN NaN NaN 0.0000 NaN 0.0000 0.0000 -128.00 -128.00 NaN -128.00 NaN NaN 0.0000 0.0000 -128.00 NaN NaN 0.0000 NaN 0.0000 -128.00 NaN
< ({valueOf:function(){return null}}): NaN NaN NaN 0.0000 NaN 0.0000 0.0000 0.0000 0.0000 NaN 0.0000 NaN NaN 0.0000 0.0000 0.0000 NaN NaN 0.0000 NaN 0.0000 0.0000 NaN
< new Boolean(true): NaN NaN NaN 0.0000 NaN 0.0000 1.0000 1.0000 1.0000 NaN 1.0000 NaN NaN 1.0000 0.0000 1.0000 NaN NaN 1.0000 NaN 0.0000 1.0000 NaN
< new Number(1234.5678): NaN NaN NaN 0.56780 NaN 0.56780 82.568 0.0000 1234.6 NaN 1234.6 NaN NaN 82.568 0.56780 0.56780 NaN NaN 82.568 NaN 0.56780 0.0000 NaN
< new String("str"): NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN
< 
-
> testOneOperator("&")
< &
< undefined: 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000
< null: 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000
< false: 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000
< true: 0.0000 0.0000 0.0000 1.0000 0.0000 1.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 1.0000 0.0000 0.0000 0.0000 0.0000 0.0000 1.0000 0.0000 0.0000
< 0: 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000
< 1: 0.0000 0.0000 0.0000 1.0000 0.0000 1.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 1.0000 0.0000 0.0000 0.0000 0.0000 0.0000 1.0000 0.0000 0.0000
< -128: 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 -128.00 1152.0 -1.0000e+7 0.0000 0.0000 0.0000 0.0000 -128.00 0.0000 1152.0 0.0000 0.0000 -128.00 0.0000 0.0000 1152.0 0.0000
< 1234.5678: 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 1152.0 1234.0 128.00 0.0000 0.0000 0.0000 0.0000 1152.0 0.0000 1234.0 0.0000 0.0000 1152.0 0.0000 0.0000 1234.0 0.0000
< -1.0e+7: 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 -1.0000e+7 128.00 -1.0000e+7 0.0000 0.0000 0.0000 0.0000 -1.0000e+7 0.0000 128.00 0.0000 0.0000 -1.0000e+7 0.0000 0.0000 128.00 0.0000
< NaN: 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000
< Infinity: 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000
< "": 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000
< "str": 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000
< "-128": 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 -128.00 1152.0 -1.0000e+7 0.0000 0.0000 0.0000 0.0000 -128.00 0.0000 1152.0 0.0000 0.0000 -128.00 0.0000 0.0000 1152.0 0.0000
< "1.0": 0.0000 0.0000 0.0000 1.0000 0.0000 1.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 1.0000 0.0000 0.0000 0.0000 0.0000 0.0000 1.0000 0.0000 0.0000
< "  +1234  ": 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 1152.0 1234.0 128.00 0.0000 0.0000 0.0000 0.0000 1152.0 0.0000 1234.0 0.0000 0.0000 1152.0 0.0000 0.0000 1234.0 0.0000
< "string": 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000
< "5tring": 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000
< ({valueOf:function(){return "-128"}}): 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 -128.00 1152.0 -1.0000e+7 0.0000 0.0000 0.0000 0.0000 -128.00 0.0000 1152.0 0.0000 0.0000 -128.00 0.0000 0.0000 1152.0 0.0000
< ({valueOf:function(){return null}}): 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000
< new Boolean(true): 0.0000 0.0000 0.0000 1.0000 0.0000 1.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 1.0000 0.0000 0.0000 0.0000 0.0000 0.0000 1.0000 0.0000 0.0000
< new Number(1234.5678): 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 1152.0 1234.0 128.00 0.0000 0.0000 0.0000 0.0000 1152.0 0.0000 1234.0 0.0000 0.0000 1152.0 0.0000 0.0000 1234.0 0.0000
< new String("str"): 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000
< 
-
> testOneOperator("^")
< ^
< undefined: 0.0000 0.0000 0.0000 1.0000 0.0000 1.0000 -128.00 1234.0 -1.0000e+7 0.0000 0.0000 0.0000 0.0000 -128.00 1.0000 1234.0 0.0000 0.0000 -128.00 0.0000 1.0000 1234.0 0.0000
< null: 0.0000 0.0000 0.0000 1.0000 0.0000 1.0000 -128.00 1234.0 -1.0000e+7 0.0000 0.0000 0.0000 0.0000 -128.00 1.0000 1234.0 0.0000 0.0000 -128.00 0.0000 1.0000 1234.0 0.0000
< false: 0.0000 0.0000 0.0000 1.0000 0.0000 1.0000 -128.00 1234.0 -1.0000e+7 0.0000 0.0000 0.0000 0.0000 -128.00 1.0000 1234.0 0.0000 0.0000 -128.00 0.0000 1.0000 1234.0 0.0000
< true: 1.0000 1.0000 1.0000 0.0000 1.0000 0.0000 -127.00 1235.0 -1.0000e+7 1.0000 1.0000 1.0000 1.0000 -127.00 0.0000 1235.0 1.0000 1.0000 -127.00 1.0000 0.0000 1235.0 1.0000
< 0: 0.0000 0.0000 0.0000 1.0000 0.0000 1.0000 -128.00 1234.0 -1.0000e+7 0.0000 0.0000 0.0000 0.0000 -128.00 1.0000 1234.0 0.0000 0.0000 -128.00 0.0000 1.0000 1234.0 0.0000
< 1: 1.0000 1.0000 1.0000 0.0000 1.0000 0.0000 -127.00 1235.0 -1.0000e+7 1.0000 1.0000 1.0000 1.0000 -127.00 0.0000 1235.0 1.0000 1.0000 -127.00 1.0000 0.0000 1235.0 1.0000
< -128: -128.00 -128.00 -128.00 -127.00 -128.00 -127.00 0.0000 -1198.0 9.9999e+6 -128.00 -128.00 -128.00 -128.00 0.0000 -127.00 -1198.0 -128.00 -128.00 0.0000 -128.00 -127.00 -1198.0 -128.00
< 1234.5678: 1234.0 1234.0 1234.0 1235.0 1234.0 1235.0 -1198.0 0.0000 -9.9990e+6 1234.0 1234.0 1234.0 1234.0 -1198.0 1235.0 0.0000 1234.0 1234.0 -1198.0 1234.0 1235.0 0.0000 1234.0
< -1.0e+7: -1.0000e+7 -1.0000e+7 -1.0000e+7 -1.0000e+7 -1.0000e+7 -1.0000e+7 9.9999e+6 -9.9990e+6 0.0000 -1.0000e+7 -1.0000e+7 -1.0000e+7 -1.0000e+7 9.9999e+6 -1.0000e+7 -9.9990e+6 -1.0000e+7 -1.0000e+7 9.9999e+6 -1.0000e+7 -1.0000e+7 -9.9990e+6 -1.0000e+7
< NaN: 0.0000 0.0000 0.0000 1.0000 0.0000 1.0000 -128.00 1234.0 -1.0000e+7 0.0000 0.0000 0.0000 0.0000 -128.00 1.0000 1234.0 0.0000 0.0000 -128.00 0.0000 1.0000 1234.0 0.0000
< Infinity: 0.0000 0.0000 0.0000 1.0000 0.0000 1.0000 -128.00 1234.0 -1.0000e+7 0.0000 0.0000 0.0000 0.0000 -128.00 1.0000 1234.0 0.0000 0.0000 -128.00 0.0000 1.0000 1234.0 0.0000
< "": 0.0000 0.0000 0.0000 1.0000 0.0000 1.0000 -128.00 1234.0 -1.0000e+7 0.0000 0.0000 0.0000 0.0000 -128.00 1.0000 1234.0 0.0000 0.0000 -128.00 0.0000 1.0000 1234.0 0.0000
< "str": 0.0000 0.0000 0.0000 1.0000 0.0000 1.0000 -128.00 1234.0 -1.0000e+7 0.0000 0.0000 0.0000 0.0000 -128.00 1.0000 1234.0 0.0000 0.0000 -128.00 0.0000 1.0000 1234.0 0.0000
< "-128": -128.00 -128.00 -128.00 -127.00 -128.00 -127.00 0.0000 -1198.0 9.9999e+6 -128.00 -128.00 -128.00 -128.00 0.0000 -127.00 -1198.0 -128.00 -128.00 0.0000 -128.00 -127.00 -1198.0 -128.00
< "1.0": 1.0000 1.0000 1.0000 0.0000 1.0000 0.0000 -127.00 1235.0 -1.0000e+7 1.0000 1.0000 1.0000 1.0000 -127.00 0.0000 1235.0 1.0000 1.0000 -127.00 1.0000 0.0000 1235.0 1.0000
< "  +1234  ": 1234.0 1234.0 1234.0 1235.0 1234.0 1235.0 -1198.0 0.0000 -9.9990e+6 1234.0 1234.0 1234.0 1234.0 -1198.0 1235.0 0.0000 1234.0 1234.0 -1198.0 1234.0 1235.0 0.0000 1234.0
< "string": 0.0000 0.0000 0.0000 1.0000 0.0000 1.0000 -128.00 1234.0 -1.0000e+7 0.0000 0.0000 0.0000 0.0000 -128.00 1.0000 1234.0 0.0000 0.0000 -128.00 0.0000 1.0000 1234.0 0.0000
< "5tring": 0.0000 0.0000 0.0000 1.0000 0.0000 1.0000 -128.00 1234.0 -1.0000e+7 0.0000 0.0000 0.0000 0.0000 -128.00 1.0000 1234.0 0.0000 0.0000 -128.00 0.0000 1.0000 1234.0 0.0000
< ({valueOf:function(){return "-128"}}): -128.00 -128.00 -128.00 -127.00 -128.00 -127.00 0.0000 -1198.0 9.9999e+6 -128.00 -128.00 -128.00 -128.00 0.0000 -127.00 -1198.0 -128.00 -128.00 0.0000 -128.00 -127.00 -1198.0 -128.00
< ({valueOf:function(){return null}}): 0.0000 0.0000 0.0000 1.0000 0.0000 1.0000 -128.00 1234.0 -1.0000e+7 0.0000 0.0000 0.0000 0.0000 -128.00 1.0000 1234.0 0.0000 0.0000 -128.00 0.0000 1.0000 1234.0 0.0000
< new Boolean(true): 1.0000 1.0000 1.0000 0.0000 1.0000 0.0000 -127.00 1235.0 -1.0000e+7 1.0000 1.0000 1.0000 1.0000 -127.00 0.0000 1235.0 1.0000 1.0000 -127.00 1.0000 0.0000 1235.0 1.0000
< new Number(1234.5678): 1234.0 1234.0 1234.0 1235.0 1234.0 1235.0 -1198.0 0.0000 -9.9990e+6 1234.0 1234.0 1234.0 1234.0 -1198.0 1235.0 0.0000 1234.0 1234.0 -1198.0 1234.0 1235.0 0.0000 1234.0
< new String("str"): 0.0000 0.0000 0.0000 1.0000 0.0000 1.0000 -128.00 1234.0 -1.0000e+7 0.0000 0.0000 0.0000 0.0000 -128.00 1.0000 1234.0 0.0000 0.0000 -128.00 0.0000 1.0000 1234.0 0.0000
< 
-
> testOneOperator("|")
< |
< undefined: 0.0000 0.0000 0.0000 1.0000 0.0000 1.0000 -128.00 1234.0 -1.0000e+7 0.0000 0.0000 0.0000 0.0000 -128.00 1.0000 1234.0 0.0000 0.0000 -128.00 0.0000 1.0000 1234.0 0.0000
< null: 0.0000 0.0000 0.0000 1.0000 0.0000 1.0000 -128.00 1234.0 -1.0000e+7 0.0000 0.0000 0.0000 0.0000 -128.00 1.0000 1234.0 0.0000 0.0000 -128.00 0.0000 1.0000 1234.0 0.0000
< false: 0.0000 0.0000 0.0000 1.0000 0.0000 1.0000 -128.00 1234.0 -1.0000e+7 0.0000 0.0000 0.0000 0.0000 -128.00 1.0000 1234.0 0.0000 0.0000 -128.00 0.0000 1.0000 1234.0 0.0000
< true: 1.0000 1.0000 1.0000 1.0000 1.0000 1.0000 -127.00 1235.0 -1.0000e+7 1.0000 1.0000 1.0000 1.0000 -127.00 1.0000 1235.0 1.0000 1.0000 -127.00 1.0000 1.0000 1235.0 1.0000
< 0: 0.0000 0.0000 0.0000 1.0000 0.0000 1.0000 -128.00 1234.0 -1.0000e+7 0.0000 0.0000 0.0000 0.0000 -128.00 1.0000 1234.0 0.0000 0.0000 -128.00 0.0000 1.0000 1234.0 0.0000
< 1: 1.0000 1.0000 1.0000 1.0000 1.0000 1.0000 -127.00 1235.0 -1.0000e+7 1.0000 1.0000 1.0000 1.0000 -127.00 1.0000 1235.0 1.0000 1.0000 -127.00 1.0000 1.0000 1235.0 1.0000
< -128: -128.00 -128.00 -128.00 -127.00 -128.00 -127.00 -128.00 -46.000 -128.00 -128.00 -128.00 -128.00 -128.00 -128.00 -127.00 -46.000 -128.00 -128.00 -128.00 -128.00 -127.00 -46.000 -128.00
< 1234.5678: 1234.0 1234.0 1234.0 1235.0 1234.0 1235.0 -46.000 1234.0 -9.9989e+6 1234.0 1234.0 1234.0 1234.0 -46.000 1235.0 1234.0 1234.0 1234.0 -46.000 1234.0 1235.0 1234.0 1234.0
< -1.0e+7: -1.0000e+7 -1.0000e+7 -1.0000e+7 -1.0000e+7 -1.0000e+7 -1.0000e+7 -128.00 -9.9989e+6 -1.0000e+7 -1.0000e+7 -1.0000e+7 -1.0000e+7 -1.0000e+7 -128.00 -1.0000e+7 -9.9989e+6 -1.0000e+7 -1.0000e+7 -128.00 -1.0000e+7 -1.0000e+7 -9.9989e+6 -1.0000e+7
< NaN: 0.0000 0.0000 0.0000 1.0000 0.0000 1.0000 -128.00 1234.0 -1.0000e+7 0.0000 0.0000 0.0000 0.0000 -128.00 1.0000 1234.0 0.0000 0.0000 -128.00 0.0000 1.0000 1234.0 0.0000
< Infinity: 0.0000 0.0000 0.0000 1.0000 0.0000 1.0000 -128.00 1234.0 -1.0000e+7 0.0000 0.0000 0.0000 0.0000 -128.00 1.0000 1234.0 0.0000 0.0000 -128.00 0.0000 1.0000 1234.0 0.0000
< "": 0.0000 0.0000 0.0000 1.0000 0.0000 1.0000 -128.00 1234.0 -1.0000e+7 0.0000 0.0000 0.0000 0.0000 -128.00 1.0000 1234.0 0.0000 0.0000 -128.00 0.0000 1.0000 1234.0 0.0000
< "str": 0.0000 0.0000 0.0000 1.0000 0.0000 1.0000 -128.00 1234.0 -1.0000e+7 0.0000 0.0000 0.0000 0.0000 -128.00 1.0000 1234.0 0.0000 0.0000 -128.00 0.0000 1.0000 1234.0 0.0000
< "-128": -128.00 -128.00 -128.00 -127.00 -128.00 -127.00 -128.00 -46.000 -128.00 -128.00 -128.00 -128.00 -128.00 -128.00 -127.00 -46.000 -128.00 -128.00 -128.00 -128.00 -127.00 -46.000 -128.00
< "1.0": 1.0000 1.0000 1.0000 1.0000 1.0000 1.0000 -127.00 1235.0 -1.0000e+7 1.0000 1.0000 1.0000 1.0000 -127.00 1.0000 1235.0 1.0000 1.0000 -127.00 1.0000 1.0000 1235.0 1.0000
< "  +1234  ": 1234.0 1234.0 1234.0 1235.0 1234.0 1235.0 -46.000 1234.0 -9.9989e+6 1234.0 1234.0 1234.0 1234.0 -46.000 1235.0 1234.0 1234.0 1234.0 -46.000 1234.0 1235.0 1234.0 1234.0
< "string": 0.0000 0.0000 0.0000 1.0000 0.0000 1.0000 -128.00 1234.0 -1.0000e+7 0.0000 0.0000 0.0000 0.0000 -128.00 1.0000 1234.0 0.0000 0.0000 -128.00 0.0000 1.0000 1234.0 0.0000
< "5tring": 0.0000 0.0000 0.0000 1.0000 0.0000 1.0000 -128.00 1234.0 -1.0000e+7 0.0000 0.0000 0.0000 0.0000 -128.00 1.0000 1234.0 0.0000 0.0000 -128.00 0.0000 1.0000 1234.0 0.0000
< ({valueOf:function(){return "-128"}}): -128.00 -128.00 -128.00 -127.00 -128.00 -127.00 -128.00 -46.000 -128.00 -128.00 -128.00 -128.00 -128.00 -128.00 -127.00 -46.000 -128.00 -128.00 -128.00 -128.00 -127.00 -46.000 -128.00
< ({valueOf:function(){return null}}): 0.0000 0.0000 0.0000 1.0000 0.0000 1.0000 -128.00 1234.0 -1.0000e+7 0.0000 0.0000 0.0000 0.0000 -128.00 1.0000 1234.0 0.0000 0.0000 -128.00 0.0000 1.0000 1234.0 0.0000
< new Boolean(true): 1.0000 1.0000 1.0000 1.0000 1.0000 1.0000 -127.00 1235.0 -1.0000e+7 1.0000 1.0000 1.0000 1.0000 -127.00 1.0000 1235.0 1.0000 1.0000 -127.00 1.0000 1.0000 1235.0 1.0000
< new Number(1234.5678): 1234.0 1234.0 1234.0 1235.0 1234.0 1235.0 -46.000 1234.0 -9.9989e+6 1234.0 1234.0 1234.0 1234.0 -46.000 1235.0 1234.0 1234.0 1234.0 -46.000 1234.0 1235.0 1234.0 1234.0
< new String("str"): 0.0000 0.0000 0.0000 1.0000 0.0000 1.0000 -128.00 1234.0 -1.0000e+7 0.0000 0.0000 0.0000 0.0000 -128.00 1.0000 1234.0 0.0000 0.0000 -128.00 0.0000 1.0000 1234.0 0.0000
< 
-
> testOneOperator("<<")
< <<
< undefined: 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000
< null: 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000
< false: 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000
< true: 1.0000 1.0000 1.0000 2.0000 1.0000 2.0000 1.0000 2.6214e+5 1.0000 1.0000 1.0000 1.0000 1.0000 1.0000 2.0000 2.6214e+5 1.0000 1.0000 1.0000 1.0000 2.0000 2.6214e+5 1.0000
< 0: 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000
< 1: 1.0000 1.0000 1.0000 2.0000 1.0000 2.0000 1.0000 2.6214e+5 1.0000 1.0000 1.0000 1.0000 1.0000 1.0000 2.0000 2.6214e+5 1.0000 1.0000 1.0000 1.0000 2.0000 2.6214e+5 1.0000
< -128: -128.00 -128.00 -128.00 -256.00 -128.00 -256.00 -128.00 -3.3554e+7 -128.00 -128.00 -128.00 -128.00 -128.00 -128.00 -256.00 -3.3554e+7 -128.00 -128.00 -128.00 -128.00 -256.00 -3.3554e+7 -128.00
< 1234.5678: 1234.0 1234.0 1234.0 2468.0 1234.0 2468.0 1234.0 3.2349e+8 1234.0 1234.0 1234.0 1234.0 1234.0 1234.0 2468.0 3.2349e+8 1234.0 1234.0 1234.0 1234.0 2468.0 3.2349e+8 1234.0
< -1.0e+7: -1.0000e+7 -1.0000e+7 -1.0000e+7 -2.0000e+7 -1.0000e+7 -2.0000e+7 -1.0000e+7 -1.5099e+9 -1.0000e+7 -1.0000e+7 -1.0000e+7 -1.0000e+7 -1.0000e+7 -1.0000e+7 -2.0000e+7 -1.5099e+9 -1.0000e+7 -1.0000e+7 -1.0000e+7 -1.0000e+7 -2.0000e+7 -1.5099e+9 -1.0000e+7
< NaN: 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000
< Infinity: 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000
< "": 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000
< "str": 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000
< "-128": -128.00 -128.00 -128.00 -256.00 -128.00 -256.00 -128.00 -3.3554e+7 -128.00 -128.00 -128.00 -128.00 -128.00 -128.00 -256.00 -3.3554e+7 -128.00 -128.00 -128.00 -128.00 -256.00 -3.3554e+7 -128.00
< "1.0": 1.0000 1.0000 1.0000 2.0000 1.0000 2.0000 1.0000 2.6214e+5 1.0000 1.0000 1.0000 1.0000 1.0000 1.0000 2.0000 2.6214e+5 1.0000 1.0000 1.0000 1.0000 2.0000 2.6214e+5 1.0000
< "  +1234  ": 1234.0 1234.0 1234.0 2468.0 1234.0 2468.0 1234.0 3.2349e+8 1234.0 1234.0 1234.0 1234.0 1234.0 1234.0 2468.0 3.2349e+8 1234.0 1234.0 1234.0 1234.0 2468.0 3.2349e+8 1234.0
< "string": 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000
< "5tring": 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000
< ({valueOf:function(){return "-128"}}): -128.00 -128.00 -128.00 -256.00 -128.00 -256.00 -128.00 -3.3554e+7 -128.00 -128.00 -128.00 -128.00 -128.00 -128.00 -256.00 -3.3554e+7 -128.00 -128.00 -128.00 -128.00 -256.00 -3.3554e+7 -128.00
< ({valueOf:function(){return null}}): 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000
< new Boolean(true): 1.0000 1.0000 1.0000 2.0000 1.0000 2.0000 1.0000 2.6214e+5 1.0000 1.0000 1.0000 1.0000 1.0000 1.0000 2.0000 2.6214e+5 1.0000 1.0000 1.0000 1.0000 2.0000 2.6214e+5 1.0000
< new Number(1234.5678): 1234.0 1234.0 1234.0 2468.0 1234.0 2468.0 1234.0 3.2349e+8 1234.0 1234.0 1234.0 1234.0 1234.0 1234.0 2468.0 3.2349e+8 1234.0 1234.0 1234.0 1234.0 2468.0 3.2349e+8 1234.0
< new String("str"): 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000
< 
-
> testOneOperator(">>")
< >>
< undefined: 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000
< null: 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000
< false: 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000
< true: 1.0000 1.0000 1.0000 0.0000 1.0000 0.0000 1.0000 0.0000 1.0000 1.0000 1.0000 1.0000 1.0000 1.0000 0.0000 0.0000 1.0000 1.0000 1.0000 1.0000 0.0000 0.0000 1.0000
< 0: 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000
< 1: 1.0000 1.0000 1.0000 0.0000 1.0000 0.0000 1.0000 0.0000 1.0000 1.0000 1.0000 1.0000 1.0000 1.0000 0.0000 0.0000 1.0000 1.0000 1.0000 1.0000 0.0000 0.0000 1.0000
< -128: -128.00 -128.00 -128.00 -64.000 -128.00 -64.000 -128.00 -1.0000 -128.00 -128.00 -128.00 -128.00 -128.00 -128.00 -64.000 -1.0000 -128.00 -128.00 -128.00 -128.00 -64.000 -1.0000 -128.00
< 1234.5678: 1234.0 1234.0 1234.0 617.00 1234.0 617.00 1234.0 0.0000 1234.0 1234.0 1234.0 1234.0 1234.0 1234.0 617.00 0.0000 1234.0 1234.0 1234.0 1234.0 617.00 0.0000 1234.0
< -1.0e+7: -1.0000e+7 -1.0000e+7 -1.0000e+7 -5.0000e+6 -1.0000e+7 -5.0000e+6 -1.0000e+7 -39.000 -1.0000e+7 -1.0000e+7 -1.0000e+7 -1.0000e+7 -1.0000e+7 -1.0000e+7 -5.0000e+6 -39.000 -1.0000e+7 -1.0000e+7 -1.0000e+7 -1.0000e+7 -5.0000e+6 -39.000 -1.0000e+7
< NaN: 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000
< Infinity: 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000
< "": 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000
< "str": 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000
< "-128": -128.00 -128.00 -128.00 -64.000 -128.00 -64.000 -128.00 -1.0000 -128.00 -128.00 -128.00 -128.00 -128.00 -128.00 -64.000 -1.0000 -128.00 -128.00 -128.00 -128.00 -64.000 -1.0000 -128.00
< "1.0": 1.0000 1.0000 1.0000 0.0000 1.0000 0.0000 1.0000 0.0000 1.0000 1.0000 1.0000 1.0000 1.0000 1.0000 0.0000 0.0000 1.0000 1.0000 1.0000 1.0000 0.0000 0.0000 1.0000
< "  +1234  ": 1234.0 1234.0 1234.0 617.00 1234.0 617.00 1234.0 0.0000 1234.0 1234.0 1234.0 1234.0 1234.0 1234.0 617.00 0.0000 1234.0 1234.0 1234.0 1234.0 617.00 0.0000 1234.0
< "string": 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000
< "5tring": 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000
< ({valueOf:function(){return "-128"}}): -128.00 -128.00 -128.00 -64.000 -128.00 -64.000 -128.00 -1.0000 -128.00 -128.00 -128.00 -128.00 -128.00 -128.00 -64.000 -1.0000 -128.00 -128.00 -128.00 -128.00 -64.000 -1.0000 -128.00
< ({valueOf:function(){return null}}): 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000
< new Boolean(true): 1.0000 1.0000 1.0000 0.0000 1.0000 0.0000 1.0000 0.0000 1.0000 1.0000 1.0000 1.0000 1.0000 1.0000 0.0000 0.0000 1.0000 1.0000 1.0000 1.0000 0.0000 0.0000 1.0000
< new Number(1234.5678): 1234.0 1234.0 1234.0 617.00 1234.0 617.00 1234.0 0.0000 1234.0 1234.0 1234.0 1234.0 1234.0 1234.0 617.00 0.0000 1234.0 1234.0 1234.0 1234.0 617.00 0.0000 1234.0
< new String("str"): 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000
< 
-
> testOneOperator(">>>")
< >>>
< undefined: 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000
< null: 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000
< false: 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000
< true: 1.0000 1.0000 1.0000 0.0000 1.0000 0.0000 1.0000 0.0000 1.0000 1.0000 1.0000 1.0000 1.0000 1.0000 0.0000 0.0000 1.0000 1.0000 1.0000 1.0000 0.0000 0.0000 1.0000
< 0: 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000
< 1: 1.0000 1.0000 1.0000 0.0000 1.0000 0.0000 1.0000 0.0000 1.0000 1.0000 1.0000 1.0000 1.0000 1.0000 0.0000 0.0000 1.0000 1.0000 1.0000 1.0000 0.0000 0.0000 1.0000
< -128: 4.2950e+9 4.2950e+9 4.2950e+9 2.1475e+9 4.2950e+9 2.1475e+9 4.2950e+9 16383 4.2950e+9 4.2950e+9 4.2950e+9 4.2950e+9 4.2950e+9 4.2950e+9 2.1475e+9 16383 4.2950e+9 4.2950e+9 4.2950e+9 4.2950e+9 2.1475e+9 16383 4.2950e+9
< 1234.5678: 1234.0 1234.0 1234.0 617.00 1234.0 617.00 1234.0 0.0000 1234.0 1234.0 1234.0 1234.0 1234.0 1234.0 617.00 0.0000 1234.0 1234.0 1234.0 1234.0 617.00 0.0000 1234.0
< -1.0e+7: 4.2850e+9 4.2850e+9 4.2850e+9 2.1425e+9 4.2850e+9 2.1425e+9 4.2850e+9 16345 4.2850e+9 4.2850e+9 4.2850e+9 4.2850e+9 4.2850e+9 4.2850e+9 2.1425e+9 16345 4.2850e+9 4.2850e+9 4.2850e+9 4.2850e+9 2.1425e+9 16345 4.2850e+9
< NaN: 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000
< Infinity: 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000
< "": 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000
< "str": 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000
< "-128": 4.2950e+9 4.2950e+9 4.2950e+9 2.1475e+9 4.2950e+9 2.1475e+9 4.2950e+9 16383 4.2950e+9 4.2950e+9 4.2950e+9 4.2950e+9 4.2950e+9 4.2950e+9 2.1475e+9 16383 4.2950e+9 4.2950e+9 4.2950e+9 4.2950e+9 2.1475e+9 16383 4.2950e+9
< "1.0": 1.0000 1.0000 1.0000 0.0000 1.0000 0.0000 1.0000 0.0000 1.0000 1.0000 1.0000 1.0000 1.0000 1.0000 0.0000 0.0000 1.0000 1.0000 1.0000 1.0000 0.0000 0.0000 1.0000
< "  +1234  ": 1234.0 1234.0 1234.0 617.00 1234.0 617.00 1234.0 0.0000 1234.0 1234.0 1234.0 1234.0 1234.0 1234.0 617.00 0.0000 1234.0 1234.0 1234.0 1234.0 617.00 0.0000 1234.0
< "string": 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000
< "5tring": 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000
< ({valueOf:function(){return "-128"}}): 4.2950e+9 4.2950e+9 4.2950e+9 2.1475e+9 4.2950e+9 2.1475e+9 4.2950e+9 16383 4.2950e+9 4.2950e+9 4.2950e+9 4.2950e+9 4.2950e+9 4.2950e+9 2.1475e+9 16383 4.2950e+9 4.2950e+9 4.2950e+9 4.2950e+9 2.1475e+9 16383 4.2950e+9
< ({valueOf:function(){return null}}): 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000
< new Boolean(true): 1.0000 1.0000 1.0000 0.0000 1.0000 0.0000 1.0000 0.0000 1.0000 1.0000 1.0000 1.0000 1.0000 1.0000 0.0000 0.0000 1.0000 1.0000 1.0000 1.0000 0.0000 0.0000 1.0000
< new Number(1234.5678): 1234.0 1234.0 1234.0 617.00 1234.0 617.00 1234.0 0.0000 1234.0 1234.0 1234.0 1234.0 1234.0 1234.0 617.00 0.0000 1234.0 1234.0 1234.0 1234.0 617.00 0.0000 1234.0
< new String("str"): 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000
< 
-
