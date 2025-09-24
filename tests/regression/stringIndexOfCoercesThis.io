// CLI:
> obj = { toString: function() { return "xyz"; } }
> print(String.prototype.indexOf.call(obj, "y"))
< 1
-
