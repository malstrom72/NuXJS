/**
NuXJS is released under the BSD 2-Clause License.

This file merges all example programs into a single translation unit
and runs them sequentially for faster builds.
**/

#include <iostream>
#include <stdexcept>
#include <string>
#include "../src/NuXJS.h"

using namespace NuXJS;

int asynchronous_example_main() {
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


// Simple C++ function exposed to JavaScript.
static Var echo(Runtime& rt, const Var&, const VarList& args) {
	// Print the first argument passed from JavaScript
	if (args.size() > 0) {
		std::wcout << L"C++ callback received: " << args[0].to<std::wstring>() << std::endl;
		return args[0];
	}
	return Var(rt);
}

int callback_example_main() {
	Heap heap;
	Runtime rt(heap);
	rt.setupStandardLibrary();

	Var globals = rt.getGlobalsVar();
	globals["echo"] = echo; // expose C++ function

	heap.gc(); // for testing purposes only

	// Define a JavaScript function that repeatedly calls back into C++
	rt.run(
		"function callEcho(n) {\n" \
		"    for (var i = 0; i < n; ++i) {\n" \
		"        echo('iteration ' + i);\n" \
		"    }\n" \
		"    return n;\n" \
		"}"
	);

	Var result = globals["callEcho"](3);
	std::wcout << L"JavaScript returned: " << result.to<int>() << std::endl;

	heap.gc(); // for testing purposes only

	return 0;
}


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

int custom_object_example_main() {
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


static Var risky(Runtime& rt, const Var&, const VarList&) {
	Heap& heap = rt.getHeap();
	try {
		throw std::runtime_error("C++ failure");
	} catch (const std::exception& e) {
		ScriptException::throwError(heap, GENERIC_ERROR, e.what());
	}
	return Var(rt);
}

int error_handling_example_main() {
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

int json_conversion_example_main() {
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

int object_creation_example_main() {
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

int property_enumeration_example_main() {
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

int time_memory_limits_example_main() {
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

int main() {
	int fail = 0;
	std::cout << "=== asynchronous_example ===" << std::endl;
	fail |= asynchronous_example_main();
	std::cout << "=== callback_example ===" << std::endl;
	fail |= callback_example_main();
	std::cout << "=== custom_object_example ===" << std::endl;
	fail |= custom_object_example_main();
	std::cout << "=== error_handling_example ===" << std::endl;
	fail |= error_handling_example_main();
	std::cout << "=== json_conversion_example ===" << std::endl;
	fail |= json_conversion_example_main();
	std::cout << "=== object_creation_example ===" << std::endl;
	fail |= object_creation_example_main();
	std::cout << "=== property_enumeration_example ===" << std::endl;
	fail |= property_enumeration_example_main();
	std::cout << "=== time_memory_limits_example ===" << std::endl;
	fail |= time_memory_limits_example_main();
	return fail;
}
