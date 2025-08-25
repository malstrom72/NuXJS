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

	Var globals = rt.getGlobalsVar();
rt.run(
"var obj = {\n" \
"\t_v: 1,\n" \
"\tget value() { return this._v; },\n" \
"\tset value(v) { this._v = v; },\n" \
"\tget double() { return this._v * 2; },\n" \
"\tset double(v) { this._v = v / 2; }\n" \
"};\n" \
"var start = obj.value;\n" \
"var startDouble = obj.double;\n" \
"obj.double = 50;\n" \
"var afterSetDouble = obj.value;\n" \
"obj.value = 15;\n" \
"var finalDouble = obj.double;"
);
	Var obj = globals["obj"];
	std::wcout << L"start = " << globals["start"].to<int>() << std::endl;
	std::wcout << L"startDouble = " << globals["startDouble"].to<int>() << std::endl;
	std::wcout << L"afterSetDouble = " << globals["afterSetDouble"].to<int>() << std::endl;
	std::wcout << L"finalDouble = " << globals["finalDouble"].to<int>() << std::endl;
	std::wcout << L"obj._v = " << obj["_v"].to<int>() << std::endl;
	return 0;
}
