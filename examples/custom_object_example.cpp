#include <iostream>
#include "../src/NuXJScript.h"

using namespace NuXJS;

static const String COUNTER_CLASS_NAME("Counter");

class Counter : public JSObject {
public:
    typedef JSObject super;
    Counter(GCList& gcList, Object* proto = 0)
        : super(gcList, proto), value(0) {}
    virtual const String* getClassName() const { return className; }

    static Var increment(Runtime& rt, const Var& thisObj, const VarList&) {
        Counter* self = static_cast<Counter*>(thisObj.to<Object*>());
        ++self->value;
        return Var(rt, self->value);
    }

    int value;
    static const String* className;
};

const String* Counter::className = &COUNTER_CLASS_NAME;

int main() {
    Heap heap;
    Runtime rt(heap);
    rt.setupStandardLibrary();

    Object* proto = rt.newJSObject();
    Var protoVar(rt, proto);
    protoVar["increment"] = Counter::increment;

    Counter* cObj = new(heap) Counter(heap.managed(), proto);
    Var counter(rt, cObj);

    heap.gc(); // for testing purposes only

    Var globals = rt.getGlobalsVar();
    globals["counter"] = counter;

    rt.run("for (var i=0;i<3;i++) counter.increment();");

    heap.gc(); // for testing purposes only

    std::wcout << L"Counter value: " << cObj->value << std::endl;
    return 0;
}
