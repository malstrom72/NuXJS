#include <iostream>
#include "../src/NuXJScript.h"

using namespace NuXJS;

int main() {
    Heap heap;
    Runtime rt(heap);
    rt.setupStandardLibrary();

    Var globals = rt.getGlobalsVar();
    Var parse = globals["JSON"]["parse"];
    Var stringify = globals["JSON"]["stringify"];

    heap.gc(); // for testing purposes only

    Var obj = parse(std::wstring(L"{\"a\":1,\"b\":2}"));
    obj["c"] = 3;

    std::wstring text = stringify(obj).to<std::wstring>();
    std::wcout << text << std::endl;

    heap.gc(); // for testing purposes only
    return 0;
}
