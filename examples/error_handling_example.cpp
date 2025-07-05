#include <iostream>
#include <stdexcept>
#include "../src/NuXJScript.h"

using namespace NuXJS;

static Var risky(Runtime& rt, const Var&, const VarList&) {
    Heap& heap = rt.getHeap();
    try {
        throw std::runtime_error("C++ failure");
    } catch (const std::exception& e) {
        ScriptException::throwError(heap, GENERIC_ERROR, e.what());
    }
    return Var(rt);
}

int main() {
    Heap heap;
    Runtime rt(heap);
    rt.setupStandardLibrary();

    Var globals = rt.getGlobalsVar();
    globals["risky"] = risky;

    heap.gc(); // for testing purposes only

    try {
        rt.run("try { risky(); } catch (e) { print('JS caught: ' + e); throw e; }");
        heap.gc(); // for testing purposes only
    } catch (const ScriptException& ex) {
        std::wcout << L"C++ caught again: " << ex.what() << std::endl;
        heap.gc(); // for testing purposes only
    }
    return 0;
}
