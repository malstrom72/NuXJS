> print("==== switch test ====");
> function switchTest(earlyReturn) {
> 	var tests = [ 1, "a", null, "x", "2.0", 2.0, "x", 4.0, "continue", { }, "x", (earlyReturn ? "return" : "break out"), "never get here" ];
> 	var twoPointZero = 2.0;
> 	var x = 0, y = 0;
> 	loop: for (var i in tests) {
> 		try {
> 			print('{ i: ' + i + ', x:' + x + ', y:' + y);
> 			switch (tests[i]) {
> 				case null: print('null'); break;
> 				case "a": print('"a"');
> 				case 1: print('1'); break;
> 				default: print("default"); break;
> 				case twoPointZero: print('twoPointZero'); break;
> 				case twoPointZero * 2: print('twoPointZero * 2'); break;
> 				case (x++, "x"): print('x: ' + x); break;
> 				case "break out": print("break out"); break loop;
> 				case "return": print("return"); return x * 23;
> 				case "continue": print("continue"); continue;
> 				case ++y: print("++y"); break;
> 			}
> 			print('...');
> 		}
> 		finally {
> 			print('} i: ' + i + ', x:' + x + ', y:' + y);
> 		}
> 	}
> }
> switchTest(false);
> var r = switchTest(true);
> print("r: " + r);
< ==== switch test ====
< { i: 0, x:0, y:0
< 1
< ...
< } i: 0, x:0, y:0
< { i: 1, x:0, y:0
< "a"
< 1
< ...
< } i: 1, x:0, y:0
< { i: 2, x:0, y:0
< null
< ...
< } i: 2, x:0, y:0
< { i: 3, x:0, y:0
< x: 1
< ...
< } i: 3, x:1, y:0
< { i: 4, x:1, y:0
< default
< ...
< } i: 4, x:2, y:1
< { i: 5, x:2, y:1
< twoPointZero
< ...
< } i: 5, x:2, y:1
< { i: 6, x:2, y:1
< x: 3
< ...
< } i: 6, x:3, y:1
< { i: 7, x:3, y:1
< twoPointZero * 2
< ...
< } i: 7, x:3, y:1
< { i: 8, x:3, y:1
< continue
< } i: 8, x:4, y:1
< { i: 9, x:4, y:1
< default
< ...
< } i: 9, x:5, y:2
< { i: 10, x:5, y:2
< x: 6
< ...
< } i: 10, x:6, y:2
< { i: 11, x:6, y:2
< break out
< } i: 11, x:7, y:2
< { i: 0, x:0, y:0
< 1
< ...
< } i: 0, x:0, y:0
< { i: 1, x:0, y:0
< "a"
< 1
< ...
< } i: 1, x:0, y:0
< { i: 2, x:0, y:0
< null
< ...
< } i: 2, x:0, y:0
< { i: 3, x:0, y:0
< x: 1
< ...
< } i: 3, x:1, y:0
< { i: 4, x:1, y:0
< default
< ...
< } i: 4, x:2, y:1
< { i: 5, x:2, y:1
< twoPointZero
< ...
< } i: 5, x:2, y:1
< { i: 6, x:2, y:1
< x: 3
< ...
< } i: 6, x:3, y:1
< { i: 7, x:3, y:1
< twoPointZero * 2
< ...
< } i: 7, x:3, y:1
< { i: 8, x:3, y:1
< continue
< } i: 8, x:4, y:1
< { i: 9, x:4, y:1
< default
< ...
< } i: 9, x:5, y:2
< { i: 10, x:5, y:2
< x: 6
< ...
< } i: 10, x:6, y:2
< { i: 11, x:6, y:2
< return
< } i: 11, x:7, y:2
< r: 161
-
> print("==== eval switch test ====");
> function evalSwitchTest(earlyReturn) {
> 	return eval("\tvar tests = [ 1, \"a\", null, \"x\", \"2.0\", 2.0, \"x\", 4.0, \"continue\", { }, \"x\", (earlyReturn ? \"return\" : \"break out\"), \"never get here\" ];\r\n\tvar twoPointZero = 2.0;\r\n\tvar x = 0, y = 0;\r\n\tloop: for (var i in tests) {\r\n\t\ttry {\r\n\t\t\tprint(\'{ i: \' + i + \', x:\' + x + \', y:\' + y);\r\n\t\t\tswitch (tests[i]) {\r\n\t\t\t\tcase null: print(\'null\'); break;\r\n\t\t\t\tcase \"a\": print(\'\"a\"\');\r\n\t\t\t\tcase 1: print(\'1\'); break;\r\n\t\t\t\tdefault: print(\"default\"); break;\r\n\t\t\t\tcase twoPointZero: print(\'twoPointZero\'); break;\r\n\t\t\t\tcase twoPointZero * 2: print(\'twoPointZero * 2\'); break;\r\n\t\t\t\tcase (x++, \"x\"): print(\'x: \' + x); break;\r\n\t\t\t\tcase \"break out\": print(\"break out\"); break loop;\r\n\t\t\t\tcase \"return\": print(\"return by breaking\"); x * 23; break loop;\r\n\t\t\t\tcase \"continue\": print(\"continue\"); continue;\r\n\t\t\t\tcase ++y: print(\"++y\"); break;\r\n\t\t\t}\r\n\t\t\tprint(\'...\');\r\n\t\t}\r\n\t\tfinally {\r\n\t\t\tprint(\'} i: \' + i + \', x:\' + x + \', y:\' + y);\r\n\"finally\"\r\n\t\t}\r\n\t}\r\n");
> }
> evalSwitchTest(false);
> var r = evalSwitchTest(true);
> print("r: " + r);
< ==== eval switch test ====
< { i: 0, x:0, y:0
< 1
< ...
< } i: 0, x:0, y:0
< { i: 1, x:0, y:0
< "a"
< 1
< ...
< } i: 1, x:0, y:0
< { i: 2, x:0, y:0
< null
< ...
< } i: 2, x:0, y:0
< { i: 3, x:0, y:0
< x: 1
< ...
< } i: 3, x:1, y:0
< { i: 4, x:1, y:0
< default
< ...
< } i: 4, x:2, y:1
< { i: 5, x:2, y:1
< twoPointZero
< ...
< } i: 5, x:2, y:1
< { i: 6, x:2, y:1
< x: 3
< ...
< } i: 6, x:3, y:1
< { i: 7, x:3, y:1
< twoPointZero * 2
< ...
< } i: 7, x:3, y:1
< { i: 8, x:3, y:1
< continue
< } i: 8, x:4, y:1
< { i: 9, x:4, y:1
< default
< ...
< } i: 9, x:5, y:2
< { i: 10, x:5, y:2
< x: 6
< ...
< } i: 10, x:6, y:2
< { i: 11, x:6, y:2
< break out
< } i: 11, x:7, y:2
< { i: 0, x:0, y:0
< 1
< ...
< } i: 0, x:0, y:0
< { i: 1, x:0, y:0
< "a"
< 1
< ...
< } i: 1, x:0, y:0
< { i: 2, x:0, y:0
< null
< ...
< } i: 2, x:0, y:0
< { i: 3, x:0, y:0
< x: 1
< ...
< } i: 3, x:1, y:0
< { i: 4, x:1, y:0
< default
< ...
< } i: 4, x:2, y:1
< { i: 5, x:2, y:1
< twoPointZero
< ...
< } i: 5, x:2, y:1
< { i: 6, x:2, y:1
< x: 3
< ...
< } i: 6, x:3, y:1
< { i: 7, x:3, y:1
< twoPointZero * 2
< ...
< } i: 7, x:3, y:1
< { i: 8, x:3, y:1
< continue
< } i: 8, x:4, y:1
< { i: 9, x:4, y:1
< default
< ...
< } i: 9, x:5, y:2
< { i: 10, x:5, y:2
< x: 6
< ...
< } i: 10, x:6, y:2
< { i: 11, x:6, y:2
< return by breaking
< } i: 11, x:7, y:2
< r: 161
-
