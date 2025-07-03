> // had a bug with catch variable still accessible in finally scope when breaking out of the catch
> while (true) try { throw "oj" } catch (x) { break; } finally { try { print(x) } catch (e) { print(e.name); } }
< ReferenceError
-
> (function() { while (true) try { throw "oj" } catch (x) { return; } finally { try { print(x) } catch (e) { print(e.name); } } })()
< ReferenceError
-
