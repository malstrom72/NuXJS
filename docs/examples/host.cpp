/**
NuXJS is released under the BSD 2-Clause License.

The example host that docs/Host Guide.md walks through: it loads a "rules" script, gives it a host object and a
native class, sends it events and reports what goes wrong. buildAndTest runs it and compares its output with
expected_host.txt.
**/

#include <iostream>
#include <string>
#include "../../src/NuXJS.h"

using namespace NuXJS;

static Var hostLog(Runtime& rt, const Var&, const VarList& args) {
	const String* const text = (args.size() > 0 ? static_cast<const String*>(args[0]) : &EMPTY_STRING);
	std::cout << "  [script] " << text->toUTF8String() << std::endl;
	return Var(rt);
}

static Var hostScale(Runtime& rt, const Var&, const VarList& args) {
	if (args.size() < 1 || !args[0].to<Value>().isNumber()) {
		ScriptException::throwError(rt.getHeap(), TYPE_ERROR, "host.scale() expects a number");
	}
	return Var(rt, args[0].to<double>() * 2.0);
}

class Meter : public JSObject {
	public:
		typedef JSObject super;
		static const String CLASS_NAME;

		Meter(GCList& gcList, Object* prototype) : super(gcList, prototype), count(0), highest(0.0) { }
		virtual const String* getClassName() const { return &CLASS_NAME; }

		static Var createConstructor(Runtime& rt) {
			Var prototype = rt.newObjectVar();
			prototype["add"] = add;
			prototype["highest"] = highestValue;
			Var constructor(rt, construct);
			constructor["prototype"] = prototype;
			prototype["constructor"] = constructor;
			return constructor;
		}

	protected:
		UInt32 count;
		double highest;

		static Var construct(Runtime& rt, const Var& thisObject, const VarList&) {
			Heap& heap = rt.getHeap();
			Object* const self = thisObject.to<Value>().asObject();
			if (self == 0 || self == rt.getGlobalObject()) {
				ScriptException::throwError(heap, TYPE_ERROR, "Meter must be called with new");
			}
			return Var(rt, new(heap) Meter(heap.managed(), self->getPrototype(rt)));
		}

		static Meter* checkedSelf(Runtime& rt, const Var& thisObject) {
			Object* const object = thisObject.to<Value>().asObject();
			if (object == 0 || object->getClassName() != &CLASS_NAME) {
				ScriptException::throwError(rt.getHeap(), TYPE_ERROR, "can only be used on a Meter");
			}
			return static_cast<Meter*>(object);
		}

		static Var add(Runtime& rt, const Var& thisObject, const VarList& args) {
			Meter* const self = checkedSelf(rt, thisObject);
			if (args.size() < 1 || !args[0].to<Value>().isNumber()) {
				ScriptException::throwError(rt.getHeap(), TYPE_ERROR, "Meter.add() expects a number");
			}
			const double value = args[0].to<double>();
			self->highest = (self->count == 0 || value > self->highest ? value : self->highest);
			++self->count;
			return thisObject;
		}

		static Var highestValue(Runtime& rt, const Var& thisObject, const VarList&) {
			return Var(rt, checkedSelf(rt, thisObject)->highest);
		}
};

const String Meter::CLASS_NAME("Meter");

static void report(const char* what, const std::exception& x) {
	std::cout << "  " << what << ": " << x.what() << std::endl;
}

static void reportScriptError(const ScriptException& x) {
	std::cout << "  error: " << x.getStackTrace() << std::endl;
}

static void load(Runtime& rt, const char* fileName, const char* text) {
	std::cout << "load " << fileName << std::endl;
	try {
		Var source(rt, text);
		Var name(rt, fileName);
		const Code* code = rt.compileGlobalCode(source, name);
		Processor processor(rt);
		processor.enterGlobalCode(code);
		while (processor.run(1000)) {	// the host's own loop: other work could go between batches
			rt.autoGC(true);
			rt.checkTimeOut();
		}
	} catch (const ScriptException& x) {
		reportScriptError(x);
	} catch (const Exception& x) {
		report("stopped", x);
	}
}

static void sendEvent(Runtime& rt, const char* name, double value) {
	std::cout << "event " << name << ' ' << value << std::endl;
	try {
		Var handler = rt.getGlobalsVar()["onEvent"];
		handler(Var(rt, name), value);
	} catch (const ScriptException& x) {
		reportScriptError(x);
	} catch (const Exception& x) {
		report("stopped", x);
	}
}

int main() {
	Heap heap;
	heap.setMaxAllocationSize(4 * 1024 * 1024);
	Runtime rt(heap);
	rt.setupStandardLibrary();
	rt.setMemoryCap(16 * 1024 * 1024);

	Var host = rt.newObjectVar();
	host["log"] = hostLog;
	host["scale"] = hostScale;
	rt.getGlobalsVar()["host"] = host;
	rt.getGlobalsVar()["Meter"] = Meter::createConstructor(rt);

	load(rt, "rules.js",
		"var total = 0, loudest = new Meter();\n"
		"function onEvent(name, value) {\n"
		"\ttotal += host.scale(value);\n"
		"\tloudest.add(value);\n"
		"\thost.log(name + ' brings the total to ' + total + ', the loudest so far is ' + loudest.highest());\n"
		"\tif (name === 'oops') undefinedRule();\n"
		"\tif (name === 'wrong') host.scale('ten');\n"
		"\tif (name === 'misuse') { var add = loudest.add; add(value); }\n"
		"}\n");
	sendEvent(rt, "note", 60);
	sendEvent(rt, "note", 4.5);
	sendEvent(rt, "oops", 1);
	sendEvent(rt, "wrong", 1);
	sendEvent(rt, "misuse", 64);

	load(rt, "broken.js", "function onEvent(name, value {\n}\n");

	load(rt, "greedy.js", "(function () { var a = []; for (;;) a.push(new Array(1000)); })();\n");

	rt.resetTimeOut(1);
	load(rt, "spin.js", "for (;;) { }\n");
	rt.noTimeOut();

	sendEvent(rt, "note", 0.5);
	return 0;
}
