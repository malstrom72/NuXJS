> var open = Array(201).join("(")
> var close = Array(201).join(")")
> try {
> var re = new RegExp(open + "b" + close)
> print("compiled")
> var match = re.exec("b")
> print(match !== null)
> print(match.length)
> print(match[200])
> } catch (e) {
> print(e.name)
> print(e.message)
> }
< compiled
< true
< 201
< b
