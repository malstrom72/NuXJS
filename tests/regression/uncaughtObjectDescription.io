// An uncaught value is reported the way String(e) would render it, so an object used as an exception can say
// what went wrong. Errors already stringified natively; everything else read as [object Object] however much
// detail it carried, which is exactly what a test harness throws. Reporting runs the object's own toString, so
// each way that can go wrong has to fall back rather than replace the failure being reported.
// A plain object still has only Object.prototype.toString, so it reads as before.
> throw {}
! !!!! [object Object]
-
// The whole point: a toString of its own is used.
> function E(m) { this.message = m } E.prototype.toString = function () { return "E: " + this.message }; throw new E("the real message")
! !!!! E: the real message
-
// A toString that throws must not replace the exception being reported.
> function B() {} B.prototype.toString = function () { throw new Error("secondary") }; throw new B()
! !!!! [object Object]
-
// 9.8 would try valueOf next; for a diagnostic we just fall back, and in particular do not report "1".
> function N() {} N.prototype.toString = function () { return 1 }; N.prototype.valueOf = function () { return 2 }; throw new N()
! !!!! [object Object]
-
// A toString that recurses is stopped by the cross-call recursion limit, not by a crash.
> function R() {} R.prototype.toString = function () { return String(new R()) }; throw new R()
! !!!! [object Object]
-
// Primitives never enter the object path at all. A thrown string is the common case in the older tests.
> throw "plain string"
! !!!! plain string
-
> throw 42
! !!!! 42
-
> throw null
! !!!! null
-
// Errors are unchanged, which is what keeps every existing fixture valid.
> throw new TypeError("still native")
! !!!! TypeError: still native
-
