. combine dynamic scope (calls) and lexical scope (closures) into scope objects with two different linked list chains
	- done: slight performance improvement
. native functions also have scopes
. have resume, suspend methods that stores/restores ip etc or calls natives
. possibly move vstack into scope (have vsp per scope so that we can correctly garbage collect)
