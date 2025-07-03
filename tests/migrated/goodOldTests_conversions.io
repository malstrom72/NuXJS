> // Valids:
> print(+"");
> print(+"0");
> print(+"000");
> print(+"0123");
> print(+"12345");
> print(+"+12345");
> print(+"-12345");
> print(+"+12345.57685");
> print(+"+12345.57685e10");
> print(+"+12345.57685e+10");
> print(+"+12345.57685e-10");
> print(+"+12345.57685E-10");
> print(+" +12345.57685E-10");
> print(+"+12345.57685E-10 ");
> print(+"  \n  \r +12345.57685E-10   \v \t ");
> print(+"  \n  \r 0x0   \v \t ");
> print(+"  \n  \r 0xDE   \v \t ");
> print(+"  \n  \r 0xAA55AA55   \v \t ");
> print(+"Infinity");
> print(+"+Infinity");
> print(+"-Infinity");
< 0
< 0
< 0
< 123
< 12345
< 12345
< -12345
< 12345.57685
< 123455768500000
< 123455768500000
< 0.000001234557685
< 0.000001234557685
< 0.000001234557685
< 0.000001234557685
< 0.000001234557685
< 0
< 222
< 2857740885
< Infinity
< Infinity
< -Infinity
-
> // Invalids:
> print(+"  \n  \r -0xAA55AA55   \v \t ");
> print(+"k");
> print(+"5k");
> print(+"+ 5");
< NaN
< NaN
< NaN
< NaN
-
> function ValueObject(v) {
>     this.valueOf = function() { return v };
> };
-
> print((new ValueObject(33)) + (new ValueObject(55)));
> print((new ValueObject(33)) + (new ValueObject("55")));
> print((new ValueObject("62456")) + (new ValueObject(23452)));
> print((new ValueObject(76)) - (new ValueObject(23)));
> print((new ValueObject(35)) * (new ValueObject("123")));
> print((new ValueObject("1574.4")) / (new ValueObject(12.3)));
> print((new ValueObject(329329)) % (new ValueObject(127)));
> print((new ValueObject(55)) & (new ValueObject(27)));
> print((new ValueObject(-439)) | (new ValueObject(33)));
> print((new ValueObject(123)) ^ (new ValueObject(243)));
> print((new ValueObject(4398)) << (new ValueObject(5)));
> print((new ValueObject(129384)) >> (new ValueObject(3)));
> print((new ValueObject(-348234)) >>> (new ValueObject(11)));
> print((new ValueObject(1234)) < (new ValueObject(1235)));
> print((new ValueObject(1234)) < (new ValueObject(1234)));
> print((new ValueObject(1234)) <= (new ValueObject(1235)));
> print((new ValueObject(1234)) <= (new ValueObject("1234.0")));
> print((new ValueObject(1235)) > (new ValueObject(1234)));
> print((new ValueObject(1234)) > (new ValueObject(1234)));
> print((new ValueObject(1235)) >= (new ValueObject(1234)));
> print((new ValueObject("1234.0")) >= (new ValueObject(1234)));
> print((new ValueObject("1234")) > (new ValueObject("1234.0")));
> print((new ValueObject("1234")) >= (new ValueObject("1234.0")));
> print((new ValueObject("1234")) < (new ValueObject("1234.0")));
> print((new ValueObject("1234")) <= (new ValueObject("1234.0")));
> print((new ValueObject("1234")) == (new ValueObject(1234.0)));
> print((new ValueObject("1234")) == (new ValueObject(1234.1)));
> print((new ValueObject("1234")) != (new ValueObject("1234.0")));
> print((new ValueObject(1234)) != (new ValueObject(1234.0)));
> var v = new ValueObject(1234);
> print(v == v);
> print(v != v);
< 88
< 3355
< 6245623452
< 53
< 4305
< 128
< 18
< 19
< -407
< 136
< 140736
< 16173
< 2096981
< true
< false
< true
< true
< true
< false
< true
< true
< false
< false
< true
< true
< false
< false
< true
< true
< true
< false
-
> print(33 + (new ValueObject(55)));
> print(33 + (new ValueObject("55")));
> print("62456" + (new ValueObject(23452)));
> print(76 - (new ValueObject(23)));
> print(35 * (new ValueObject("123")));
> print("1574.4" / (new ValueObject(12.3)));
> print(329329 % (new ValueObject(127)));
> print(55 & (new ValueObject(27)));
> print(-439 | (new ValueObject(33)));
> print(123 ^ (new ValueObject(243)));
> print(4398 << (new ValueObject(5)));
> print(129384 >> (new ValueObject(3)));
> print(-348234 >>> (new ValueObject(11)));
> print(1234 < (new ValueObject(1235)));
> print(1234 < (new ValueObject(1234)));
> print(1234 <= (new ValueObject(1235)));
> print(1234 <= (new ValueObject("1234.0")));
> print(1235 > (new ValueObject(1234)));
> print(1234 > (new ValueObject(1234)));
> print(1235 >= (new ValueObject(1234)));
> print("1234.0" >= (new ValueObject(1234)));
> print("1234.0" >= (new ValueObject(1234)));
> print("1234" > (new ValueObject("1234.0")));
> print("1234" >= (new ValueObject("1234.0")));
> print("1234" < (new ValueObject("1234.0")));
> print("1234" <= (new ValueObject("1234.0")));
> print("1234" == (new ValueObject(1234.0)));
> print("1234" == (new ValueObject(1234.1)));
> print("1234" != (new ValueObject("1234.0")));
> print(1234 != (new ValueObject(1234.0)));
< 88
< 3355
< 6245623452
< 53
< 4305
< 128
< 18
< 19
< -407
< 136
< 140736
< 16173
< 2096981
< true
< false
< true
< true
< true
< false
< true
< true
< true
< false
< false
< true
< true
< true
< false
< true
< false
-
> print((new ValueObject(33)) + 55);
> print((new ValueObject(33)) + "55");
> print((new ValueObject("62456")) + 23452);
> print((new ValueObject(76)) - 23);
> print((new ValueObject(35)) * "123");
> print((new ValueObject("1574.4")) / 12.3);
> print((new ValueObject(329329)) % 127);
> print((new ValueObject(55)) & 27);
> print((new ValueObject(-439)) | 33);
> print((new ValueObject(123)) ^ 243);
> print((new ValueObject(4398)) << 5);
> print((new ValueObject(129384)) >> 3);
> print((new ValueObject(-348234)) >>> 11);
> print((new ValueObject(1234)) < 1235);
> print((new ValueObject(1234)) < 1234);
> print((new ValueObject(1234)) <= 1235);
> print((new ValueObject(1234)) <= "1234.0");
> print((new ValueObject(1235)) > 1234);
> print((new ValueObject(1234)) > 1234);
> print((new ValueObject(1235)) >= 1234);
> print((new ValueObject("1234.0")) >= 1234);
> print((new ValueObject("1234")) > "1234.0");
> print((new ValueObject("1234")) >= "1234.0");
> print((new ValueObject("1234")) < "1234.0");
> print((new ValueObject("1234")) <= "1234.0");
> print((new ValueObject("1234")) == 1234.0);
> print((new ValueObject("1234")) == 1234.1);
> print((new ValueObject("1234")) != "1234.0");
> print((new ValueObject(1234)) != 1234.0);
< 88
< 3355
< 6245623452
< 53
< 4305
< 128
< 18
< 19
< -407
< 136
< 140736
< 16173
< 2096981
< true
< false
< true
< true
< true
< false
< true
< true
< false
< false
< true
< true
< true
< false
< true
< false
-
> print(+new ValueObject(239423.2349));
> print(+new ValueObject("239423.2349"));
> print(-new ValueObject(238742));
> print(-new ValueObject("238742"));
> print(~new ValueObject(-3492384));
> print(~new ValueObject("-3492384"));
< 239423.2349
< 239423.2349
< -238742
< -238742
< 3492383
< 3492383
-
> var v = new ValueObject(123);
> print(typeof v);
> print(v++);
> print(typeof v);
> print(v);
> v = new ValueObject(v);
> print(typeof v);
> print(++v);
> print(typeof v);
< object
< 123
< number
< 124
< object
< 125
< number
-
> v = new ValueObject(v);
> print(typeof v);
> print(v--);
> print(typeof v);
> print(v);
> v = new ValueObject(v);
> print(typeof v);
> print(--v);
> print(typeof v);
< object
< 125
< number
< 124
< object
< 123
< number
-
> o = new ValueObject(12345); print(typeof o); print(o += 6789); print(typeof o); print(o); o = new ValueObject(o); print(typeof o); print(o += (new ValueObject(6789))); print(typeof o); print(o);
> o = new ValueObject(12345); print(typeof o); print(o -= 6789); print(typeof o); print(o); o = new ValueObject(o); print(typeof o); print(o -= (new ValueObject(6789))); print(typeof o); print(o);
> o = new ValueObject(12345); print(typeof o); print(o *= 6789); print(typeof o); print(o); o = new ValueObject(o); print(typeof o); print(o *= (new ValueObject(6789))); print(typeof o); print(o);
> o = new ValueObject(15744); print(typeof o); print(o /= 123); print(typeof o); print(o); o = new ValueObject(o); print(typeof o); print(o /= (new ValueObject(64))); print(typeof o); print(o);
> o = new ValueObject(12345); print(typeof o); print(o %= 6789); print(typeof o); print(o); o = new ValueObject(o); print(typeof o); print(o %= (new ValueObject(1748))); print(typeof o); print(o);
> o = new ValueObject(12345); print(typeof o); print(o &= 6789); print(typeof o); print(o); o = new ValueObject(o); print(typeof o); print(o &= (new ValueObject(374))); print(typeof o); print(o);
> o = new ValueObject(12345); print(typeof o); print(o |= 6789); print(typeof o); print(o); o = new ValueObject(o); print(typeof o); print(o |= (new ValueObject(13764))); print(typeof o); print(o);
> o = new ValueObject(12345); print(typeof o); print(o ^= 6789); print(typeof o); print(o); o = new ValueObject(o); print(typeof o); print(o ^= (new ValueObject(34857))); print(typeof o); print(o);
> o = new ValueObject(12345); print(typeof o); print(o >>= 5); print(typeof o); print(o); o = new ValueObject(o); print(typeof o); print(o >>= (new ValueObject(5))); print(typeof o); print(o);
> o = new ValueObject(12345); print(typeof o); print(o <<= 5); print(typeof o); print(o); o = new ValueObject(o); print(typeof o); print(o <<= (new ValueObject(5))); print(typeof o); print(o);
> o = new ValueObject(-12345); print(typeof o); print(o >>>= 5); print(typeof o); print(o); o = new ValueObject(o); print(typeof o); print(o >>>= (new ValueObject(5))); print(typeof o); print(o);
< object
< 19134
< number
< 19134
< object
< 25923
< number
< 25923
< object
< 5556
< number
< 5556
< object
< -1233
< number
< -1233
< object
< 83810205
< number
< 83810205
< object
< 568987481745
< number
< 568987481745
< object
< 128
< number
< 128
< object
< 2
< number
< 2
< object
< 5556
< number
< 5556
< object
< 312
< number
< 312
< object
< 4097
< number
< 4097
< object
< 0
< number
< 0
< object
< 15037
< number
< 15037
< object
< 16381
< number
< 16381
< object
< 10940
< number
< 10940
< object
< 41621
< number
< 41621
< object
< 385
< number
< 385
< object
< 12
< number
< 12
< object
< 395040
< number
< 395040
< object
< 12641280
< number
< 12641280
< object
< 134217342
< number
< 134217342
< object
< 4194291
< number
< 4194291
-
> 
-
> o=new (function() { this.valueOf = function() { return 33 } } )
> print(+o);
< 33
-
> OneHundredEleven = function() { this.valueOf = function() { print("click"); return 111 }; this.toString = null; }; o = new OneHundredEleven; print(+o)
> TestObject = function() { };
> TestObject.prototype = new OneHundredEleven;
> o2 = new TestObject; print(+o2)
>  
> AString = function() { this.valueOf = null; this.toString = function() { print("good toString"); return "stringy"; } };
> o = new AString; print(+o)
>  
> StringAgain = function() { this.valueOf = function() { print("bad valueOf"); return this }; this.toString = function() { print("good toString"); return "stringy"; } };
> o = new StringAgain; print(+o);
< click
< 111
< click
< 111
< good toString
< NaN
< bad valueOf
< good toString
< NaN
-
> (function() {
>     var v={toString:void null,valueOf:function(){print("valueOf = 1234");return 1234;}};
>     var o=new Object();
>     o[v]=5678;
>     print(o[1234]);
>     delete v.toString;
>     o[v]=9012;
>     print(o[1234]);
>     print(o["[object Object]"]);
>     v.toString=function(){print('toString = "abcd"');return "abcd";};
>     o[v]="efgh";
>     print(o.abcd);
> })();
< valueOf = 1234
< 5678
< 5678
< 9012
< toString = "abcd"
< efgh
-
> var v = { valueOf: function() { return 'a' } };
> var x = { a: 55 };
> print(delete x[v]);
> print(typeof x.a);
< true
< number
-
> var v = { toString: function() { return "koko" } };
> var o={koko:"koko"};
> print("koko" in o);
> print(v in o);
< true
< true
-
> var a = [];
> a["5.0"]=2384;
> a["5"]=9812;
> print(a[new String("5.0")]);
> print(a[new Number("5.0")]);
< 2384
< 9812
-
