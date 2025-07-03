> a: try { print("a0"); b: { try { print("b0"); break b; print("b1") } finally { print("bf") } }; print("a1"); } finally { print("af") }
< a0
< b0
< bf
< a1
< af
-
> a: try { print("a0"); b: { try { print("b0"); break a; print("b1") } finally { print("bf") } }; print("a1"); } finally { print("af") }
< a0
< b0
< bf
< af
-
> var s = ''; for (var i = 0; i < 10; ++i) { try { if (i == 8) break; if (i > 5) continue; s += i } finally { s += "." } s += ','; }; print(s);
< 0.,1.,2.,3.,4.,5.,...
-
> a: try { print("a"); } finally { break a; print("b") }
< a
-
> a: try { print("a"); } finally { try { break a; } finally { print("c") }; print("b") }
< a
< c
-
> a: try { print("a"); } finally { try { } finally { break a; print("c") }; print("b") }
< a
-
> print((function() { try { return "du"; } finally { print("hej") } })());
< hej
< du
-
> print((function() { try { print("a"); } finally { try { return "r"; } finally { print("c") }; print("b") } })());
< a
< c
< r
-
> print((function() { try { print("a"); } finally { try { } finally { return "r"; print("c") }; print("b") } })());
< a
< r
-
> print((function() { a: try { return 1 } finally { break a; print(2) } })());
< undefined
-
> print((function() { try { return 1 } finally { return 3; print(2) } })());
< 3
-
> print(function() { var x = 0; try { return ++x; } finally { x++; print(x) } }())
< 2
< 1
-
> print(function() { var x = 0; try { return ++x; } finally { x++; return(x) } }())
< 2
-
> print(function() { var x = 0; try { return ++x; } finally { return ++x } }())
> try { (function() { try { throw "x" } finally { try { throw "y" } catch ( x ) { print(x) } } })() } catch (x) { print(x) }
< 2
< y
< x
-
> thrower=function(a) { print("throwing: " + a); throw ("thrown: " + a); print("not here"); }
> print((function() { b: try { thrower("throw me") } finally { print("fake catcher") ; break b }; return("ok then...") })());
> print((function() { try { try { thrower("throw me") } finally { print("fake catcher") ; thrower("throwed again"); }; } finally { return("ok then...") } })());
< throwing: throw me
< fake catcher
< ok then...
< throwing: throw me
< fake catcher
< throwing: throwed again
< ok then...
-
> (function() { var y = null; var x = 3; try { throw 7 } catch (x) { print(x); try { thrower(9) } catch (x) { print(x); }; x=5; print(x); print(delete x); y = function() { print(x) } }; y(); print(x) })();
< 7
< throwing: 9
< thrown: 9
< 5
< false
< 5
< 3
-
> ((function() { try { x: { try { throw "oops" } finally { print("finally") } } } catch (x) { print("caught: " + x) } })());
> // finally
> // caught: oops
< finally
< caught: oops
-
> ((function() { try { x: { try { break x; thrower("oops") } finally { print("finally") } } } catch (x) { print("caught: " + x) } })());
> // finally
< finally
-
> ((function() { try { x: { try { throw "oops" } finally { print("finally"); break x } }; print("broken") } catch (x) { print("caught: " + x) } })());
> // finally
> // broken
< finally
< broken
-
> ((function() { try { x: while (true) { try { break x; thrower("oops") } finally { print("finally") }; print("nope") } } catch (x) { print("caught: " + x) } })());
> // finally
< finally
-
> print((function() { try { return "hej" } finally { print("finally") } })());
> // finally
> // "hej"
< finally
< hej
-
> ((function() { b: try { return "hej" } finally { print("finally"); break b }; print("didn't return") })());
> // finally
> // didn't return
< finally
< didn't return
-
> print((function() { var x = 1; b: try { return ++x } finally { print("finally " + x) } })());
> // finally 2
> // 2
< finally 2
< 2
-
> print((function() { var x = 1; b: try { return x++ } finally { print("finally " + x) } })());
> // finally 2
> // 1
< finally 2
< 1
-
