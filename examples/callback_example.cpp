/**
	NuXJS is released under the BSD 2-Clause License.

	Copyright (c) 2018-2025, Magnus Lidström

	Redistribution and use in source and binary forms, with or without modification, are permitted provided that the
	following conditions are met:

	1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following
	disclaimer.

	2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following
	disclaimer in the documentation and/or other materials provided with the distribution.

	THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
	INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
	DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
	SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
	SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
	WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
	OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
**/

#include <iostream>
#include "../src/NuXJS.h"

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
