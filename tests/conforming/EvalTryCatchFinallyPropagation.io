> print(eval("try { 55; throw 'poodle' } catch (x) { print(x) } finally { }"))
< poodle
< undefined
-
> print(eval("brk: for (i = 0; i < 4; ++i) try { break brk } finally { }"))
< undefined
-
> print(eval("11;try { throw 3 } catch (x) { } finally {44 }"))
< 11
-
> print(eval("11;try { 55; throw 3 } catch (x) { } finally {44 }"))
< 11
-
