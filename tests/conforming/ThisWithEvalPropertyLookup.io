> var o = { f: function() { print(this.m); }, m: "member" }; o.f();
< member
-
> var o = { f: function() { with (this) { print(m) } }, m: "member" }; o.f();
< member
-
> var o = { f: function() { with (this) { print(this.m) } }, m: "member" }; o.f();
< member
-
> var o = { f: function() { with (this) { print(eval("this.m")) } }, m: "member" }; o.f();
< member
-
> var o = { f: function() { try { throw this } catch (x) { with (x) { print(eval("this.m")) } } }, m: "member" }; o.f();
< member
-
> var o = { f: function() { try { throw this } catch (x) { with (x) { print(eval("m")) } } }, m: "member" }; o.f();
< member
-
> var o = { f: function() { try { } finally { with (this) { print(eval("m")) } } }, m: "member" }; o.f();
< member
-
> var o = { f: function() { try { return } finally { with (this) { print(eval("m")) } } }, m: "member" }; o.f();
< member
-
