> ( // missing expression
! !!!! Line: 1
! !!!! SyntaxError: Missing / invalid expression
-
> ) // just wrong
! !!!! Line: 1
! !!!! SyntaxError: Syntax error
-
> åäö = 4 // unaccepted identifier
! !!!! Line: 1
! !!!! SyntaxError: Syntax error
-
> 3 = 3 // illegal l-value
! !!!! Line: 1
! !!!! ReferenceError: Illegal l-value
-
> 5+5 }
! !!!! Line: 1
! !!!! SyntaxError: Syntax error
-
> /* unterminated
! !!!! Line: 1
! !!!! SyntaxError: Missing */
-
> " unterminated
! !!!! Line: 1
! !!!! SyntaxError: Unterminated string
-
> ' unterminated
! !!!! Line: 1
! !!!! SyntaxError: Unterminated string
-
> "\
! !!!! Line: 1
! !!!! SyntaxError: Unterminated string
-
> "\x5k"
! !!!! Line: 1
! !!!! SyntaxError: Invalid escape sequence
-
> "\u53Ak"
! !!!! Line: 1
! !!!! SyntaxError: Invalid escape sequence
-
> f(
! !!!! Line: 1
! !!!! SyntaxError: Expected ')'
-
> f(,
! !!!! Line: 1
! !!!! SyntaxError: Missing / invalid expression
-
> f(3,
! !!!! Line: 1
! !!!! SyntaxError: Missing / invalid expression
-
> f(3,5 3)
! !!!! Line: 1
! !!!! SyntaxError: Expected ',' or ')'
-
> a.
! !!!! Line: 1
! !!!! SyntaxError: Expected identifier
-
> a.+
! !!!! Line: 1
! !!!! SyntaxError: Expected identifier
-
> case = 3
! !!!! Line: 1
! !!!! SyntaxError: Illegal use of keyword
-
> super = 5
! !!!! Line: 1
! !!!! SyntaxError: Illegal use of keyword
-
> (function( {})
! !!!! Line: 1
! !!!! SyntaxError: Expected identifier
-
> (function(,) {})
! !!!! Line: 1
! !!!! SyntaxError: Expected identifier
-
> (function(a,) {})
! !!!! Line: 1
! !!!! SyntaxError: Expected identifier
-
> (function(a,b c) {})
! !!!! Line: 1
! !!!! SyntaxError: Expected ',' or ')'
-
> (function(a,b,c))
! !!!! Line: 1
! !!!! SyntaxError: Expected '{'
-
> function f
! !!!! Line: 1
! !!!! SyntaxError: Expected '('
-
> function f (
! !!!! Line: 1
! !!!! SyntaxError: Expected ')'
-
> function f ( a
! !!!! Line: 1
! !!!! SyntaxError: Expected ',' or ')'
-
> function f ( a, 
! !!!! Line: 1
! !!!! SyntaxError: Expected identifier
-
> function f ( a , )
! !!!! Line: 1
! !!!! SyntaxError: Expected identifier
-
> function f ( a , b )
! !!!! Line: 1
! !!!! SyntaxError: Expected '{'
-
> function f ( a , b ) {
! !!!! Line: 1
! !!!! SyntaxError: Expected '}'
-
> a = 0x
! !!!! Line: 1
! !!!! SyntaxError: Missing / invalid expression
-
> a = .
! !!!! Line: 1
! !!!! SyntaxError: Missing / invalid expression
-
> var =5
! !!!! Line: 1
! !!!! SyntaxError: Expected identifier
-
> var x=5,
! !!!! Line: 1
! !!!! SyntaxError: Expected identifier
-
> x: { x: { } }
! !!!! Line: 1
! !!!! SyntaxError: Duplicate label
-
> x: { break y }
! !!!! Line: 1
! !!!! SyntaxError: Undefined label
-
> x: { continue y }
! !!!! Line: 1
! !!!! SyntaxError: Undefined label
-
> x: { continue x }
! !!!! Line: 1
! !!!! SyntaxError: Illegal label for continue
-
> { break }
! !!!! Line: 1
! !!!! SyntaxError: Illegal break
-
> { continue }
! !!!! Line: 1
! !!!! SyntaxError: Illegal continue
-
> try
! !!!! Line: 1
! !!!! SyntaxError: Expected '{'
-
> try {
! !!!! Line: 1
! !!!! SyntaxError: Expected '}'
-
> try { }
! !!!! Line: 1
! !!!! SyntaxError: Expected 'catch' or 'finally'
-
> try { } catch ( ) { }
! !!!! Line: 1
! !!!! SyntaxError: Expected identifier
-
> switch () { }
! !!!! Line: 1
! !!!! SyntaxError: Missing / invalid expression
-
> switch (3) { x=1 }
! !!!! Line: 1
! !!!! SyntaxError: Expected 'case', 'default' or '}'
-
> switch () { 
! !!!! Line: 1
! !!!! SyntaxError: Missing / invalid expression
-
> (true ? a : b) = 3
! !!!! Line: 1
! !!!! ReferenceError: Illegal l-value
-
> for (var x = 3, y = 5 in f; x < 100 && y < 15 ; ++y) { s += y + "," };
! !!!! Line: 1
! !!!! SyntaxError: Expected ';'
-
> for ( a = 100 in "abcdefgh" ) ;
! !!!! Line: 1
! !!!! ReferenceError: Illegal l-value
-
> o = new(function() { });
-
> s = "not a function"; s(1,2,3);
! !!!! TypeError: not a function is not a function
-
> o.s = "also not a function"; o.s(1,2,3)
! !!!! TypeError: s is not a function
-
> stillNoFunction = new(function() { }); stillNoFunction(1,2,3)
! !!!! TypeError: [object Object] is not a function
-
> o.b = stillNoFunction; o.b(1,2,3)
! !!!! TypeError: b is not a function
-
> andAgain = new s
! !!!! TypeError: not a function is not a function
-
> andAgain = new o
! !!!! TypeError: [object Object] is not a function
-
> return "a" // is not acceptable in global scope
! !!!! Line: 1
! !!!! SyntaxError: Illegal return
-
> (1 in "abcd") // cannot do "in" operator on non-object
! !!!! TypeError: Cannot use 'in' operator on abcd
-
> ({
! !!!! Line: 1
! !!!! SyntaxError: Expected property name
-
> ({)
! !!!! Line: 1
! !!!! SyntaxError: Expected property name
-
> ({,})
! !!!! Line: 1
! !!!! SyntaxError: Expected property name
-
> ({,1})
! !!!! Line: 1
! !!!! SyntaxError: Expected property name
-
> ({1})
! !!!! Line: 1
! !!!! SyntaxError: Expected ':'
-
> ({1:})
! !!!! Line: 1
! !!!! SyntaxError: Missing / invalid expression
-
> ({1:1,
! !!!! Line: 1
! !!!! SyntaxError: Expected property name
-
> ({1:1 2:3})
! !!!! Line: 1
! !!!! SyntaxError: Expected ',' or '}'
-
> ({1:1,,})
! !!!! Line: 1
! !!!! SyntaxError: Expected property name
-
> [
! !!!! Line: 1
! !!!! SyntaxError: Missing / invalid expression
-
> ([)
! !!!! Line: 1
! !!!! SyntaxError: Missing / invalid expression
-
> [,]
-
> [,1]
-
> [1:1]
! !!!! Line: 1
! !!!! SyntaxError: Expected ',' or ']'
-
> [1,
! !!!! Line: 1
! !!!! SyntaxError: Missing / invalid expression
-
> [1 2]
! !!!! Line: 1
! !!!! SyntaxError: Expected ',' or ']'
-
> [1,,]
-
> (a=5)+=6
! !!!! Line: 1
! !!!! ReferenceError: Illegal l-value
-
> (null).asdf = 3 // not valid object
! !!!! TypeError: Cannot convert undefined or null to object
-
> (void 0).asdf = 3 // not valid object
! !!!! TypeError: Cannot convert undefined or null to object
-
> delete (void 0).asdf // not valid object
! !!!! TypeError: Cannot convert undefined or null to object
-
> delete (null).asdf // not valid object
! !!!! TypeError: Cannot convert undefined or null to object
-
