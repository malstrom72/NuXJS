#include <iostream>
#include "../src/NuXJScript.h"

using namespace NuXJS;

// Simple C++ function exposed to JavaScript.
static Var echo(Runtime& rt, const Var&, const VarList& args) {
	// Print the first argument passed from JavaScript
	if (args.size() > 0) {
		std::wcout << L"C++ callback received: " << args[0].to<std::wstring>() << std::endl;
		return args[0];
	}
	return Var(rt);
}

int main() {
	Heap heap;
	Runtime rt(heap);
	rt.setupStandardLibrary();

	Var globals = rt.getGlobalsVar();
	globals["echo"] = echo; // expose C++ function

	heap.gc(); // for testing purposes only

	// Define a JavaScript function that repeatedly calls back into C++
	rt.run(
		"function callEcho(n) {\n" \
		"    for (var i = 0; i < n; ++i) {\n" \
		"        echo('iteration ' + i);\n" \
		"    }\n" \
		"    return n;\n" \
		"}"
	);

	Var result = globals["callEcho"](3);
	std::wcout << L"JavaScript returned: " << result.to<int>() << std::endl;

	heap.gc(); // for testing purposes only

	return 0;
}
