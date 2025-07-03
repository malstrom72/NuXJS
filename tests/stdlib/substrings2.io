> var testFuncs = [ 'substring', 'substr', 'slice' ];
> var testStrings = [ '', 'abcdefghijklmnopqrstuvwxyz', { toString: function() { return "qwertyuiop" }, valueOf: function() { return 'object' } } ];
> var testArgs = [ [ ],  [ 0 ],  [ 1 ],  [ 2 ], [ 5 ], [ 100 ], [ 0.3 ], [ Infinity ], [ NaN ], [ -1 ], [ -7 ], [ -0.5 ], [ -Infinity ],
> 		[ 0, 0 ], [ 0, 1 ], [ 1, 2 ], [ 2, 5 ], [ -1, 3 ], [ -5, 2 ], [ 5.3, 7.6 ], [ 7, 2 ], [ -5, -1 ], [ 3, NaN ], [ 3, Infinity ], [ 3, -Infinity ],
>       [ undefined, 5 ], [ "5", "10" ], [ { toString: function() { return "obj1" }, valueOf: function() { return "1.3" } }, { toString: function() { return "obj2" }, valueOf: function() { return "9.3" } } ] ];
> for (var funcIndex = 0; funcIndex < testFuncs.length; ++funcIndex) {
>     var func = String.prototype[testFuncs[funcIndex]];
>     for (var stringIndex = 0; stringIndex < testStrings.length; ++stringIndex) {
>         var string = testStrings[stringIndex];
>         for (var argsIndex = 0; argsIndex < testArgs.length; ++argsIndex) {
>             var args = testArgs[argsIndex];
>             print(testFuncs[funcIndex] + "(" + string + ", " + args + "): " + func.apply(string, args));
>         }
>     }
> }
< substring(, ): 
< substring(, 0): 
< substring(, 1): 
< substring(, 2): 
< substring(, 5): 
< substring(, 100): 
< substring(, 0.3): 
< substring(, Infinity): 
< substring(, NaN): 
< substring(, -1): 
< substring(, -7): 
< substring(, -0.5): 
< substring(, -Infinity): 
< substring(, 0,0): 
< substring(, 0,1): 
< substring(, 1,2): 
< substring(, 2,5): 
< substring(, -1,3): 
< substring(, -5,2): 
< substring(, 5.3,7.6): 
< substring(, 7,2): 
< substring(, -5,-1): 
< substring(, 3,NaN): 
< substring(, 3,Infinity): 
< substring(, 3,-Infinity): 
< substring(, ,5): 
< substring(, 5,10): 
< substring(, obj1,obj2): 
< substring(abcdefghijklmnopqrstuvwxyz, ): abcdefghijklmnopqrstuvwxyz
< substring(abcdefghijklmnopqrstuvwxyz, 0): abcdefghijklmnopqrstuvwxyz
< substring(abcdefghijklmnopqrstuvwxyz, 1): bcdefghijklmnopqrstuvwxyz
< substring(abcdefghijklmnopqrstuvwxyz, 2): cdefghijklmnopqrstuvwxyz
< substring(abcdefghijklmnopqrstuvwxyz, 5): fghijklmnopqrstuvwxyz
< substring(abcdefghijklmnopqrstuvwxyz, 100): 
< substring(abcdefghijklmnopqrstuvwxyz, 0.3): abcdefghijklmnopqrstuvwxyz
< substring(abcdefghijklmnopqrstuvwxyz, Infinity): 
< substring(abcdefghijklmnopqrstuvwxyz, NaN): abcdefghijklmnopqrstuvwxyz
< substring(abcdefghijklmnopqrstuvwxyz, -1): abcdefghijklmnopqrstuvwxyz
< substring(abcdefghijklmnopqrstuvwxyz, -7): abcdefghijklmnopqrstuvwxyz
< substring(abcdefghijklmnopqrstuvwxyz, -0.5): abcdefghijklmnopqrstuvwxyz
< substring(abcdefghijklmnopqrstuvwxyz, -Infinity): abcdefghijklmnopqrstuvwxyz
< substring(abcdefghijklmnopqrstuvwxyz, 0,0): 
< substring(abcdefghijklmnopqrstuvwxyz, 0,1): a
< substring(abcdefghijklmnopqrstuvwxyz, 1,2): b
< substring(abcdefghijklmnopqrstuvwxyz, 2,5): cde
< substring(abcdefghijklmnopqrstuvwxyz, -1,3): abc
< substring(abcdefghijklmnopqrstuvwxyz, -5,2): ab
< substring(abcdefghijklmnopqrstuvwxyz, 5.3,7.6): fg
< substring(abcdefghijklmnopqrstuvwxyz, 7,2): cdefg
< substring(abcdefghijklmnopqrstuvwxyz, -5,-1): 
< substring(abcdefghijklmnopqrstuvwxyz, 3,NaN): abc
< substring(abcdefghijklmnopqrstuvwxyz, 3,Infinity): defghijklmnopqrstuvwxyz
< substring(abcdefghijklmnopqrstuvwxyz, 3,-Infinity): abc
< substring(abcdefghijklmnopqrstuvwxyz, ,5): abcde
< substring(abcdefghijklmnopqrstuvwxyz, 5,10): fghij
< substring(abcdefghijklmnopqrstuvwxyz, obj1,obj2): bcdefghi
< substring(object, ): qwertyuiop
< substring(object, 0): qwertyuiop
< substring(object, 1): wertyuiop
< substring(object, 2): ertyuiop
< substring(object, 5): yuiop
< substring(object, 100): 
< substring(object, 0.3): qwertyuiop
< substring(object, Infinity): 
< substring(object, NaN): qwertyuiop
< substring(object, -1): qwertyuiop
< substring(object, -7): qwertyuiop
< substring(object, -0.5): qwertyuiop
< substring(object, -Infinity): qwertyuiop
< substring(object, 0,0): 
< substring(object, 0,1): q
< substring(object, 1,2): w
< substring(object, 2,5): ert
< substring(object, -1,3): qwe
< substring(object, -5,2): qw
< substring(object, 5.3,7.6): yu
< substring(object, 7,2): ertyu
< substring(object, -5,-1): 
< substring(object, 3,NaN): qwe
< substring(object, 3,Infinity): rtyuiop
< substring(object, 3,-Infinity): qwe
< substring(object, ,5): qwert
< substring(object, 5,10): yuiop
< substring(object, obj1,obj2): wertyuio
< substr(, ): 
< substr(, 0): 
< substr(, 1): 
< substr(, 2): 
< substr(, 5): 
< substr(, 100): 
< substr(, 0.3): 
< substr(, Infinity): 
< substr(, NaN): 
< substr(, -1): 
< substr(, -7): 
< substr(, -0.5): 
< substr(, -Infinity): 
< substr(, 0,0): 
< substr(, 0,1): 
< substr(, 1,2): 
< substr(, 2,5): 
< substr(, -1,3): 
< substr(, -5,2): 
< substr(, 5.3,7.6): 
< substr(, 7,2): 
< substr(, -5,-1): 
< substr(, 3,NaN): 
< substr(, 3,Infinity): 
< substr(, 3,-Infinity): 
< substr(, ,5): 
< substr(, 5,10): 
< substr(, obj1,obj2): 
< substr(abcdefghijklmnopqrstuvwxyz, ): abcdefghijklmnopqrstuvwxyz
< substr(abcdefghijklmnopqrstuvwxyz, 0): abcdefghijklmnopqrstuvwxyz
< substr(abcdefghijklmnopqrstuvwxyz, 1): bcdefghijklmnopqrstuvwxyz
< substr(abcdefghijklmnopqrstuvwxyz, 2): cdefghijklmnopqrstuvwxyz
< substr(abcdefghijklmnopqrstuvwxyz, 5): fghijklmnopqrstuvwxyz
< substr(abcdefghijklmnopqrstuvwxyz, 100): 
< substr(abcdefghijklmnopqrstuvwxyz, 0.3): abcdefghijklmnopqrstuvwxyz
< substr(abcdefghijklmnopqrstuvwxyz, Infinity): 
< substr(abcdefghijklmnopqrstuvwxyz, NaN): abcdefghijklmnopqrstuvwxyz
< substr(abcdefghijklmnopqrstuvwxyz, -1): z
< substr(abcdefghijklmnopqrstuvwxyz, -7): tuvwxyz
< substr(abcdefghijklmnopqrstuvwxyz, -0.5): abcdefghijklmnopqrstuvwxyz
< substr(abcdefghijklmnopqrstuvwxyz, -Infinity): abcdefghijklmnopqrstuvwxyz
< substr(abcdefghijklmnopqrstuvwxyz, 0,0): 
< substr(abcdefghijklmnopqrstuvwxyz, 0,1): a
< substr(abcdefghijklmnopqrstuvwxyz, 1,2): bc
< substr(abcdefghijklmnopqrstuvwxyz, 2,5): cdefg
< substr(abcdefghijklmnopqrstuvwxyz, -1,3): z
< substr(abcdefghijklmnopqrstuvwxyz, -5,2): vw
< substr(abcdefghijklmnopqrstuvwxyz, 5.3,7.6): fghijkl
< substr(abcdefghijklmnopqrstuvwxyz, 7,2): hi
< substr(abcdefghijklmnopqrstuvwxyz, -5,-1): 
< substr(abcdefghijklmnopqrstuvwxyz, 3,NaN): 
< substr(abcdefghijklmnopqrstuvwxyz, 3,Infinity): defghijklmnopqrstuvwxyz
< substr(abcdefghijklmnopqrstuvwxyz, 3,-Infinity): 
< substr(abcdefghijklmnopqrstuvwxyz, ,5): abcde
< substr(abcdefghijklmnopqrstuvwxyz, 5,10): fghijklmno
< substr(abcdefghijklmnopqrstuvwxyz, obj1,obj2): bcdefghij
< substr(object, ): qwertyuiop
< substr(object, 0): qwertyuiop
< substr(object, 1): wertyuiop
< substr(object, 2): ertyuiop
< substr(object, 5): yuiop
< substr(object, 100): 
< substr(object, 0.3): qwertyuiop
< substr(object, Infinity): 
< substr(object, NaN): qwertyuiop
< substr(object, -1): p
< substr(object, -7): rtyuiop
< substr(object, -0.5): qwertyuiop
< substr(object, -Infinity): qwertyuiop
< substr(object, 0,0): 
< substr(object, 0,1): q
< substr(object, 1,2): we
< substr(object, 2,5): ertyu
< substr(object, -1,3): p
< substr(object, -5,2): yu
< substr(object, 5.3,7.6): yuiop
< substr(object, 7,2): io
< substr(object, -5,-1): 
< substr(object, 3,NaN): 
< substr(object, 3,Infinity): rtyuiop
< substr(object, 3,-Infinity): 
< substr(object, ,5): qwert
< substr(object, 5,10): yuiop
< substr(object, obj1,obj2): wertyuiop
< slice(, ): 
< slice(, 0): 
< slice(, 1): 
< slice(, 2): 
< slice(, 5): 
< slice(, 100): 
< slice(, 0.3): 
< slice(, Infinity): 
< slice(, NaN): 
< slice(, -1): 
< slice(, -7): 
< slice(, -0.5): 
< slice(, -Infinity): 
< slice(, 0,0): 
< slice(, 0,1): 
< slice(, 1,2): 
< slice(, 2,5): 
< slice(, -1,3): 
< slice(, -5,2): 
< slice(, 5.3,7.6): 
< slice(, 7,2): 
< slice(, -5,-1): 
< slice(, 3,NaN): 
< slice(, 3,Infinity): 
< slice(, 3,-Infinity): 
< slice(, ,5): 
< slice(, 5,10): 
< slice(, obj1,obj2): 
< slice(abcdefghijklmnopqrstuvwxyz, ): abcdefghijklmnopqrstuvwxyz
< slice(abcdefghijklmnopqrstuvwxyz, 0): abcdefghijklmnopqrstuvwxyz
< slice(abcdefghijklmnopqrstuvwxyz, 1): bcdefghijklmnopqrstuvwxyz
< slice(abcdefghijklmnopqrstuvwxyz, 2): cdefghijklmnopqrstuvwxyz
< slice(abcdefghijklmnopqrstuvwxyz, 5): fghijklmnopqrstuvwxyz
< slice(abcdefghijklmnopqrstuvwxyz, 100): 
< slice(abcdefghijklmnopqrstuvwxyz, 0.3): abcdefghijklmnopqrstuvwxyz
< slice(abcdefghijklmnopqrstuvwxyz, Infinity): 
< slice(abcdefghijklmnopqrstuvwxyz, NaN): abcdefghijklmnopqrstuvwxyz
< slice(abcdefghijklmnopqrstuvwxyz, -1): z
< slice(abcdefghijklmnopqrstuvwxyz, -7): tuvwxyz
< slice(abcdefghijklmnopqrstuvwxyz, -0.5): abcdefghijklmnopqrstuvwxyz
< slice(abcdefghijklmnopqrstuvwxyz, -Infinity): abcdefghijklmnopqrstuvwxyz
< slice(abcdefghijklmnopqrstuvwxyz, 0,0): 
< slice(abcdefghijklmnopqrstuvwxyz, 0,1): a
< slice(abcdefghijklmnopqrstuvwxyz, 1,2): b
< slice(abcdefghijklmnopqrstuvwxyz, 2,5): cde
< slice(abcdefghijklmnopqrstuvwxyz, -1,3): 
< slice(abcdefghijklmnopqrstuvwxyz, -5,2): 
< slice(abcdefghijklmnopqrstuvwxyz, 5.3,7.6): fg
< slice(abcdefghijklmnopqrstuvwxyz, 7,2): 
< slice(abcdefghijklmnopqrstuvwxyz, -5,-1): vwxy
< slice(abcdefghijklmnopqrstuvwxyz, 3,NaN): 
< slice(abcdefghijklmnopqrstuvwxyz, 3,Infinity): defghijklmnopqrstuvwxyz
< slice(abcdefghijklmnopqrstuvwxyz, 3,-Infinity): 
< slice(abcdefghijklmnopqrstuvwxyz, ,5): abcde
< slice(abcdefghijklmnopqrstuvwxyz, 5,10): fghij
< slice(abcdefghijklmnopqrstuvwxyz, obj1,obj2): bcdefghi
< slice(object, ): qwertyuiop
< slice(object, 0): qwertyuiop
< slice(object, 1): wertyuiop
< slice(object, 2): ertyuiop
< slice(object, 5): yuiop
< slice(object, 100): 
< slice(object, 0.3): qwertyuiop
< slice(object, Infinity): 
< slice(object, NaN): qwertyuiop
< slice(object, -1): p
< slice(object, -7): rtyuiop
< slice(object, -0.5): qwertyuiop
< slice(object, -Infinity): qwertyuiop
< slice(object, 0,0): 
< slice(object, 0,1): q
< slice(object, 1,2): w
< slice(object, 2,5): ert
< slice(object, -1,3): 
< slice(object, -5,2): 
< slice(object, 5.3,7.6): yu
< slice(object, 7,2): 
< slice(object, -5,-1): yuio
< slice(object, 3,NaN): 
< slice(object, 3,Infinity): rtyuiop
< slice(object, 3,-Infinity): 
< slice(object, ,5): qwert
< slice(object, 5,10): yuiop
< slice(object, obj1,obj2): wertyuio
-
