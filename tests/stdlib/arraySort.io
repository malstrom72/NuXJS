> a=[1,2,3,4,,,55,6,6,7,8,1,2,34,1,5,6,'a','x','zzzz',undefined,2342,undefined,-1,'b', 'c', 'aaaa', 'q', 'fff', 'r', { valueOf: function() { return 3 }, toString: function() { return "xyzzy" } }]
> print(a.sort().toString())
< -1,1,1,1,2,2,2342,3,34,4,5,55,6,6,6,7,8,a,aaaa,b,c,fff,q,r,x,xyzzy,zzzz,,,,
-
> print(a.toString())
< -1,1,1,1,2,2,2342,3,34,4,5,55,6,6,6,7,8,a,aaaa,b,c,fff,q,r,x,xyzzy,zzzz,,,,
-
> for (var i = 0; i < a.length; ++i) print(i + ': ' + (i in a) + ' ' + (typeof a[i]) + ' ' + a[i])
< 0: true number -1
< 1: true number 1
< 2: true number 1
< 3: true number 1
< 4: true number 2
< 5: true number 2
< 6: true number 2342
< 7: true number 3
< 8: true number 34
< 9: true number 4
< 10: true number 5
< 11: true number 55
< 12: true number 6
< 13: true number 6
< 14: true number 6
< 15: true number 7
< 16: true number 8
< 17: true string a
< 18: true string aaaa
< 19: true string b
< 20: true string c
< 21: true string fff
< 22: true string q
< 23: true string r
< 24: true string x
< 25: true object 3
< 26: true string zzzz
< 27: true undefined undefined
< 28: true undefined undefined
< 29: false undefined undefined
< 30: false undefined undefined
-
