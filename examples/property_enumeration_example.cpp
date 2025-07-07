#include <iostream>
#include "../src/NuXJScript.h"

using namespace NuXJS;

int main() {
	Heap heap;
	Runtime rt(heap);
	rt.setupStandardLibrary();

	Object* proto = rt.newJSObject();
	Var protoVar(rt, proto);
	protoVar["inProto"] = std::wstring(L"from proto");

	JSObject* objPtr = new(heap) JSObject(heap.managed(), proto);
	Var obj(rt, objPtr);
	obj["own"] = 1;
	obj["text"] = std::wstring(L"hello");
	obj["number"] = 42;
	Object* nested = rt.newJSObject();
	Var nestedVar(rt, nested);
	nestedVar["inner"] = 3.14;
	obj["nested"] = nested;

	heap.gc(); // for testing purposes only

	for (Var::const_iterator it = obj.begin(); it != obj.end(); ++it) {
		std::wstring name = (*it).to<std::wstring>();
		std::wcout << name << L" = " << obj[*it].to<std::wstring>() << std::endl;
	}

	heap.gc(); // for testing purposes only

	return 0;
}
