> a=[1,2,,,,,5,7]
> print(a.toString())
< 1,2,,,,,5,7
> Array.prototype[4]='inProto'
> print(a.toString())
< 1,2,,,inProto,,5,7
> print(Array.prototype.toString())
< ,,,,inProto
> print('inProto' in a)
< false
> print(4 in a)
< true
> print(5 in a)
< false
> print(1 in a)
< true
> print(a.length)
< 8
> a.length=2
> print(a.length)
< 2
> print(a.toString())
< 1,2
> try { a.length=1.5 } catch (e) { print(e) }
< RangeError: Invalid array length
> try { a.length=-3 } catch (e) { print(e) }
< RangeError: Invalid array length
> print(Array.prototype.length)
< 5
