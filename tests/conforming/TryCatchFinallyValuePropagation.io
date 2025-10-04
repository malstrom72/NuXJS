> print(eval('try { } catch (x) { }'))
< undefined
-
> print(eval('try { 23 } catch (x) { }'))
< 23
-
> print(eval('try { throw 5 } catch (x) { }'))
< undefined
-
> print(eval('try { throw 5 } catch (x) { print(x) }'))
< 5
< undefined
-
> print(eval('try { throw 5 } catch (x) { print(x);23 }'))
< 5
< 23
-
> print(eval('try { 55;throw 5 } catch (x) { print(x);23 }'))
< 5
< 23
-
> print(eval('try { 55;throw 5 } catch (x) { }'))
< undefined
-
> print(eval('5;try { 55;throw 5 } catch (x) { }'))
< 5
-
> print(eval('out:{5;try { 55;throw 5 } catch (x) { break out } }'))
< 5
-
> print(eval('out:{5;try { 55;throw 25 } catch (x) { break out } }'))
< 5
-
> print(eval('out:{5;try { 55;throw 25 } catch (x) { 77;break out } }'))
< 77
-
> try { eval('out:{5;try { 55;throw 25 } catch (x) { 77;throw 99 } }') } catch (x) { print("thrown:"+x) }
< thrown:99
-
> print(eval('out:{5;try { 55;throw 25 } catch (x) { 77;break out } finally { } }'))
< 77
-
> print(eval('out:{5;try { 55;throw 25 } catch (x) { 77;break out } finally { 13 } }'))
< 77
-
> print(eval('out:{5;try { 55;throw 25 } catch (x) { 77;break out } finally { print("fin") } }'))
< fin
< 77
-
> print(eval('out:{5;try { 55;throw 25 } catch (x) { 77;break out } finally { print("fin");break out } }'))
< fin
< undefined
-
> try { eval('out:{5;try { 55;throw 25 } catch (x) { 77;throw 99 } finally { print("fin"); } }') } catch (x) { print("thrown:"+x) }
< fin
< thrown:99
-
> print(eval('out:{5;try { 55;throw 25 } catch (x) { 77;throw 99 } finally { print("fin");break out } }'))
< fin
< undefined
-
> print((function() { try { } catch (x) { } })())
< undefined
-
> print((function() { try { 23 } catch (x) { } })())
< undefined
-
> print((function() { try { throw 5 } catch (x) { } })())
< undefined
-
> print((function() { try { throw 5 } catch (x) { print(x) } })())
< 5
< undefined
-
> print((function() { try { throw 5 } catch (x) { print(x);23 } })())
< 5
< undefined
-
> print((function() { try { 55;throw 5 } catch (x) { print(x);23 } })())
< 5
< undefined
-
> print((function() { try { 55;throw 5 } catch (x) { } })())
< undefined
-
> print((function() { 5;try { 55;throw 5 } catch (x) { } })())
< undefined
-
> print((function() { out:{5;try { 55;throw 5 } catch (x) { break out } } })())
< undefined
-
> print((function() { out:{5;try { 55;throw 25 } catch (x) { break out } } })())
< undefined
-
> print((function() { out:{5;try { 55;throw 25 } catch (x) { 77;break out } } })())
< undefined
-
> try { (function() { out:{5;try { 55;throw 25 } catch (x) { 77;throw 99 } } })() } catch (x) { print("thrown:"+x) }
< thrown:99
-
> print((function() { out:{5;try { 55;throw 25 } catch (x) { 77;break out } finally { } } })())
< undefined
-
> print((function() { out:{5;try { 55;throw 25 } catch (x) { 77;break out } finally { 13 } } })())
< undefined
-
> print((function() { out:{5;try { 55;throw 25 } catch (x) { 77;break out } finally { print("fin") } } })())
< fin
< undefined
-
> print((function() { out:{5;try { 55;throw 25 } catch (x) { 77;break out } finally { print("fin");break out } } })())
< fin
< undefined
-
> try { (function() { out:{5;try { 55;throw 25 } catch (x) { 77;throw 99 } finally { print("fin"); } } })() } catch (x) { print("thrown:"+x) }
< fin
< thrown:99
-
> print((function() { out:{5;try { 55;throw 25 } catch (x) { 77;throw 99 } finally { print("fin");break out } } })())
< fin
< undefined
-
