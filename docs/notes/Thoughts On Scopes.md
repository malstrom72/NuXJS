Variant 1: shared big value stack in processor, vm instructions are executed by the shared processor
	Pros: 	*) can more effectively reuse stack space, e.g. after a function call the arguments are copied to scope and then immediately reclaimed
			*) slightly faster than variant 2 (around 10% at most)
			*) global scope can be truly global cause there is nothing in it that ever changes
	Cons:	*) cannot point right into value stacks (e.g. for native arguments) because they need to be able to grow (and thus be reallocated)
			*) no easy way to shrink allocated stack, e.g. after extreme use
			*) vstack, ip, locals and constant pointers all reside in the shared processor and must be updated on function entry/exit

Variant 2: value stack (combined with variables) in scope, vm instructions are executed by each scope
	Pros: 	*) no need to grow value stack = ok to point right into value stacks, e.g. for native arguments
			*) no need to shrink stack
			*) vstack, ip, locals and constant pointers can all reside in the scope, which means we have fast direct access to them
	Cons:	*) stack space cannot be reused as effectively
			*) closures retains instructon pointer, value stack elements etc unnecessarily
			*) slightly slower than variant 1 (around 10% at most)
			*) global scope needs vstack with different sizes depending on code, thus we need either an extra temporary layer or allow multiple global scopes or allow reallocating vstack for the global scope
