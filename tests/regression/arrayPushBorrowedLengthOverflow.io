// CLI:
> var target = { length: 0xFFFFFFFF, push: Array.prototype.push }
> print(target.push("a", "b", "c"))
< 4294967298
> print(target.length)
< 4294967298
> print(target[4294967295])
< a
> print(target[4294967296])
< b
> print(target[4294967297])
< c
