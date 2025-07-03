> print(/a|ab/.exec("abc").toString())
< a
-
> print(/((a)|(ab))((c)|(bc))/.exec("abc").toString())
< abc,a,a,,bc,,bc
-
> print(/a[a-z]{2,4}/.exec("abcdefghi").toString())
< abcde
-
> print(/a[a-z]{2,4}?/.exec("abcdefghi").toString())
< abc
-
> print(/(aa|aabaac|ba|b|c)*/.exec("aabaac").toString())
< aaba,ba
-
> print(/(z)((a+)?(b+)?(c))*/.exec("zaacbbbcac").toString())
< zaacbbbcac,z,ac,a,,c
-
> print(/(a*)*/.exec("b").toString())
< ,
-
> print(/(a*)b\1+/.exec("baaaac").toString())
< b,
-
> print(/(?=(a+))/.exec("baaabac").toString())
< ,aaa
-
> print(/(?=(a+))a*b\1/.exec("baaabac").toString())
< aba,a
-
> print(/(.*?)a(?!(a+)b\2c)\2(.*)/.exec("baaabaac").toString())
< baaabaac,ba,,abaac
-
