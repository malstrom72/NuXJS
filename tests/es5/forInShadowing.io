// 12.6.4: shadowing ignores [[Enumerable]] - an own non-enumerable property hides the prototype's enumerable one
// from for-in and Object.keys alike - and own names come before prototype names.
> var proto = { p: "protoVal", shared: 1 };
> function C() {} C.prototype = proto;
> var child = new C(); child.q = 2;
> Object.defineProperty(child, "p", { value: "ownVal", enumerable: false });
> var seen = []; for (var k in child) seen.push(k);
> print("[" + seen.join(",") + "]")
< [q,shared]
> print("[" + Object.keys(child).join(",") + "]")
< [q]
-
// Two enumerable levels: the nearer level's name wins and the farther one is suppressed, not doubled.
> var grand = { g: 1, both: "far" }; var mid = Object.create(grand); mid.both = "near";
> var leaf = Object.create(mid); leaf.own = 0;
> var order = []; for (var k in leaf) order.push(k);
> print("[" + order.join(",") + "]")
< [own,both,g]
-
