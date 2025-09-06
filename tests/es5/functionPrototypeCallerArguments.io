> function f(){}
> try { f.caller; } catch(e){ print(e instanceof TypeError); }
> try { f.arguments; } catch(e){ print(e instanceof TypeError); }
> try { f.caller = {}; } catch(e){ print(e instanceof TypeError); }
> try { f.arguments = {}; } catch(e){ print(e instanceof TypeError); }
< true
< true
< true
< true
-
