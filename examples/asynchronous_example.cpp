#include <iostream>
#include "../src/NuXJScript.h"

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
