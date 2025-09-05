> var obj = {};
> Object.defineProperty(obj, 'hidden', { value:1, enumerable:false });
> obj.visible = 2;
> print(Object.getOwnPropertyNames(obj).sort().join(','));
< hidden,visible
-
> var arr = [1];
> arr[2] = 3;
> Object.defineProperty(arr, '1', { value:2, enumerable:false });
> print(Object.getOwnPropertyNames(arr).sort().join(','));
< 0,1,2,length
-
> try { Object.getOwnPropertyNames(null); } catch(e){ print(e instanceof TypeError); }
< true
-
