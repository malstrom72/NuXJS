> var array = []
> array.length = 4294967295
> try { array.push("x"); print("push succeeded unexpectedly") } catch (e) { print(e.name) }
< RangeError
> print(array.length)
< 4294967295
> print(array[4294967295])
< x
