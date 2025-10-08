> var array = [1, 2]
> try { Object.defineProperty(array, "length", { value: false }); print("ok") } catch (e) { print(e.name) }
> print(array.length)
> print(array.hasOwnProperty(0))
> print(array.hasOwnProperty(1))
