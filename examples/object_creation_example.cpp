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

int main() {
	Heap heap;
	Runtime rt(heap);
	rt.setupStandardLibrary();

	// Create an object with nested array
	Var user = rt.newObjectVar();
	user["name"] = std::wstring(L"Alice");
	user["age"] = 30;

	Var hobbies = rt.newArrayVar();
	hobbies[0] = std::wstring(L"coding");
	hobbies[1] = std::wstring(L"music");
	user["hobbies"] = hobbies;

	// Expose object to JavaScript
	Var globals = rt.getGlobalsVar();
	globals["user"] = user;

	heap.gc(); // for testing purposes only

	// JavaScript function that modifies the object
	rt.run(
		"function addHobby(obj, hobby) {\n" \
		"    obj.hobbies.push(hobby);\n" \
		"    obj.age += 1;\n" \
		"    return obj;\n" \
		"}"
	);

	Var updated = globals["addHobby"](user, std::wstring(L"photography"));

	// Print the updated object via JSON.stringify
	Var stringify = globals["JSON"]["stringify"];
	heap.gc(); // for testing purposes only
	std::wstring text = stringify(updated).to<std::wstring>();
	std::wcout << L"Updated user: " << text << std::endl;

	heap.gc(); // for testing purposes only

	return 0;
}
