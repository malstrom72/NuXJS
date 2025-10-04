> print((function() { out:{ try {  } finally { return 2  } } })())
< 2
-
> print((function() { out:{ try { return 3  } finally { return 2  } } })())
< 2
-
> print((function() { out:{ try { try { return 1 } finally { return 2 } } finally { return 3 } } })())
< 3
-
> print((function() { out:{ try { try { return 1 } finally { return 2 } } finally {  } } })())
< 2
-
> print((function() { out:{ try { try { return 1 } finally {  } } finally {  } } })())
< 1
-
> print((function() { out:{ try { try { return 1 } finally {  } } finally { break out } } })())
< undefined
-
> print((function() { out:{ try { try { return 1 } finally { break out  } } finally {  } } })())
< undefined
-
> print((function() { out:{ try { try { } finally { break out  } } finally {  } } })())
< undefined
-
> print((function() { out:{ try { try { } finally { break out  } } finally { return 9 } } })())
< 9
-
