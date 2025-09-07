> var r=/(aa|aabaac|ba|b|c)*/.exec({toString:function(){return {};}, valueOf:function(){return "aabaac";}})
> print(r[0])
> print(r.index)
< aabaac
< 0
-
