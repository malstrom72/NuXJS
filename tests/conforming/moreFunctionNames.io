> SyntaxError.name
> print(SyntaxError.name)
< SyntaxError
-
> print(SyntaxError.name=3)
< 3
-
> print(SyntaxError.name)
// ES6:
// < SyntaxError
< SyntaxError
-
> print(delete SyntaxError.name)
< true
-
> print(SyntaxError.name)
// ES6, maybe:
// < Error
< 
-
> function test() { }
> print(test.name)
< test
-
> test.name=1345
> print(test.name)
// ES6, maybe:
// < test
< test
-
> print(delete test.name)
< true
-
> print(test.name)
> test.name=3
> print(test.name)
<
-
