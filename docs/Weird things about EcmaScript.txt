Weird things about EcmaScript when it comes to implementing an engine:

According to 11.2.1 (and 8.7.1), any property access may result in a conversion of the target base (i.e. the left-hand side of '.' or '[]') to an object (if it is a "primitive type"). A string is a "primitive type". This means that, in theory, any subscript access ('[]') on a string requires the creation of a temporary full-blown String object (which is then just thrown away).

Workaround in NuXJS: strings are "shallow" objects meaning that they can't be extended but they have properties that can be accessed without any object conversion / creation. Only member calls (on a member in String.prototype) will actually convert "this" to a full-blown "deep" String object. Any such member call *might* indirectly use "this" for extending the String so this is necessary to obtain 100% EcmaScript compatibility.

WRITE ABOUT: scoped catch variable (remember it is ok to eval("x") this catch variable, so one can't simply fake a unique name for it)
	(function() { var x = 88; try { throw "k" } catch (x) { eval("print(x); var x = 5"); print(x) }; print(x) })();

WRITE ABOUT: the discrepancy between internal and script features, like why the hell can a native function react differently if called as constructor or function, when a script function can't?
