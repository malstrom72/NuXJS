> print(eval("3"))
< 3
-
> print(eval("3+3"))
< 6
-
> print(eval("3+3;;;;"))
< 6
-
> print(eval("3+3;;;{}"))
< 6
-
> print(eval(";;{3+3};;"))
< 6
-
> print(eval("aGlobal=1"))
< 1
-
> print(eval("aGlobal"))
< 1
-
> print(typeof eval("aGlobal=new (function(){this.a='a string'})"))
< object
-
> print(eval("aGlobal.a"))
< a string
-
> print("- if");
< - if
-
> print(eval("if (true) 3"))
< 3
-
> print(eval("if (false) 3"))
< undefined
-
> print(eval("if (true) 3+3"))
< 6
-
> print(eval("if (false) 3+3"))
< undefined
-
> print(eval("if (true) 3+3; else 6-6"))
< 6
-
> print(eval("if (false) 3+3; else 6-6"))
< 0
-
> print(typeof eval("aGlobal; if (false) 3"))
< object
-
> print("- break");
< - break
-
> print(eval("b: { 1; break b }"))
< 1
-
> print(eval("b: if (true) { 1; break b; 2 }"))
< 1
-
> print(eval("3; b: if (false) { 123; if (false) { 1; break b; 2 }}"))
< 3
-
> print(eval("3; b: if (true) { 123; if (false) { 1; break b; 2 }}"))
< 123
-
> print(eval("3; b: if (false) { 123; if (true) { 1; break b; 2 }}"))
< 3
-
> print(eval("3; b: if (false) { 123; if (false) { 1; break b; 2 }}"))
< 3
-
> print("- while");
< - while
-
> print(eval("while (false) 7;"))
< undefined
-
> print(eval("5; while (false) 7;"))
< 5
-
> print(eval("5; while (true) { 3; break }"))
< 3
-
> print(eval("var i = 0; 234; while (i++ == 0) i * 100"))
< 100
-
> print(eval("var i = 0; 234; while (i++ == 0) { if (i == 1) continue; i * 100 }"))
< 234
-
> print(eval("var i = 0; 234; while (++i < 10) { 23; continue }"))
< 23
-
> print(eval("var i = 3; 234; while (++i < 10) { j = 5; while (++j < i) j * 3 }"))
< 24
-
> print("- do while");
< - do while
-
> i = 0; print(eval("do { ; } while (++i < 1000)"))
< undefined
-
> i = 0; print(eval("do { ++i } while (i < 1000)"))
< 1000
-
> i = 0; print(eval("234; do { ++i; if (i < 10) continue; i * 100 } while (i < 1000)"))
< 100000
-
> i = 0; print(eval("234; do { ++i; if (i < 10) continue; 123 } while (i < 1000)"));
< 123
-
> print("- for");
< - for
-
> print(eval("; for (var i = 0; i < -1; ++i) 123"))
< undefined
-
> print(eval("1; for (var i = 0; i < -1; ++i) 123"))
< 1
-
> print(eval("; for (var i = 0; i < 1; ++i) 123"))
< 123
-
> print(eval("1; for (var i = 0; i < 1; ++i) 123"))
< 123
-
> print(eval("for (var i = 0; i < 100; ++i) { ++i; if (i < 10) continue; 123 }"));
< 123
-
> print(eval("for (var i = 0; i < 100; ++i) { ++i; if (i >= 10) break; 123 }"));
< 11
-
> print("- for in");
< - for in
-
> o = new (function() { });
-
> print(eval("; for (var i in o) 123"))
< undefined
-
> print(eval("1; for (var i in o) 123"))
< 1
-
> o["a"] = "b";
-
> print(eval("; for (var i in o) 123"))
< 123
-
> print(eval("1; for (var i in o) 123"))
< 123
-
> for (var i = 0; i < 100; ++i) o[i] = i * 1234;
-
> print("built");
< built
-
> print(eval("for (var i in o) { ++i; if (i == 55) continue; 123 }"));
< 123
-
> print("first");
< first
-
> print(eval("for (var i in o) { ++i; if (i == 55) continue; 123 }"));
< 123
-
> print(eval("for (var i in o) { ++i; if (i == 55) { print('found'); break; }; 123 }"));
< found
< undefined
-
> print("second");
< second
-
> print("- switch");
< - switch
-
> print(eval("; switch (3+3) { case 7: 123 }"));
> print(eval("; switch (3+3) { case 7: 123; default: 5656 }"));
> print(eval("345; switch (3+3) { case 7: 123; default: 5656 }"));
> print(eval("345; switch (3+3) { case 7: 123 }"));
> print(eval("; switch (3+3) { case 6: 123; case 7: 256; }"));
> print(eval("; switch (3+3+1) { case 6: 123; case 7: 256; }"));
> print(eval("; switch (3+3) { case 6: 123; break; case 7: 256; }"));
> print(eval("for (var i = 0; i < 10; ++i) switch (3+3) { case 6: 123; continue; case 7: 256; }"));
< undefined
< 5656
< 5656
< 345
< 256
< 256
< 123
< 123
-
> print("- try catch");
< - try catch
-
> print(eval("; try { 234 } catch ( x ) { 555 }"));
> print(eval("1234; try { 234 } catch ( x ) { 555 }"));
> print(eval("1234; try { throw 55; 234 } catch ( x ) { 555 }"));
> print(eval("1234; try { throw 55; 234 } catch ( x ) { }"));
> print(eval("1234; try { throw 55; 234 } catch ( x ) { } finally { 9876 }"));
> print(eval("try { throw 2 } catch (x) { try { throw 3 } catch (y) { print(y) } } finally { try { } catch (y) { } }"));
> for (x = 0; x < 2; ++x) {
>     for (y = 1; y < 4; ++y) {
>         print(eval("switch (x) { case 0: 0; break; case 1: switch (y) { case 3: 3; break; case 2: try { throw 2 } catch (z) { z } } }"))
>     }
> }
< 234
< 234
< 555
< 1234
< 1234
< 3
< undefined
< 0
< 0
< 0
< undefined
< 2
< 3
-
> print("- more");
< - more
-
> print((function() { var x = 33; eval("x = 55"); return x })());
< 55
-
> print((function() { var x = 33; eval("var x = 55"); return x })());
< 55
-
> print((function() { eval("if (false) var x = 23"); return x })());
< undefined
-
> (function() { var x = 88; try { throw "k" } catch (x) { eval("print(x); var x = 5"); print(x) }; print(x) })();
< k
< 5
< 88
-
> (function() { var x = 88; try { throw "k" } catch (x) { eval("print(x); x = 5"); print(x) }; print(x) })();
< k
< 5
< 88
-
> aGlobal = "ok"; (function() { eval("var aGlobal = 5"); print(delete aGlobal); print(aGlobal) })(); print("aGlobal" in this);
> print("");
< true
< ok
< true
< 
-
> aGlobal = "ok"; (function() { eval("var aGlobal = 5"); print(delete aGlobal); print(delete aGlobal); })(); print("aGlobal" in this);
> print("");
< true
< true
< false
< 
-
> (function() { eval("var x = 5"); print(delete x); })();
> print("");
< true
< 
-
> (function() { var x = 77; eval("var x = 5"); print(delete x); print(x) })();
> print("");
< false
< 5
< 
-
> (function() { var f = 33; eval("function f() { print('ohboy') }"); f(); })();
< ohboy
-
> (function() { var f = 33; eval("f=18; function f() { print('ohboy') }"); print(f); })();
< 18
-
> (function() { var f = 33; eval("function f() { print('ohboy') }; f=18"); print(f); })();
< 18
-
> print("anotherGlobal in this: " + ("anotherGlobal" in this));
> eval("if (false) var anotherGlobal = 'this creates a global'");
> print("anotherGlobal in this: " + ("anotherGlobal" in this));
< anotherGlobal in this: false
< anotherGlobal in this: true
-
> var y = -100; var a=(function() { var z = 3; var y = 2; var x = eval; z = x("var y = 100; (function() { print('tick ' + ++y); return y })"); print(y); return z })(); print(a()); print(a()); print(y); print("");
< 2
< tick 101
< 101
< tick 102
< 102
< 102
< 
-
> var y = -100;
> var a=(function() { var z = 3; var y = 2; z = eval("var y = 100; (function() { print('tick ' + ++y); return y })"); print(y); return z })();
> print(a());
> print(a());
> print(y);
> print("");
< 100
< tick 101
< 101
< tick 102
< 102
< -100
< 
-
> var y = -100;
> var a=(function() { var z = 3; var y = 2; z = eval("y = 100; (function() { print('tick ' + ++y); return y })"); print(y); return z })();
> print(a());
> print(a());
> print(y);
> print("");
< 100
< tick 101
< 101
< tick 102
< 102
< -100
< 
-
> var y = -100;
> var a=(function() { var z = 3; var y = 2; var x = eval; z = x("y = 100; (function() { print('tick ' + ++y); return y })"); print(y); return z })();
> print(a());
> print(a());
> print(y);
> print("");
< 2
< tick 101
< 101
< tick 102
< 102
< 102
< 
-
> this.isGlobal = "yeah, is global";
> var o = new (function() { this.eval = eval; this.isGlobal = "no, is not global"; this.test1 = function() { this.eval("print(this.isGlobal)")
>         this.test2 = function() { eval("print(this.isGlobal)") } } });
> // o.eval("print(this.isGlobal)"); // FIX : jsc doesn't like this
> // o.test1(); // FIX : jsc doesn't like this
> // o.test2();
-
> 
-
