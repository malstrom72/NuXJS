#include <iostream>
#include "../src/NuXJScript.h"

using namespace NuXJS;

int main() {
    Heap heap;
    Runtime rt(heap);
    rt.setupStandardLibrary();

    // Use two processors running in the same runtime.
    // Each script is stored in a rooted Var so GC won't sweep it while compiling.
    // Pre-declare a shared result variable
    rt.getGlobalsVar()["sum"] = 0;

    Var source1(rt, "var i=0; while(i<5){ sum+=i; i++; }");
    Var source2(rt, "var j=5; while(j<10){ sum+=j; j++; }");

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

    Var resultVar = rt.getGlobalsVar()["sum"];
    heap.gc(); // for testing purposes only
    std::cout << "result=" << resultVar.to<int>() << std::endl;
    return 0;
}
