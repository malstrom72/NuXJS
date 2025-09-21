> obj={}
> obj.length=Number.POSITIVE_INFINITY
> obj.push=Array.prototype.push
> try{obj.push(-4)}catch(e){print(e.name)}
< TypeError
-
> print(obj.length)
< Infinity
-
> print(obj[9007199254740991])
< undefined
-
