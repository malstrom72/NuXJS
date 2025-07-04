# NuXJS
A sandboxed, single C++ source, JavaScript engine with fine-grained control over execution.

## Features

- **Fully EcmaScript 3 compliant** with partial EcmaScript 5 support where it is most essential.
- The entire source is **two small .cpp files and one .h file**. (Total line count is around 7000.)
- Written in standard architecture-agnostic vanilla C++03. Virtually **no platform-specific code**.
- Fully asynchronous **non-blocking virtual machine**. You can run as many processor cycles as you want at a time.
- Simple but reasonably **fast stack machine**. (Should perform well compared to other interpreting JS engines.)
- **Sandboxed and secure**. JavaScript code should never be able to crash the host application.
- Instantiate **any number of engines** in as many or as few threads that you wish.
- Reentrant and **thread-safe by design**. (No global variables, no data is implicitly shared between engines.)
- **Fast single-pass JavaScript compiler**. (Handwritten recursive descent/operator precedence parser.)
- Mark-and-sweep (stop-the-world) **GC with adaptive rate of invocation** and memory usage cap.
- Uses standard C++ heap (allocations are done with new, etc) with **pools for quick allocation** of small objects.
- **Few library dependencies** (does not even use the standard C++ containers).
- Built-in **standard library written in JavaScript** for non-blocking and secure execution.
- **Regular expressions compiler** also written in Javascript. (Compiles to JavaScript functions.)
- Optional **easy-to-use** high-level C++ API.
- **Zero tolerance for bugs**. Plenty of tests.

## Why ECMAScript 3?

ECMAScript 3 was the first widely adopted standardized version of JavaScript. It is a version that many programmers are
familiar with, and imho it has got everything you need from a *scripting* language. Naturally, more recent versions of
ECMAScript offers improvements, but at the cost of larger standard libraries and more complex compilers/interpreters.
There is also something positive to be said about a standard that remained unchanged for ten years. No denying it,
ECMAScript 3 was a hugely successful version of JavaScript and a good starting point for this implementation.

With that said, there are a few features from ECMAScript 5 that I felt necessary to "retrofit" into this engine. Most
notably:

- Array indexed properties [ ] for reading individual characters from String objects.
- JSON support.

## Why C++03?

This project originally began a few years before the release of C++11. When I picked it up again, many years late,r I
decided to stick to the original C++03 style. Since the code is written in such a simple style (just a few basic
templates and then plain vanilla C++ classes) and has so few dependencies on the C++ standard library, it feels almost
irrelevant to update to a later C++ version.

## High-level API Examples

A simple hello world.

```cpp
#include <NuXJScript.h>
using namespace NuXJS;

int main(int argc, const char* argv[]) {
    Heap heap;                                          // We use the standard heap.
    Runtime rt(heap);                                   // Construct an empty engine.
    rt.setupStandardLibrary();                          // Install the ES3 standard library.
    Var helloWorld = rt.eval("'hello ' + 'world'");     // Evaluate a JS expression.
    std::wcout << helloWorld << std::endl;
    return 0;
}
```

A slightly more complex program showing some security features, sharing of data and functions, and more.

```cpp
#include <NuXJScript.h>
using namespace NuXJS;

// C++ functions that you want to call from JavaScript should have these arguments.
static Var sum(Runtime& rt, const Var& thisVar, const VarList& args) {
    double sum = 0.0;
    for (int i = 0; i < args.size(); ++i) {
        sum += args[i];
    }
    return Var(rt, sum);    // A `Var` owns its `Value` (sum) and is tied to a `Runtime` (rt)
}

int main(int argc, const char* argv[]) {
    Heap heap;                                          // We use the standard heap.
    Runtime rt(heap);                                   // Construct an empty engine.
    rt.setupStandardLibrary();                          // Install the ES3 standard library.
    rt.setMemoryCap(1024 * 1024);                       // Max 1MB of memory please.
    rt.resetTimeOut(10);                                // Time-out JS code after 10 seconds.
    Var globals = rt.getGlobalsVar();
    
    // Set up the native function and a JS demo function that calls it.
    globals["sum"] = sum;
    rt.run("function demo(a,b,c) { return 'a+b+c = ' + sum(a,b,c); }");
    std::wcout << globals["demo"](7, 15, 20) << std::endl;
    
    // Lets go silly. Create an anonymous function with eval that simply returns its arguments.
    Var sillyFunction = rt.eval("(function() { return arguments; })");
    
    // `Var` protects data from being garbage collected.
    // In this case, a `String` is created on the heap for "131".
    Var oneThreeOne(rt, "131");
    
    // If we have more arguments than there, we use a `Value` array instead.
    const Value args[10] = { oneThreeOne, 535, 236, 984, 456.5, 666, 626, 585, 382, 109.5 };

    // Call the silly function. The VarList encapsulates and protects the argument values.
    Var list = sillyFunction(VarList(rt, 10, args));
    
    // Now call the equivalent of the JavaScript code: `sum.apply(null, list)` from C++.
    std::wcout << globals["sum"]["apply"](Value::NUL, list) << std::endl;
    
	// C++ == operator checks for strict equality like JS ===
	std::wcout << "1 == true: " << (Var(rt, 1) == true ? "true" : "false") << std::endl;
	
	// Use equals() to check for equality like JS ==
	std::wcout << "1.equals(true): " << (Var(rt, 1).equals(true) ? "true" : "false") << std::endl;

	// There is no support for calling a Javascript constructor directly from C++ so we have to make a little stub.
	const int year = 2008, month = 7, day = 20;
	Var dateVar = rt.eval("(function(y, m, d) { return new Date(y, m, d) })")(year, month, day);

	// Converting a Var to string never calls JavaScript's toString() method. This will output '[object Date]'.
	std::wcout << dateVar << std::endl;

	// But naturally, you can call toString() manually. This will output 2008-08-20 00:00:00.
	Var dateString = dateVar["toString"]();
	std::wcout << dateString << std::endl;

	// Var::const_iterator will enumerate all properties, similar to the JavaScript "for in" statement.
	Var anArray = rt.eval("[ 4, 8, 15, 16, 23, 42]");
	for (Var::const_iterator it = anArray.begin(); it != anArray.end(); ++it) {
		std::wcout << anArray[*it] << ' ';
	}
	std::wcout << std::endl;

    return 0;
}
```


