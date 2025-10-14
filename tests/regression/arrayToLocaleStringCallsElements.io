> var n=0
> var obj={toLocaleString:function(){n++;return 'obj'}}
> var arr=[undefined,obj,null,obj,obj]
> arr.toLocaleString()
> print(n)
< 3
-
