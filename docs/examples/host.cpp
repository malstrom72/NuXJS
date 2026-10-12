/**
NuXJS is released under the BSD 2-Clause License.

The example host that docs/Host Guide.md walks through: it loads a "rules" script, gives it a host object, sends it
events and reports what goes wrong. buildAndTest runs it and compares its output with expected_host.txt.
**/

#include <iostream>
#include <string>
#include "../../src/NuXJS.h"

using namespace NuXJS;

static int eventsSent = 0;

static Var hostLog(Runtime& rt, const Var&, const VarList& args) {
	const String* const text = (args.size() > 0 ? static_cast<const String*>(args[0]) : &EMPTY_STRING);
	std::cout << "  [script] " << text->toUTF8String() << std::endl;
	return Var(rt);
}

static Var hostEventCount(Runtime& rt, const Var&, const VarList&) {
	return Var(rt, eventsSent);
}

static Var hostScale(Runtime& rt, const Var&, const VarList& args) {
	if (args.size() < 1 || !args[0].to<Value>().isNumber()) {
		ScriptException::throwError(rt.getHeap(), TYPE_ERROR, "host.scale() expects a number");
	}
	return Var(rt, args[0].to<double>() * 2.0);
}

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
	} catch (const CompilationError& x) {
		std::cout << "  syntax: " << x.filename->toUTF8String() << ':' << x.lineNumber << ':' << x.columnNumber << ": "
				<< x.what() << std::endl;
	} catch (const ScriptException& x) {
		reportScriptError(x);
	} catch (const Exception& x) {
		report("stopped", x);
	}
}

static void sendEvent(Runtime& rt, const char* name, double value) {
	std::cout << "event " << name << ' ' << value << std::endl;
	++eventsSent;
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
	host["eventCount"] = hostEventCount;
	host["scale"] = hostScale;
	rt.getGlobalsVar()["host"] = host;

	load(rt, "rules.js",
		"var total = 0;\n"
		"function onEvent(name, value) {\n"
		"\ttotal += host.scale(value);\n"
		"\thost.log(name + ' brings the total to ' + total + ' after ' + host.eventCount() + ' events');\n"
		"\tif (name === 'oops') undefinedRule();\n"
		"\tif (name === 'wrong') host.scale('ten');\n"
		"}\n");
	sendEvent(rt, "note", 60);
	sendEvent(rt, "note", 4.5);
	sendEvent(rt, "oops", 1);
	sendEvent(rt, "wrong", 1);

	load(rt, "broken.js", "function onEvent(name, value {\n}\n");

	load(rt, "greedy.js", "(function () { var a = []; for (;;) a.push(new Array(1000)); })();\n");

	rt.resetTimeOut(1);
	load(rt, "spin.js", "for (;;) { }\n");
	rt.noTimeOut();

	sendEvent(rt, "note", 0.5);
	return 0;
}
