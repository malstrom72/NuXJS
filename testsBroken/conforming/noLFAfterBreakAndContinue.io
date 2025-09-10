> (function() { doBreakThis: do { while (true) { break /* no lf */ doBreakThis }; print("don't get here"); } while (false); print("done"); })()
< done
-
> (function() { dontBreakThis: do { while (true) { break
> dontBreakThis }; print("get here"); } while (false); print("done"); })()
< get here
< done
-
> (function() { var j = 0; doContinueHere: while (++j < 2) { var i = 0; while (++i < 2) { continue /* no lf */ doContinueHere; print("don't get here"); } print("don't get here either"); }; print(i); print(j) })()
< 1
< 2
-
> (function() { var j = 0; doContinueHere: while (++j < 2) { var i = 0; while (++i < 2) { continue
> doContinueHere; print("don't get here"); } print("but get here"); }; print(i); print(j) })()
< but get here
< 2
< 2
-
