> function f() { }
> print(f.name)
< f
> print(delete f.name)
< true
> print(f.name)
> print('name' in f)
< 
< true
> print(f.hasOwnProperty('name'))
< false
> print('name' in Function.prototype)
< true
> print(Function.prototype.name)
> print(Function.prototype.name==='')
< 
< true
> print(Math.sin.name)
< sin
> print(typeof Math.sin)
< function
> print(SyntaxError.name)
