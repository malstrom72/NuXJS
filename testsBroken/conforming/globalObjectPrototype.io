> Object.prototype.marshmallow='yummy'
-
> print(marshmallow)
< yummy
-
> this.marshmallow='yuck'
-
> print(marshmallow)
< yuck
-
> function f() { print(marshmallow) }
-
> f()
< yuck
-
> Object.defineProperty(Object.prototype, "smurf", { value: "bingo", writable: false, configurable: false })
-
> print(smurf)
< bingo
-
> print(delete smurf)
< true
-
> print(smurf)
< bingo
-
> smurf='zingo'
-
> print(smurf)
< bingo
-
> eval("var smurf='dingo'")
> print(smurf)
< dingo
-
> eval("smurf='lingo'")
> print(smurf)
< lingo
-
> print(delete smurf)
< true
-
> print(smurf)
< bingo
-
> Object.defineProperty(Object.prototype, "future", { value: "is not here", writable: false, configurable: false })
> print(future)
> var future="is here"
> print(future)
< undefined
< is here
-
> Object.defineProperty(Object.prototype, "1", { value: "bingo", writable: false, configurable: false });
> this[1]="jingo"
> print(this[1])
< bingo
-
