#include <iostream>
#include "../src/NuXJScript.h"

using namespace NuXJS;

int main() {
	Heap heap;
	Runtime rt(heap);
	rt.setupStandardLibrary();

	rt.setMemoryCap(1024 * 10); // 10 KiB
	rt.resetTimeOut(1); // 1 second

	heap.gc(); // for testing purposes only

	try {
		rt.run("var list = []; while (true) { list.push('x'); }");
	} catch (const ScriptException& ex) {
		std::wcout << L"ScriptException: " << ex.what() << std::endl;
	} catch (const ConstStringException& ex) {
		std::wcout << L"Runtime limit hit: " << ex.what() << std::endl;
		heap.gc(); // for testing purposes only
	}
	return 0;
}
