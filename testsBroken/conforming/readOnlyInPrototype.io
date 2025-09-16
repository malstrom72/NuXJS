> TestObject=function() { }; Object.defineProperty(TestObject.prototype, 'z', { value:'f', writable:false, configurable: false });
-
> x=new TestObject;
-
> print(x.z)
< f
-
> x.z='a'
-
> print(x.z)
< f
-
> print(x.hasOwnProperty('z'));
< false
-
> print(delete x.z);
< true
-
