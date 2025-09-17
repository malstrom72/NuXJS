> var threw = false
> try { Date.prototype.setFullYear.call(Date.prototype, 2024) } catch (e) { threw = e instanceof TypeError }
> print(threw)
< true
-
