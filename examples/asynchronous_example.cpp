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

	// Use two processors running in the same runtime.
	// Each script is stored in a rooted Var so GC won't sweep it while compiling.
	// Pre-declare variables where each processor stores its partial sum to avoid
	// race conditions on a shared variable.
	rt.getGlobalsVar()["partial1"] = 0;
	rt.getGlobalsVar()["partial2"] = 0;

	Var source1(rt,
		"(function(){var s=0,i=0; while(i<5){ s+=i; i++; } partial1=s; })();");
	Var source2(rt,
		"(function(){var s=0,j=5; while(j<10){ s+=j; j++; } partial2=s; })();");

	Processor proc1(rt);
	proc1.enterGlobalCode(rt.compileGlobalCode(source1));
	Processor proc2(rt);
	proc2.enterGlobalCode(rt.compileGlobalCode(source2));
	heap.gc(); // for testing purposes only

	while (true) {
		bool a = proc1.run(5);
		bool b = proc2.run(5);
		if (!a && !b) {
			break;
		}
		std::cout << "tick" << std::endl;
	}

	Var part1 = rt.getGlobalsVar()["partial1"];
	Var part2 = rt.getGlobalsVar()["partial2"];
	heap.gc(); // for testing purposes only
	int result = part1.to<int>() + part2.to<int>();
	std::cout << "result=" << result << std::endl;
	return 0;
}
