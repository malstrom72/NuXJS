> x=new Function("print('hej')")
> x()
< hej
-
> x=new Function('a','b','c',"print(a+b+c)");
> x(99,139,255)
< 493
-
> print(x.length)
< 3
-
> print(x.name)
< anonymous
-
> x=new Function("print('typeof anonymous')");
> x()
< typeof anonymous
-
> x=new Function("print(typeof anonymous)");
> x()
< undefined
-
> x=Function('a','b','c',"print(a+b+c)");
-
> x=Function('a','b','c',"print(a+b+c)");
> x()
< NaN
-
> x=Function('a','b','c',"print(a+b+c)");
> x(1,2,3)
< 6
-
> print(x.toString())
< function anonymous(a,b,c) {
< print(a+b+c)
< }
-
> f=Function('key','add',"print(this[key]+add)");
> f.apply({ 'hello': 'there' }, [ 'hello', ' mr klister' ])
> f.apply({ 'hello': 'make sure it is ' }, [ 'hello', , ' mr klister' ])
> f.apply({ 'undefined': 'does this ' }, [ , 'work?' ])
> f.call({ 'hello': 'there' }, 'hello', ' mr klister')
< there mr klister
< make sure it is undefined
< does this work?
< there mr klister
-
> globby="mr globby"
> f.apply(null, [ 'globby', ' is a global' ])
> f.apply(undefined, [ 'globby', ' is a global' ])
> f.call(null, 'globby', ' is a global')
> f.call(undefined, 'globby', ' is a global')
< mr globby is a global
< mr globby is a global
< mr globby is a global
< mr globby is a global
-
> try { f.apply({ 'hello': 'there' }, 'nope') } catch(x) { print(x) }
< TypeError: Argument list has wrong type
-
> g = function() { f.apply({ 'hello': 'there' }, arguments) }
> g('hello', ' what where')
< there what where
-
> f = new Function('print((1 in arguments) + "," + arguments[1])');
> f.apply(null, [ 0,1,2 ]);
> f.apply(null, [ 0,,2 ]);
< true,1
< true,undefined
-
> f=Function("print(arguments.length);for(var i=0;i<arguments.length;++i)print(arguments[i])");
> f(1,2,3,4,5,6,7,8)
< 8
< 1
< 2
< 3
< 4
< 5
< 6
< 7
< 8
-
> f.apply(null,[])
< 0
-
> f.apply(null,null)
< 0
-
> f.apply(null,[1])
< 1
< 1
-
> f.apply(null,[1,2,3,4,5,6,7,8])
< 8
< 1
< 2
< 3
< 4
< 5
< 6
< 7
< 8
-
> f.apply(null,['q','w','e','r','t'])
< 5
< q
< w
< e
< r
< t
-
> f.call(null,'q','w','e','r','t')
< 5
< q
< w
< e
< r
< t
-
> f.call(null)
< 0
-
