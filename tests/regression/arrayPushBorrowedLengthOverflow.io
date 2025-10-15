> var target = { length: 0xFFFFFFFF, push: Array.prototype.push }
> try { target.push("a", "b", "c"); print("push succeeded unexpectedly") } catch (e) { print(e.name) }
< RangeError
> print(target.length)
< 4294967295
> print(target[4294967295])
< a
> print(target[4294967296])
< b
> print(target[4294967297])
< c
