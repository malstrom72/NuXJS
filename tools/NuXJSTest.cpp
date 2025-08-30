/**
	NuXJS is released under the BSD 2-Clause License.

	Copyright (c) 2018-2025, Magnus Lidström

	Redistribution and use in source and binary forms, with or without modification, are permitted provided that the
	following conditions are met:

	1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following
	disclaimer.

	2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following
	disclaimer in the documentation and/or other materials provided with the distribution.

	THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
	INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
	DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
	SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
	SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
	WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
	OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
**/

#include <stdint.h>
#include "../src/NuXJS.h"
#include <fstream>
#include <memory>
#include <vector>
#include <sstream>
#include <ctime>
#include <algorithm>

using namespace NuXJS;

// --- Tiny test framework ---

static int testCount = 0;
static int failureCount = 0;

static void expectationFailed(const char* sourceCode, const char* file, int line) {
	std::cout << "Failure: " << sourceCode << ", file: " << file << ", line: " << line << std::endl;
	++failureCount;
}

static void unexpectedException(const char* expression, const char* file, int line, const char* s) {
	expectationFailed(expression, file, line);
	std::cout << "  Unexpected exception: " << s << std::endl << std::endl;
}

static void expectedException(const char* statement, const char* file, int line, const char* s) {
	expectationFailed(statement, file, line);
	std::cout << "  Expected exception: " << s << std::endl << std::endl;
}

static void checkException(const char* statement, const char* file, int line, const char* got, const char* expected) {
	if (std::strcmp(got, expected) != 0) {
		expectationFailed(statement, file, line);
		std::cout << "  Unexpected exception: " << got << std::endl;
		std::cout << "  Expected: " << expected << std::endl << std::endl;
	}
}

template<typename T, typename U> static void expectEqual(const char* expression, const T& got, const U& expected
		, const char* file, int line) {
	if (!(got == expected)) {
		expectationFailed(expression, file, line);
		std::wcout << L"  Unexpected result: " << got << std::endl;
		std::wcout << L"  Expected result: " << expected << std::endl << std::endl;
	}
}

template<typename T, typename U> static void expectNotEqual(const char* expression, const T& result, const U& notEqual
		, const char* file, int line) {
	if (!(result != notEqual)) {
		expectationFailed(expression, file, line);
		std::wcout << L"  Result: " << result << std::endl;
		std::wcout << L"  Equals: " << notEqual << std::endl << std::endl;
	}
}

#define EXPECT(c) \
	do { try { ++testCount; if (!(c)) { expectationFailed(#c, __FILE__, __LINE__); std::cout << std::endl; } } \
	catch (const std::exception& x) { unexpectedException(#c, __FILE__, __LINE__, x.what()); } \
	catch (...) { unexpectedException(#c, __FILE__, __LINE__, "(unknown exception)"); } } while (false)

#define EXPECT_EQUAL(a, b) \
	do { try { ++testCount; expectEqual(#a " == " #b, a, b, __FILE__, __LINE__); } \
	catch (const std::exception& x) { unexpectedException(#a " == " #b, __FILE__, __LINE__, x.what()); } \
	catch (...) { unexpectedException(#a " == " #b, __FILE__, __LINE__, "(unknown exception)"); } } while (false)

#define EXPECT_NOT_EQUAL(a, b) \
	do { try { ++testCount; expectNotEqual(#a " != " #b, a, b, __FILE__, __LINE__); } \
	catch (const std::exception& x) { unexpectedException(#a " != " #b, __FILE__, __LINE__, x.what()); } \
	catch (...) { unexpectedException(#a " != " #b, __FILE__, __LINE__, "(unknown exception)"); } } while (false)

#define EXPECT_NO_EXCEPTION(s) \
	try { ++testCount; s; } \
	catch (const std::exception& x) { unexpectedException(#s, __FILE__, __LINE__, x.what()); } \
	catch (...) { unexpectedException(#s, __FILE__, __LINE__, "(unknown exception)"); }

#define EXPECT_EXCEPTION(s, e) \
	try { ++testCount; s; expectedException(#s, __FILE__, __LINE__, (e)); } \
	catch (const Exception& x) { checkException(#s, __FILE__, __LINE__, x.what(), (e)); } \
	catch (const std::exception& x) { unexpectedException(#s, __FILE__, __LINE__, x.what()); } \
	catch (...) { unexpectedException(#s, __FILE__, __LINE__, "(unknown exception)"); }

class XorshiftRandom2x32 {
	public:		XorshiftRandom2x32(unsigned int seed0 = 123456789, unsigned int seed1 = 362436069) : px(seed0), py(seed1) { }

				// full 32-bit range
	public:		unsigned int operator() () throw() {
					const unsigned int t = px ^ (px << 10);
					px = py;
					py = py ^ (py >> 13) ^ t ^ (t >> 10);
					return py;
				}

				// Range [0,maxx]
	public:		unsigned int operator() (const unsigned int maxx) throw() {
					unsigned int used = maxx;
					used |= used >> 1;
					used |= used >> 2;
					used |= used >> 4;
					used |= used >> 8;
					used |= used >> 16;
		
					unsigned int i;
					do {
						i = (*this)() & used;
					} while (i > maxx);
					return i;
				}
	
	protected:	unsigned int px;
	protected:	unsigned int py;
};

template<typename T> void generateRandomValue(XorshiftRandom2x32& prng, T& v) { v = static_cast<T>(prng()); }
template<typename T> T generateRandomValue(XorshiftRandom2x32& prng) { T v; generateRandomValue(prng, v); return v; }
template<> void generateRandomValue(XorshiftRandom2x32& prng, bool& b) { b = ((prng() & 1) != 0); }

struct TestDataClass {
	TestDataClass();
	TestDataClass(const TestDataClass& that);
	void randomize(XorshiftRandom2x32& prng);
	bool operator==(const TestDataClass& that) const;
	~TestDataClass();
	bool boolField;
	int intField;
	double doubleField;
	unsigned int magic;
	static size_t constructedCount;
	static size_t destructedCount;
};
size_t TestDataClass::constructedCount = 0;
size_t TestDataClass::destructedCount = 0;

TestDataClass::TestDataClass() : magic(0x51C37F03), boolField(false), intField(0), doubleField(0.0) {
	++constructedCount;
}

TestDataClass::TestDataClass(const TestDataClass& that) : magic(0x51C37F03) {
	++constructedCount;
	(*this) = that;
}

bool TestDataClass::operator==(const TestDataClass& that) const {
	EXPECT_EQUAL(magic, 0x51C37F03);
	return (boolField == that.boolField && intField == that.intField && doubleField == that.doubleField);
}

void TestDataClass::randomize(XorshiftRandom2x32& prng) {
	EXPECT_EQUAL(magic, 0x51C37F03);
	generateRandomValue(prng, boolField);
	generateRandomValue(prng, intField);
	generateRandomValue(prng, doubleField);
}

TestDataClass::~TestDataClass() {
	EXPECT_EQUAL(magic, 0x51C37F03);
	magic = 0;
	++destructedCount;
}

template<> void generateRandomValue(XorshiftRandom2x32& prng, TestDataClass& s) { s.randomize(prng); }

struct UnreliableConstructorClass {
	UnreliableConstructorClass();
	UnreliableConstructorClass(const UnreliableConstructorClass& that);
	~UnreliableConstructorClass();
	static size_t constructedCount;
	static size_t destructedCount;
};

UnreliableConstructorClass::UnreliableConstructorClass() {
	if (constructedCount >= 10) {
		throw ConstStringException("Evil constructor");
	}
	++constructedCount;
}

UnreliableConstructorClass::UnreliableConstructorClass(const UnreliableConstructorClass&) {
	if (constructedCount >= 10) {
		throw ConstStringException("Evil constructor");
	}
	++constructedCount;
}

UnreliableConstructorClass::~UnreliableConstructorClass() {
	++destructedCount;
}

size_t UnreliableConstructorClass::constructedCount = 0;
size_t UnreliableConstructorClass::destructedCount = 0;

// --- Test classes and functions ---

String TEST_CLASS_STRING("NativeObject");
class NativeObject : public JSObject {
	public:		typedef JSObject super;
	public:		NativeObject(GCList& gcList, Object* prototype) : super(gcList, prototype), x(0.3) { }
	public:		NativeObject(GCList& gcList, Object* prototype, const VarList& args)
						: super(gcList, prototype), x(args[0] != Value::UNDEFINED ? args[0] : 0.0) { if (args[1] != Value::UNDEFINED) { Var me = args[1]; me = this; args[1](); } }
	public:		virtual const String* getClassName() const { return &TEST_CLASS_STRING; }
	public:		static Var testMethod1(Runtime& rt, const Var& thisVar, const VarList& args) {
					(void)args;
					Object* thisObject = thisVar;
					std::wcout << Var(rt, (reinterpret_cast<JSObject*>(thisObject)->JSObject::getClassName())) << std::endl;
					std::wcout << Var(rt, (reinterpret_cast<NativeObject*>(thisObject)->NativeObject::getClassName())) << std::endl;
					std::wcout << Var(rt, (reinterpret_cast<NativeObject*>(thisObject)->getClassName())) << std::endl;
					Var className(rt, thisObject->getClassName());
					if ((reinterpret_cast<NativeObject*>(thisObject)->NativeObject::getClassName())
							!= (reinterpret_cast<NativeObject*>(thisObject)->getClassName())) {
						ScriptException::throwError(rt.getHeap(), TYPE_ERROR, "Invalid class");
					}
					NativeObject* dis = reinterpret_cast<NativeObject*>(thisObject);
					return Var(rt, dis->x);
				}
	public:		static Var construct(Runtime& rt, const Var& thisVar, const VarList& args) {
					Heap& heap = rt.getHeap();
					return Var(rt, new(heap) NativeObject(heap.managed(), static_cast<Object*>(thisVar)->getPrototype(rt), args));
				}
	public:		Var nativeMethod(Runtime& rt, const Var& thisVar, const VarList& args) {
					(void)thisVar;
					(void)args;
					return Var(rt, x);
				}
	protected:	double x;
};

struct BindingTestObject {
	BindingTestObject() : x(123.456) { }
	Var method(Runtime& rt, const Var& thisVar, const VarList& args) {
		(void)thisVar;
		(void)args;
		return Var(rt, x);
	}
	double x;
};

struct NativeConstructor : public ExtensibleFunction {
	typedef ExtensibleFunction super;
	NativeConstructor(GCList& gcList, const Var& prototype) : super(gcList), prototype(prototype) { }
	virtual Value invoke(Runtime& rt, Processor& processor, UInt32 argc, const Value* argv, Object* thisObject) {
		(void)processor;
		(void)thisObject;
		Heap& heap = rt.getHeap();
		return new(heap) NativeObject(heap.managed(), prototype, VarList(rt, argc, argv));
	}
	Var prototype;
};

Var test1(Runtime& rt, const Var& thisVar, const VarList& args) {
	(void)thisVar;
	std::wcout << L"argc: " << args.size() << std::endl;
	std::wcout << L"arg 0: " << args[0] << std::endl;
	std::wcout << L"arg 1: " << args[1] << std::endl;
	std::wcout << L"arg 0 type: " << args[0].typeOf() << std::endl;
	if (args[0].typeOf() == "function") {
		args[0]("znooorf");
	}
	if (args[0] == 21) {
		std::wcout << L"twenty three" << std::endl;
	}
	if (args[0] == Value::NUL) {
		std::wcout << L"nuuuul" << std::endl;
	}
	args[1]["zoom"] = args[0] * 9191;
	return Var(rt, static_cast<double>(args[0]) + args[1]);
}

Value gcTest(Runtime& rt, Processor& processor, UInt32 argc, const Value* argv, Object* thisObject) {
	(void)processor;
	(void)thisObject;
	VarList safeKeep(rt, argc, argv);
	Heap& heap = rt.getHeap();
	heap.gc();
	Value v = String::allocate(heap, "");
	for (UInt32 i = 0; i < argc; ++i) {
		v = String::concatenate(heap, *v.toString(heap), *argv[i].toString(heap));
	}
	return v;
}

/* --- Var tests --- */

static void testVars() {
	std::cout << std::endl << "***** Var *****" << std::endl << std::endl;
	std::cout << "  - primitives and conversions" << std::endl;
	std::cout << "  - numeric edge cases" << std::endl;
	std::cout << "  - objects, arrays and functions" << std::endl;

	Heap heap;
	Runtime rt(heap);
	Var globals = rt.getGlobalsVar();

	const Var undefinedVar(rt);
	const Var undefinedVar2(rt, Value::UNDEFINED);

	EXPECT_EQUAL(undefinedVar, Value::UNDEFINED);
	EXPECT_EQUAL(undefinedVar2, Value::UNDEFINED);
	EXPECT_EQUAL(undefinedVar2, undefinedVar);
	EXPECT_EQUAL(undefinedVar.typeOf(), &UNDEFINED_STRING);
	EXPECT(!undefinedVar.to<bool>());
	EXPECT(isNaN(undefinedVar.to<double>()));
	EXPECT_EXCEPTION(undefinedVar.to<Object*>(), "TypeError: Cannot convert undefined or null to object");
	EXPECT_EXCEPTION(undefinedVar.to<Function*>(), "TypeError: undefined is not a function");
	EXPECT_EQUAL(undefinedVar.to<std::wstring>(), L"undefined");
	EXPECT(undefinedVar.to<const String&>().isEqualTo(L"undefined"));
	EXPECT(undefinedVar.equals(undefinedVar));
	EXPECT_EQUAL(undefinedVar, undefinedVar);
	EXPECT(!(undefinedVar < undefinedVar));
	EXPECT(!(undefinedVar <= undefinedVar));
	EXPECT(!(undefinedVar >= undefinedVar));
	EXPECT(!(undefinedVar > undefinedVar));

	const Var nullVar(rt, Value::NUL);
	EXPECT_EQUAL(nullVar, Value::NUL);
	EXPECT_EQUAL(nullVar.typeOf(), &OBJECT_STRING);
	EXPECT(!nullVar.to<bool>());
	EXPECT_EQUAL(nullVar.to<double>(), 0);
	EXPECT_EXCEPTION(nullVar.to<Object*>(), "TypeError: Cannot convert undefined or null to object");
	EXPECT_EXCEPTION(nullVar.to<Function*>(), "TypeError: null is not a function");
	EXPECT_EQUAL(nullVar.to<std::wstring>(), L"null");
	EXPECT(nullVar.to<const String&>().isEqualTo(L"null"));
	EXPECT(nullVar.equals(nullVar));
	EXPECT_EQUAL(nullVar, nullVar);
	EXPECT(!(nullVar < nullVar));
	EXPECT(nullVar <= nullVar);
	EXPECT(nullVar >= nullVar);
	EXPECT(!(nullVar > nullVar));
	EXPECT(undefinedVar.equals(nullVar));
	EXPECT_NOT_EQUAL(undefinedVar, nullVar);

	const Var falseVar(rt, false);
	EXPECT_EQUAL(falseVar, false);
	EXPECT_EQUAL(falseVar.typeOf(), &BOOLEAN_STRING);
	EXPECT(!falseVar.to<bool>());
	EXPECT_EQUAL(falseVar.to<double>(), 0);
	EXPECT_NOT_EQUAL(falseVar.to<Object*>(), (Object*)(0));
	EXPECT_EXCEPTION(falseVar.to<Function*>(), "TypeError: false is not a function");
	EXPECT_EQUAL(falseVar.to<std::wstring>(), L"false");
	EXPECT(falseVar.to<const String&>().isEqualTo(L"false"));
	EXPECT(falseVar.equals(falseVar));
	EXPECT_EQUAL(falseVar, falseVar);
	EXPECT(!(falseVar < falseVar));
	EXPECT(falseVar <= falseVar);
	EXPECT(falseVar >= falseVar);
	EXPECT(!(falseVar > falseVar));
	EXPECT(!falseVar.equals(undefinedVar));
	EXPECT(!falseVar.equals(nullVar));
	EXPECT_NOT_EQUAL(falseVar, undefinedVar);
	EXPECT_NOT_EQUAL(falseVar, nullVar);

	const Var trueVar(rt, true);
	EXPECT_EQUAL(trueVar, true);
	EXPECT_EQUAL(trueVar.typeOf(), &BOOLEAN_STRING);
	EXPECT(trueVar.to<bool>());
	EXPECT_EQUAL(trueVar.to<double>(), 1);
	EXPECT_NOT_EQUAL(trueVar.to<Object*>(), (Object*)(0));
	EXPECT_EXCEPTION(trueVar.to<Function*>(), "TypeError: true is not a function");
	EXPECT_EQUAL(trueVar.to<std::wstring>(), L"true");
	EXPECT(trueVar.to<const String&>().isEqualTo(L"true"));
	EXPECT(trueVar.equals(trueVar));
	EXPECT(!trueVar.equals(falseVar));
	EXPECT_EQUAL(trueVar, trueVar);
	EXPECT_NOT_EQUAL(trueVar, falseVar);
	EXPECT(!(trueVar < trueVar));
	EXPECT(trueVar <= trueVar);
	EXPECT(trueVar >= trueVar);
	EXPECT(!(trueVar > trueVar));
	EXPECT(!trueVar.equals(undefinedVar));
	EXPECT(!trueVar.equals(nullVar));
	EXPECT_NOT_EQUAL(trueVar, undefinedVar);
	EXPECT_NOT_EQUAL(trueVar, nullVar);

	const Var zeroVar(rt, 0.0);
	EXPECT_EQUAL(zeroVar, 0.0);
	EXPECT_EQUAL(zeroVar.typeOf(), &NUMBER_STRING);
	EXPECT(!zeroVar.to<bool>());
	EXPECT_EQUAL(zeroVar.to<double>(), 0);
	EXPECT(!isNaN(zeroVar));
	EXPECT(isFinite(zeroVar));
	EXPECT_NOT_EQUAL(zeroVar.to<Object*>(), (Object*)(0));
	EXPECT_EXCEPTION(zeroVar.to<Function*>(), "TypeError: 0 is not a function");
	EXPECT_EQUAL(zeroVar.to<std::wstring>(), L"0");
	EXPECT(zeroVar.to<const String&>().isEqualTo(L"0"));
	EXPECT(zeroVar.equals(zeroVar));
	EXPECT_EQUAL(zeroVar, zeroVar);
	EXPECT(!(zeroVar < zeroVar));
	EXPECT(zeroVar <= zeroVar);
	EXPECT(zeroVar >= zeroVar);
	EXPECT(!(zeroVar > zeroVar));
	EXPECT(!zeroVar.equals(undefinedVar));
	EXPECT(!zeroVar.equals(nullVar));
	EXPECT_NOT_EQUAL(zeroVar, undefinedVar);
	EXPECT_NOT_EQUAL(zeroVar, nullVar);
	EXPECT(zeroVar.equals(falseVar));
	EXPECT(!zeroVar.equals(trueVar));
	EXPECT_NOT_EQUAL(zeroVar, falseVar);
	EXPECT_NOT_EQUAL(zeroVar, trueVar);

	const Var positiveNumberVar(rt, 1.33203125);	// exact in binary and decimal: 0x15500/65536.0
	EXPECT_EQUAL(positiveNumberVar, 1.33203125);
	EXPECT_EQUAL(positiveNumberVar.typeOf(), &NUMBER_STRING);
	EXPECT(positiveNumberVar.to<bool>());
	EXPECT_EQUAL(positiveNumberVar.to<double>(), 1.33203125);
	EXPECT(!isNaN(positiveNumberVar));
	EXPECT(isFinite(positiveNumberVar));
	EXPECT_NOT_EQUAL(positiveNumberVar.to<Object*>(), (Object*)(0));
	EXPECT_EXCEPTION(positiveNumberVar.to<Function*>(), "TypeError: 1.33203125 is not a function");
	EXPECT_EQUAL(positiveNumberVar.to<std::wstring>(), L"1.33203125");
	EXPECT(positiveNumberVar.to<const String&>().isEqualTo(L"1.33203125"));
	EXPECT(positiveNumberVar.equals(positiveNumberVar));
	EXPECT_EQUAL(positiveNumberVar, positiveNumberVar);
	EXPECT(!(positiveNumberVar < positiveNumberVar));
	EXPECT(positiveNumberVar <= positiveNumberVar);
	EXPECT(positiveNumberVar >= positiveNumberVar);
	EXPECT(!(positiveNumberVar > positiveNumberVar));
	EXPECT_NOT_EQUAL(positiveNumberVar, zeroVar);
	EXPECT(!(positiveNumberVar < zeroVar));
	EXPECT(!(positiveNumberVar <= zeroVar));
	EXPECT(positiveNumberVar >= zeroVar);
	EXPECT(positiveNumberVar > zeroVar);
	EXPECT(!positiveNumberVar.equals(falseVar));
	EXPECT(!positiveNumberVar.equals(trueVar));
	EXPECT_NOT_EQUAL(positiveNumberVar, falseVar);
	EXPECT_NOT_EQUAL(positiveNumberVar, trueVar);

	const Var negativeNumberVar(rt, -1.33203125);
	EXPECT_EQUAL(negativeNumberVar, -1.33203125);
	EXPECT_EQUAL(negativeNumberVar.typeOf(), &NUMBER_STRING);
	EXPECT(negativeNumberVar.to<bool>());
	EXPECT_EQUAL(negativeNumberVar.to<double>(), -1.33203125);
	EXPECT(!isNaN(negativeNumberVar));
	EXPECT(isFinite(negativeNumberVar));
	EXPECT_NOT_EQUAL(negativeNumberVar.to<Object*>(), (Object*)(0));
	EXPECT_EXCEPTION(negativeNumberVar.to<Function*>(), "TypeError: -1.33203125 is not a function");
	EXPECT_EQUAL(negativeNumberVar.to<std::wstring>(), L"-1.33203125");
	EXPECT(negativeNumberVar.to<const String&>().isEqualTo(L"-1.33203125"));
	EXPECT(negativeNumberVar.equals(negativeNumberVar));
	EXPECT_EQUAL(negativeNumberVar, negativeNumberVar);
	EXPECT(!(negativeNumberVar < negativeNumberVar));
	EXPECT(negativeNumberVar <= negativeNumberVar);
	EXPECT(negativeNumberVar >= negativeNumberVar);
	EXPECT(!(negativeNumberVar > negativeNumberVar));
	EXPECT_NOT_EQUAL(negativeNumberVar, zeroVar);
	EXPECT(negativeNumberVar < zeroVar);
	EXPECT(negativeNumberVar <= zeroVar);
	EXPECT(!(negativeNumberVar >= zeroVar));
	EXPECT(!(negativeNumberVar > zeroVar));

	const Var positiveInfiniteVar(rt, Value::INFINITE_NUMBER);
	EXPECT_EQUAL(positiveInfiniteVar, Value::INFINITE_NUMBER);
	EXPECT_EQUAL(positiveInfiniteVar.typeOf(), &NUMBER_STRING);
	EXPECT(!isNaN(positiveInfiniteVar));
	EXPECT(!isFinite(positiveInfiniteVar));
	EXPECT_NOT_EQUAL(positiveInfiniteVar.to<Object*>(), (Object*)(0));
	EXPECT_EXCEPTION(positiveInfiniteVar.to<Function*>(), "TypeError: Infinity is not a function");
	EXPECT_EQUAL(positiveInfiniteVar.to<std::wstring>(), L"Infinity");
	EXPECT(positiveInfiniteVar.to<const String&>().isEqualTo(L"Infinity"));
	EXPECT(positiveInfiniteVar.equals(positiveInfiniteVar));
	EXPECT_EQUAL(positiveInfiniteVar, positiveInfiniteVar);
	EXPECT(!(positiveInfiniteVar < positiveInfiniteVar));
	EXPECT(positiveInfiniteVar <= positiveInfiniteVar);
	EXPECT(positiveInfiniteVar >= positiveInfiniteVar);
	EXPECT(!(positiveInfiniteVar > positiveInfiniteVar));
	EXPECT(!(positiveInfiniteVar < 0.0));
	EXPECT(positiveInfiniteVar > 0.0);

	const Var negativeInfiniteVar(rt, -positiveInfiniteVar);
	EXPECT_EQUAL(negativeInfiniteVar, -(Value::INFINITE_NUMBER).toDouble());
	EXPECT_EQUAL(negativeInfiniteVar.typeOf(), &NUMBER_STRING);
	EXPECT(!isNaN(negativeInfiniteVar));
	EXPECT(!isFinite(negativeInfiniteVar));
	EXPECT_NOT_EQUAL(negativeInfiniteVar.to<Object*>(), (Object*)(0));
	EXPECT_EXCEPTION(negativeInfiniteVar.to<Function*>(), "TypeError: -Infinity is not a function");
	EXPECT_EQUAL(negativeInfiniteVar.to<std::wstring>(), L"-Infinity");
	EXPECT(negativeInfiniteVar.to<const String&>().isEqualTo(L"-Infinity"));
	EXPECT(negativeInfiniteVar.equals(negativeInfiniteVar));
	EXPECT_EQUAL(negativeInfiniteVar, negativeInfiniteVar);
	EXPECT(!(negativeInfiniteVar < negativeInfiniteVar));
	EXPECT(negativeInfiniteVar <= negativeInfiniteVar);
	EXPECT(negativeInfiniteVar >= negativeInfiniteVar);
	EXPECT(!(negativeInfiniteVar > negativeInfiniteVar));
	EXPECT(negativeInfiniteVar < 0.0);
	EXPECT(!(negativeInfiniteVar > 0.0));

	const Var nanVar(rt, Value::NOT_A_NUMBER);
	EXPECT_NOT_EQUAL(nanVar, Value::NOT_A_NUMBER);
	EXPECT_EQUAL(nanVar.typeOf(), &NUMBER_STRING);
	EXPECT(isNaN(nanVar));
	EXPECT(!isFinite(nanVar));
	EXPECT(!nanVar.to<bool>());
	EXPECT_NOT_EQUAL(nanVar.to<Object*>(), (Object*)(0));
	EXPECT_EXCEPTION(nanVar.to<Function*>(), "TypeError: NaN is not a function");
	EXPECT_EQUAL(nanVar.to<std::wstring>(), L"NaN");
	EXPECT(nanVar.to<const String&>().isEqualTo(L"NaN"));
	EXPECT(!nanVar.equals(nanVar));
	EXPECT_NOT_EQUAL(nanVar, nanVar);
	EXPECT(!(nanVar < nanVar));
	EXPECT(!(nanVar <= nanVar));
	EXPECT(!(nanVar >= nanVar));
	EXPECT(!(nanVar > nanVar));
	EXPECT(!(nanVar < 0.0));
	EXPECT_NOT_EQUAL(nanVar, 0.0);
	EXPECT(!(nanVar > 0.0));

	const Var stringVar(rt, "Eeny, meeny, miny, moe");
	EXPECT_EQUAL(stringVar.typeOf(), &STRING_STRING);
	EXPECT(stringVar.to<bool>());
	EXPECT(isNaN(stringVar.to<double>()));
	EXPECT_NOT_EQUAL(stringVar.to<Object*>(), (Object*)(0));
	EXPECT_EXCEPTION(stringVar.to<Function*>(), "TypeError: Eeny, meeny, miny, moe is not a function");
	EXPECT_EQUAL(stringVar.to<std::wstring>(), L"Eeny, meeny, miny, moe");
	EXPECT(stringVar.to<const String&>().isEqualTo("Eeny, meeny, miny, moe"));
	EXPECT(stringVar.to<const String&>().isEqualTo(L"Eeny, meeny, miny, moe"));
	EXPECT(stringVar.equals(stringVar));
	EXPECT_EQUAL(stringVar, stringVar);
	EXPECT(!(stringVar < stringVar));
	EXPECT(stringVar <= stringVar);
	EXPECT(stringVar >= stringVar);
	EXPECT(!(stringVar > stringVar));
	EXPECT(!stringVar.equals(falseVar));
	EXPECT(!stringVar.equals(trueVar));
	EXPECT_NOT_EQUAL(stringVar, falseVar);
	EXPECT_NOT_EQUAL(stringVar, trueVar);

	const Var emptyStringVar(rt, &EMPTY_STRING);
	EXPECT_EQUAL(emptyStringVar.typeOf(), &STRING_STRING);
	EXPECT(!emptyStringVar.to<bool>());
	EXPECT_EQUAL(emptyStringVar.to<double>(), 0);
	EXPECT_NOT_EQUAL(emptyStringVar.to<Object*>(), (Object*)(0));
	EXPECT_EXCEPTION(emptyStringVar.to<Function*>(), "TypeError:  is not a function");
	EXPECT_EQUAL(emptyStringVar.to<std::wstring>(), L"");
	EXPECT(emptyStringVar.to<const String&>().isEqualTo(""));
	EXPECT(emptyStringVar.to<const String&>().isEqualTo(L""));
	EXPECT(emptyStringVar.equals(emptyStringVar));
	EXPECT_EQUAL(emptyStringVar, emptyStringVar);
	EXPECT(!(emptyStringVar < emptyStringVar));
	EXPECT(emptyStringVar <= emptyStringVar);
	EXPECT(emptyStringVar >= emptyStringVar);
	EXPECT(!(emptyStringVar > emptyStringVar));
	EXPECT(emptyStringVar.equals(falseVar));
	EXPECT(!emptyStringVar.equals(trueVar));
	EXPECT_NOT_EQUAL(emptyStringVar, falseVar);
	EXPECT_NOT_EQUAL(emptyStringVar, trueVar);

	// the unintuitive JS "false" string -> boolean conversion
	const Var falseStringVar(rt, "false");
	EXPECT_EQUAL(falseStringVar.typeOf(), &STRING_STRING);
	EXPECT(falseStringVar.to<bool>());
	EXPECT(isNaN(falseStringVar.to<double>()));
	EXPECT_NOT_EQUAL(falseStringVar.to<Object*>(), (Object*)(0));
	EXPECT_EXCEPTION(falseStringVar.to<Function*>(), "TypeError: false is not a function");
	EXPECT(falseStringVar.equals(falseStringVar));
	EXPECT_EQUAL(falseStringVar, falseStringVar);
	EXPECT(!(falseStringVar < falseStringVar));
	EXPECT(falseStringVar <= falseStringVar);
	EXPECT(falseStringVar >= falseStringVar);
	EXPECT(!(falseStringVar > falseStringVar));
	EXPECT(!falseStringVar.equals(falseVar));
	EXPECT(!falseStringVar.equals(trueVar));
	EXPECT_NOT_EQUAL(falseStringVar, falseVar);
	EXPECT_NOT_EQUAL(falseStringVar, trueVar);

	const Var numberStringVar(rt, "-1.33203125");
	EXPECT_EQUAL(numberStringVar.typeOf(), &STRING_STRING);
	EXPECT(numberStringVar.to<bool>());
	EXPECT_EQUAL(numberStringVar.to<double>(), -1.33203125);
	EXPECT(numberStringVar.equals(numberStringVar));
	EXPECT(numberStringVar.equals(-1.33203125));
	EXPECT(numberStringVar.equals(negativeNumberVar));
	EXPECT(numberStringVar.equals(-1.33203125));
	EXPECT_NOT_EQUAL(numberStringVar, -1.33203125);
	EXPECT(!(numberStringVar < -1.33203125));
	EXPECT(numberStringVar <= -1.33203125);
	EXPECT(numberStringVar >= -1.33203125);
	EXPECT(!(numberStringVar > -1.33203125));

	const Var objectVar = rt.newObjectVar();
	const Var anotherObjectVar = rt.newObjectVar();
	EXPECT_EQUAL(objectVar.typeOf(), &OBJECT_STRING);
	EXPECT(objectVar.to<bool>());
	EXPECT(isNaN(objectVar.to<double>()));
	EXPECT_NOT_EQUAL(objectVar.to<Object*>(), (Object*)(0));
	EXPECT_EQUAL(objectVar.to<Object*>(), objectVar);
	EXPECT_EXCEPTION(objectVar.to<Function*>(), "TypeError: [object Object] is not a function");
	EXPECT_EQUAL(objectVar.to<std::wstring>(), L"[object Object]");
	EXPECT(objectVar.equals(objectVar));
	EXPECT_EQUAL(objectVar, objectVar);
	EXPECT(!objectVar.equals(anotherObjectVar));
	EXPECT_NOT_EQUAL(objectVar, anotherObjectVar);
	// notice that other (relative) comparison operators in JS work indirectly via toString() but not in C++

	const Var arrayVar = rt.newArrayVar();
	EXPECT_EQUAL(arrayVar.typeOf(), &OBJECT_STRING);
	EXPECT_EQUAL(arrayVar.to<std::wstring>(), L"[object Array]");
	EXPECT_EQUAL(arrayVar.size(), 0);

	const Var functionVar = rt.eval("(function() { })");
	const Var anotherFunctionVar = rt.eval("(function() { })");
	EXPECT_EQUAL(functionVar.typeOf(), &FUNCTION_STRING);
	EXPECT(functionVar.to<bool>());
	EXPECT(isNaN(functionVar.to<double>()));
	EXPECT_NOT_EQUAL(functionVar.to<Object*>(), (Object*)(0));
	EXPECT_EQUAL(functionVar.to<Object*>(), functionVar);
	EXPECT_NOT_EQUAL(functionVar.to<Function*>()->asFunction(), (Function*)(0));
	EXPECT_EQUAL(functionVar.to<std::wstring>(), L"function () { }");
	EXPECT(functionVar.equals(functionVar));
	EXPECT_EQUAL(functionVar, functionVar);
	EXPECT_NOT_EQUAL(functionVar, anotherFunctionVar);
	// notice that other (relative) comparison operators in JS work indirectly via toString() but not in C++
}

/* --- ArrayVars test --- */

static void testArrayVars() {
	std::cout << std::endl << "***** Array Vars *****" << std::endl << std::endl;
	std::cout << "  - element access and insertion" << std::endl;
	std::cout << "  - length updates" << std::endl;
	std::cout << "  - iteration" << std::endl;

	Heap heap;
	Runtime rt(heap);
	Var globals = rt.getGlobalsVar();
	
	Var arrayVar = rt.newArrayVar();
	EXPECT_EQUAL(arrayVar.typeOf(), &OBJECT_STRING);

	Var className = arrayVar.className();
	EXPECT_EQUAL(className, &A_RRAY_STRING);

	JSArray* jsArray = arrayVar.to<Object*>()->asArray();
	EXPECT_NOT_EQUAL(jsArray, (JSArray*)(0));

	EXPECT_EQUAL(arrayVar.size(), 0);
	for (int i = 0; i < 100; ++i) {
		arrayVar[i] = i * 1234;
	}
	for (int i = 100; i < 200; ++i) {
		jsArray->setElement(rt, i, i * 1234);
	}
	for (int i = 200; i < 300; ++i) {
		jsArray->setOwnProperty(rt, String::fromInt(heap, i), i * 1234);
	}
	EXPECT_EQUAL(arrayVar.size(), 300);
	arrayVar[400400] = 918273;
	EXPECT_EQUAL(arrayVar.size(), 400401);
	for (int i = 0; i < 300; ++i) {
		EXPECT_EQUAL(arrayVar[i], i * 1234);
		EXPECT_EQUAL(jsArray->getElement(rt, i).toInt(), i * 1234);
		Value v;
		EXPECT_NOT_EQUAL(jsArray->getOwnProperty(rt, String::fromInt(heap, i), &v), NONEXISTENT);
		EXPECT_EQUAL(v.toInt(), i * 1234);
	}
	EXPECT_EQUAL(arrayVar[301], UNDEFINED_VALUE);
	EXPECT_EQUAL(arrayVar[400400], 918273);
	EXPECT(arrayVar.has(400400));
	EXPECT_EQUAL(arrayVar["400400"], 918273);
	EXPECT_EQUAL(jsArray->getLength(), 400401);
	jsArray->updateLength(100);
	EXPECT_EQUAL(arrayVar.size(), 100);
	arrayVar[&LENGTH_STRING] = 30;
	EXPECT_EQUAL(jsArray->getLength(), 30);

	const Var::const_iterator e = arrayVar.end();
	int elementsInArray = 0;
	for (Var::const_iterator it = arrayVar.begin(); it != e; ++it) {
		elementsInArray |= (1 << (*it).to<int>());
	}
	EXPECT_EQUAL(elementsInArray, 0x3FFFFFFF);
}

static void testStandardLibrary() {
	std::cout << std::endl << "***** Standard Library *****" << std::endl << std::endl;
	std::cout << "  - array operations" << std::endl;
	std::cout << "  - string utilities" << std::endl;

	Heap heap;
	Runtime rt(heap);
	rt.setupStandardLibrary();

	Var result = rt.eval("var a = []; a.push(1); a.length;");
	EXPECT_EQUAL(result.to<Int32>(), 1);

	Var upper = rt.eval("'abc'.toUpperCase();");
	EXPECT_EQUAL(upper.to<std::wstring>(), L"ABC");
}

static void testJSON() {
	std::cout << std::endl << "***** JSON *****" << std::endl << std::endl;
	std::cout << "  - stringify objects" << std::endl;
	std::cout << "  - parse JSON strings" << std::endl;

	Heap heap;
	Runtime rt(heap);
	rt.setupStandardLibrary();

	Var obj = rt.eval("({ foo: 17, bar: [1,2,3], baz: 'hi' })");
	Var stringify = rt.getGlobalsVar()["JSON"]["stringify"];
	Var parse = rt.getGlobalsVar()["JSON"]["parse"];
	const std::wstring text = stringify(obj);
	Var parsed = parse(std::wstring(text));
	EXPECT_EQUAL(parsed["foo"], 17);
	EXPECT_EQUAL(parsed["bar"][1], 2);
        EXPECT_EQUAL(parsed["baz"].to<std::wstring>(), L"hi");
}

static void testCompilation() {
	std::cout << std::endl << "***** Compilation *****" << std::endl << std::endl;
	std::cout << "  - eval compilation" << std::endl;
	std::cout << "  - global code compilation" << std::endl;
	std::cout << "  - global object setup" << std::endl;

	Heap heap;
	Runtime rt(heap);
	rt.setupStandardLibrary();

	const String* expr = String::allocate(heap, "21+21");
	Processor p(rt);
	p.enterEvalCode(rt.compileEvalCode(expr));
	EXPECT_EQUAL(rt.runUntilReturn(p), 42);

	const String source(heap.managed(), "var x=3; x+4;");
	Processor p2(rt);
	p2.enterGlobalCode(rt.compileGlobalCode(source));
	Var res = rt.runUntilReturn(p2);
	EXPECT_EQUAL(res.typeOf(), &UNDEFINED_STRING);
	EXPECT_EQUAL(rt.getGlobalsVar()["x"], 3);

	JSObject* globalsObj = rt.newJSObject();
	rt.setGlobalObject(globalsObj);
	Var globals = rt.getGlobalsVar();
	globals["val"] = 99;
	EXPECT_EQUAL(rt.getGlobalObject(), globalsObj);
	EXPECT_EQUAL(globals["val"], 99);
	JSArray* arr = rt.newJSArray(5);
	EXPECT_EQUAL(arr->getLength(), 5);
}

static void testLimits() {
	std::cout << std::endl << "***** Limits *****" << std::endl << std::endl;
	std::cout << "  - memory limits" << std::endl;
	std::cout << "  - execution timeouts" << std::endl;

	Heap heap;
	Runtime rt(heap);
	rt.setupStandardLibrary();

	rt.setMemoryCap(8192);
	EXPECT_EXCEPTION(rt.eval("var a=[]; for(var i=0;i<1e6;i++) a[i]=i;"), "Out of memory");

	rt.setMemoryCap(512*1024*1024);
	rt.resetTimeOut(1);
	EXPECT_EXCEPTION(rt.run("while(true) {}"), "Time out");
	rt.noTimeOut();
}

// C++ functions that you want to call from Javascript should have these arguments.
static Var sum(Runtime& rt, const Var& thisVar, const VarList& args) {
	(void)thisVar;
	double sum = 0.0;
	for (int i = 0; i < args.size(); ++i) {
		sum += args[i];
	}
	return Var(rt, sum);    // A `Var` owns its `Value` (sum) and is tied to a `Runtime` (rt)
}

static Var addFunction(Runtime& rt, const Var& thisVar, const VarList& args) {
	(void)thisVar;
	double sum = 0.0;
	for (UInt32 i = 0; i < args.size(); ++i) {
		sum += args[i];
	}
	return Var(rt, sum);
}

static Var countArguments(Runtime& rt, const Var&, const VarList& args) {
	return Var(rt, static_cast<UInt32>(args.size()));
}

static Value returnFortyTwo(Runtime&, Processor&, UInt32, const Value*, Object*) {
	return Value(42);
}

static void testHighLevelAPI() {
	std::cout << std::endl << "***** High Level API *****" << std::endl << std::endl;
	std::cout << "  - C++ to JS binding" << std::endl;
	std::cout << "  - object and array helpers" << std::endl;
	std::cout << "  - type conversions" << std::endl;

	Heap heap;
	Runtime rt(heap);
	rt.setupStandardLibrary();

	Var globals = rt.getGlobalsVar();

	globals["add"] = addFunction;
	EXPECT_EQUAL(globals["add"](4, 5), 9);

	const Value values[3] = { 1, 2, 3 };
	EXPECT_EQUAL(globals["add"](VarList(rt, 3, values)), 6);

	Var object(rt.newObjectVar());
	object["foo"] = 123;
	object["bar"] = "abc";
	EXPECT_EQUAL(object["foo"], 123);
	EXPECT_EQUAL(object["bar"].to<std::wstring>(), L"abc");
	EXPECT(object.has("foo"));
	EXPECT(!object.has("baz"));

	Var array(rt.newArrayVar());
	for (int i = 0; i < 5; ++i) array[i] = i * 2;
	EXPECT_EQUAL(array.size(), 5);
	EXPECT_EQUAL(array[2], 4);
	EXPECT(array.has(4));
	EXPECT(!array.has(5));

	rt.run("function mul(a,b){ return a*b; }");
	EXPECT_EQUAL(globals["mul"](6, 7), 42);

	EXPECT(object["foo"].equals(123));
	EXPECT(object["foo"] == 123);
	EXPECT(object["foo"] != 124);

	Var booleanVar(rt, true);
	Var integerVar(rt, 77);
	Var unsignedIntegerVar(rt, static_cast<UInt32>(99));
	Var doubleVar(rt, 3.5);
	Var charStringVar(rt, "hello");
	Var standardStringVar(rt, std::string("bye"));
	Var wideStringVar(rt, std::wstring(L"wide"));
	JSObject* rawObject = rt.newJSObject();
	Var objectVar(rt, rawObject);
	Var valueVar(rt, Value(11));
	Var countArgumentsFunctionVar(rt, countArguments);
	Var nativeFunctionVar(rt, returnFortyTwo);
	BindingTestObject bindingTestObject;
	Var boundMethodVar(rt, &bindingTestObject, &BindingTestObject::method);

	EXPECT(booleanVar.to<bool>());
	EXPECT_EQUAL(integerVar.to<Int32>(), 77);
	EXPECT_EQUAL(unsignedIntegerVar.to<UInt32>(), 99U);
	EXPECT_EQUAL(doubleVar.to<double>(), 3.5);
	EXPECT_EQUAL(charStringVar.to<std::wstring>(), L"hello");
	EXPECT(standardStringVar.to<const String&>().isEqualTo(L"bye"));
	const String* wPtr = wideStringVar.to<const String*>();
	EXPECT(wPtr->isEqualTo(L"wide"));
	Var unicodeString(rt, std::wstring(L"Hello \u00A9 \u20AC \u03A9"));
	EXPECT_EQUAL(unicodeString.to<std::wstring>(), L"Hello \u00A9 \u20AC \u03A9");
	EXPECT_EQUAL(objectVar.to<Object*>(), rawObject);
	EXPECT_EQUAL(valueVar.to<Value>().toInt(), 11);
	EXPECT_NOT_EQUAL(countArgumentsFunctionVar.to<Function*>(), (Function*)0);
	EXPECT_NOT_EQUAL(nativeFunctionVar.to<Function*>(), (Function*)0);
	const Value args2[4] = { 1, 2, 3, 4 };
	EXPECT_EQUAL(countArgumentsFunctionVar(VarList(rt, 4, args2)), 4);
	EXPECT_EQUAL(countArgumentsFunctionVar(VarList(rt, true)), 1);
	Var tempString(rt, std::wstring(L"hi"));
	EXPECT_EQUAL(countArgumentsFunctionVar(VarList(rt, true, tempString.to<Value>())), 2);
	Var tempFuncVar(rt, nativeFunctionVar.to<Function*>());
	EXPECT_EQUAL(countArgumentsFunctionVar(VarList(rt, true, tempString.to<Value>(), tempFuncVar.to<Value>())), 3);
	EXPECT_EQUAL(countArgumentsFunctionVar.apply(0), 0);
	EXPECT_EQUAL(countArgumentsFunctionVar.apply(0, 1), 1);
	EXPECT_EQUAL(countArgumentsFunctionVar.apply(0, 1, 2), 2);
	EXPECT_EQUAL(countArgumentsFunctionVar.apply(0, 1, 2, 3), 3);
	EXPECT_EQUAL(nativeFunctionVar(), 42);
	EXPECT_EQUAL(boundMethodVar().to<double>(), 123.456);
	EXPECT_EQUAL(object["foo"].to<Int32>(), 123);
	EXPECT_EQUAL(object["foo"].to<UInt32>(), 123U);
	EXPECT(object["foo"].to<bool>());
	Value val = charStringVar.to<Value>();
	EXPECT(val.isString());
}

static void readMeSample1() {
	std::wstringstream strout;

	Heap heap;                                          // We use the standard heap.
	Runtime rt(heap);                                   // Construct an empty engine.
	rt.setupStandardLibrary();                          // Install the ES3 standard library.
	Var helloWorld = rt.eval("'hello ' + 'world'");     // Evaluate a JS expression.
	strout << helloWorld << std::endl;

	const std::wstring result = strout.str();
	EXPECT_EQUAL(result, L"hello world\n");
}

static void readMeSample2() {
	std::wstringstream strout;

	Heap heap;                                          // We use the standard heap.
	Runtime rt(heap);                                   // Construct an empty engine.
	rt.setupStandardLibrary();                          // Install the ES3 standard library.
	rt.setMemoryCap(1024 * 1024);                       // Max 1MB of memory please.
	rt.resetTimeOut(10);                                // Time-out JS code after 10 seconds.
	Var globals = rt.getGlobalsVar();
	
	// Set up the native function and a JS demo function that calls it.
	globals["sum"] = sum;
	rt.run("function demo(a,b,c) { return 'a+b+c = ' + sum(a,b,c); }");
	strout << globals["demo"](7, 15, 20) << std::endl;
	
	// Lets go silly. Create an anonymous function with eval that simply returns its arguments.
	Var sillyFunction = rt.eval("(function() { return arguments; })");
	
	// `Var` protects data from being garbage collected.
	// In this case, a `String` is created on the heap for "131".
	Var oneThreeOne(rt, "131");
	
	// If we have more arguments than there, we use a `Value` array instead.
	const Value args[10] = { oneThreeOne, 535, 236, 984, 456.5, 666, 626, 585, 382, 109.5 };
	
	// Call the silly function. The VarList encapsulates and protects the argument values.
	Var list = sillyFunction(VarList(rt, 10, args));
	
	// Now call the equivalent of the Javascript code: `sum.apply(null, list)` from C++.
	strout << globals["sum"]["apply"](Value::NUL, list) << std::endl;
	
	// C++ == operator checks for strict equality like JS ===
	strout << "1 == true: " << (Var(rt, 1) == true ? "true" : "false") << std::endl;
	
	// Use equals() to check for equality like JS ==
	strout << "1.equals(true): " << (Var(rt, 1).equals(true) ? "true" : "false") << std::endl;

	// There is no support for calling a Javascript constructor directly from C++ so we have to make a little stub.
	const int year = 2008, month = 7, day = 20;
	Var dateVar = rt.eval("(function(y, m, d) { return new Date(y, m, d) })")(year, month, day);

	// Converting a Var to string never calls Javascript's toString() method. This will simply output '[object Date]'.
	EXPECT_EQUAL(dateVar.className(), &D_ATE_STRING);
	strout << dateVar << std::endl;

	// But naturally, you can call toString() manually. This will output 2008-08-20 00:00:00.
	Var dateString = dateVar["toString"]();
	EXPECT_EQUAL(dateString.typeOf(), &STRING_STRING);
	strout << dateString << std::endl;

	// Var::const_iterator will enumerate all properties, similar to the Javscript "for in" statement.
	Var anArray = rt.eval("[ 4, 8, 15, 16, 23, 42]");
	for (Var::const_iterator it = anArray.begin(); it != anArray.end(); ++it) {
		strout << anArray[*it] << ' ';
	}
	strout << std::endl;

	const std::wstring result = strout.str();
	EXPECT_EQUAL(result, L"a+b+c = 42\n4711\n1 == true: false\n1.equals(true): true\n[object Date]\n2008-08-20 00:00:00\n4 8 15 16 23 42 \n");
}

// --- Testing the test framework ---

static int dummy(int input) {
	return input * 29384;
}

static int throwScriptException(Heap& heap) {
	ScriptException::throwError(heap, GENERIC_ERROR, "Error Flynn");
	return 123;
}

struct SomeException : public std::exception {
	virtual const char* what() const throw() { return "some random exception"; }
};

static int throwSomeOtherException(Heap& heap) {
	(void)heap;
	throw SomeException();
	return 123;
}

static int selfTest() {
	std::cout << std::endl << "***** Test Framework *****" << std::endl << std::endl;

	Heap heap;
	
	/* these should pass */
	EXPECT(true);
	EXPECT_EQUAL(1, 1);
	EXPECT_EXCEPTION(throwScriptException(heap), "Error: Error Flynn");
	EXPECT_EQUAL(1, 1);
	EXPECT_EQUAL(dummy(93), dummy(93));
	EXPECT_NOT_EQUAL(1, 0);
	EXPECT_NOT_EQUAL(dummy(93), dummy(47));

	/* these should fail */
	EXPECT(false);
	EXPECT_EQUAL(1, 0);
	EXPECT(throwScriptException(heap));
	EXPECT(throwSomeOtherException(heap));
	EXPECT_EXCEPTION(throwScriptException(heap), "Error: Flynn Rider");
	EXPECT_EXCEPTION(throwSomeOtherException(heap), "Error: Error Flynn");
	EXPECT_EQUAL(1, 0);
	EXPECT_EQUAL(dummy(93), dummy(47));
	EXPECT_EQUAL(throwScriptException(heap), 123);
	EXPECT_EQUAL(throwSomeOtherException(heap), 123);
	EXPECT_NOT_EQUAL(0, 0);
	EXPECT_NOT_EQUAL(dummy(93), (93 * 29384));
	EXPECT_NOT_EQUAL(throwScriptException(heap), 234);
	EXPECT_NOT_EQUAL(throwSomeOtherException(heap), 234);

	XorshiftRandom2x32 prng;
	EXPECT_EQUAL(prng(), 2112846788);
	EXPECT_EQUAL(prng(), 20866602);
	EXPECT_EQUAL(prng(999), 7);
	EXPECT_EQUAL(prng(999), 232);

	if (testCount != 25) {
		std::cout << "Expected 25 checks in total but executed " << testCount << "!" << std::endl;
		return 1;
	}
	
	if (failureCount != 14) {
		std::cout << "Expected 14 checks to fail but " << failureCount << " failed!" << std::endl;
		return 1;
	}
	
	std::cout << "Self test passed successfully" << std::endl;
	return 0;
}

static size_t sizeOfAllocation(size_t bytes) {
	return sizeof (size_t) + ((0 < bytes && bytes <= MAX_POOLED_SIZE - POOL_SIZE_GRANULARITY)
			? static_cast<int>((bytes + (POOL_SIZE_GRANULARITY - 1)) / POOL_SIZE_GRANULARITY * POOL_SIZE_GRANULARITY)
			: bytes);
}

/* --- Heap tests --- */

const int RANDOM_ALLOCATION_COUNT = 20000;
const int MAX_ALLOCATION_SIZE = 7000;
const int EDGE_COUNT = 4;
const int MAX_NODE_COUNT = 100000;
const int GC_ITERATIONS = 8;

struct GraphNode : public GCItem {
	typedef GCItem super;
	GraphNode(GCList& gcList) : super(gcList), iteration(0) {
		std::fill(edges + 0, edges + EDGE_COUNT, (GraphNode*)(0));
	}
	virtual void gcMarkReferences(Heap& heap) const {
		gcMark(heap, edges + 0, edges + EDGE_COUNT);
		super::gcMarkReferences(heap);
	}
	~GraphNode() { iteration = -1; }
	GraphNode* edges[EDGE_COUNT];
	int iteration;
};

struct CheapHeap : public Heap {
	virtual void* acquireMemory(size_t n) {
		if (size() + n > 65536) {
			throw ConstStringException("out of Commodore 64 memory");
		}
		return Heap::acquireMemory(n);
	}
};

static void testHeap() {
	std::cout << std::endl << "***** Heap *****" << std::endl << std::endl;

	Heap heap;

	// Test allocations, memory pools etc with lots of pseudorandom allocations and deallocations.
	{
		Vector<void*, 1> allocations(RANDOM_ALLOCATION_COUNT, 0);		// lets not use our heap for this one
		Vector<size_t, 1> sizes(RANDOM_ALLOCATION_COUNT, 0);			// lets not use our heap for this one
		for (int i = 0; i < RANDOM_ALLOCATION_COUNT; ++i) {
			allocations[i] = 0;
			sizes[i] = 0;
		}

		XorshiftRandom2x32 prng;
		size_t totalCount = 0;
		size_t totalSize = 0;
		for (int i = 0; i < RANDOM_ALLOCATION_COUNT; ++i) {
			const size_t bytes = prng(MAX_ALLOCATION_SIZE);
			const size_t thisSize = sizeOfAllocation(bytes);
			allocations[i] = heap.allocate(bytes);
			unsigned char* p = reinterpret_cast<unsigned char*>(allocations[i]);
			std::fill(p, p + bytes, i & 255);
			sizes[i] = bytes;
			++totalCount;
			totalSize += thisSize;
		}
		heap.drain();
		EXPECT_EQUAL(heap.count(), totalCount);
		EXPECT_EQUAL(heap.size(), totalSize);
		std::cout << "allocated " << totalCount << " blocks with a total of " << totalSize << " bytes" << std::endl;

		for (int i = 0; i < RANDOM_ALLOCATION_COUNT / 2; ++i) {
			const int freeIndex = prng(RANDOM_ALLOCATION_COUNT - 1);
			if (allocations[freeIndex] != 0) {
				heap.free(allocations[freeIndex]);
				allocations[freeIndex] = 0;
				--totalCount;
				totalSize -= sizeOfAllocation(sizes[freeIndex]);
			}
		}
		heap.drain();
		EXPECT_EQUAL(heap.count(), totalCount);
		EXPECT_EQUAL(heap.size(), totalSize);
		std::cout << "now: " << totalCount << " blocks with a total of " << totalSize << " bytes" << std::endl;

		for (int i = 0; i < RANDOM_ALLOCATION_COUNT / 2; ++i) {
			if (i == RANDOM_ALLOCATION_COUNT / 4) {
				heap.drain();
			}
			const int reallocIndex = prng(RANDOM_ALLOCATION_COUNT - 1);
			if (allocations[reallocIndex] != 0) {
				heap.free(allocations[reallocIndex]);
				allocations[reallocIndex] = 0;
				--totalCount;
				totalSize -= sizeOfAllocation(sizes[reallocIndex]);
			}
			const size_t bytes = prng(MAX_ALLOCATION_SIZE);
			const size_t thisSize = sizeOfAllocation(bytes);
			allocations[reallocIndex] = heap.allocate(bytes);
			unsigned char* p = reinterpret_cast<unsigned char*>(allocations[reallocIndex]);
			std::fill(p, p + bytes, reallocIndex & 255);
			sizes[reallocIndex] = bytes;
			++totalCount;
			totalSize += thisSize;
		}
		heap.drain();
		EXPECT_EQUAL(heap.count(), totalCount);
		EXPECT_EQUAL(heap.size(), totalSize);
		std::cout << "now: " << totalCount << " blocks with a total of " << totalSize << " bytes" << std::endl;

		int fails = 0;
		for (int i = 0; i < RANDOM_ALLOCATION_COUNT; ++i) {
			if (allocations[i] != 0) {
				const unsigned char* p = reinterpret_cast<const unsigned char*>(allocations[i]);
				size_t j = 0;
				while (j < sizes[i] && p[j] == (i & 255)) {
					++j;
				}
				EXPECT_EQUAL(j, sizes[i]);
				heap.free(allocations[i]);
				allocations[i] = 0;
				sizes[i] = 0;
			}
		}
		heap.drain();
		EXPECT_EQUAL(heap.count(), 0);
		EXPECT_EQUAL(heap.size(), 0);
		EXPECT_EQUAL(fails, 0);
	}
	
	// Test GC
	{
		{
			XorshiftRandom2x32 prng(123);

			Vector<GraphNode*, 1> reachableNodes(MAX_NODE_COUNT, 0);		// lets not use our heap for this one
			for (int i = 0; i < MAX_NODE_COUNT; ++i) {
				reachableNodes[i] = new(heap) GraphNode(heap.managed());
			}
			EXPECT_EQUAL(heap.count(), static_cast<size_t>(MAX_NODE_COUNT));
			for (int i = 0; i < MAX_NODE_COUNT; ++i) {
				for (int j = 0; j < EDGE_COUNT; ++j) {
					reachableNodes[i]->edges[j] = reachableNodes[prng(MAX_NODE_COUNT - 1)];
				}
			}
			EXPECT(heap.managed().owns(reachableNodes[0]));
			heap.roots().claim(reachableNodes[0]);
			EXPECT(heap.roots().owns(reachableNodes[0]));
			for (int currentIteration = 1; currentIteration <= GC_ITERATIONS; ++currentIteration) {
				heap.gc();
				EXPECT(reachableNodes[0]->iteration >= 0);
				reachableNodes[0]->iteration = currentIteration;
				int reachableCount = 1;
				int traverseIndex = 0;
				while (traverseIndex < reachableCount) {
					GraphNode* thisNode = reachableNodes[traverseIndex];
					for (int edgeIndex = 0; edgeIndex < EDGE_COUNT; ++edgeIndex) {
						GraphNode* linkedNode = thisNode->edges[edgeIndex];
						if (linkedNode != 0 && linkedNode->iteration != currentIteration) {
							EXPECT(linkedNode->iteration >= 0);	// < 0 = already deleted by gc()
							EXPECT(heap.managed().owns(linkedNode));
							linkedNode->iteration = currentIteration;
							EXPECT(reachableCount < MAX_NODE_COUNT);
							reachableNodes[reachableCount] = linkedNode;
							++reachableCount;
						}
					}
					thisNode->edges[prng(EDGE_COUNT - 1)] = 0; // kill a random edge for next iteration
					++traverseIndex;
				}
				heap.drain();
				EXPECT_EQUAL(reachableCount, heap.count());
				std::cout << "gc iteration: " << currentIteration << ", reachable: " << reachableCount << std::endl;
			}
			heap.managed().claim(reachableNodes[0]);
			heap.gc();
			heap.drain();
			EXPECT_EQUAL(heap.count(), 0);
		}
	}
	
	{
		EXPECT_EXCEPTION(heap.allocate(MAX_SINGLE_ALLOCATION_SIZE), "Memory allocation failure (size too large)");
		EXPECT_EXCEPTION(heap.allocate(~(size_t)(0) - sizeof (size_t) - 16), "Memory allocation failure (size too large)");
		CheapHeap cheapHeap;
		void* alloc1 = 0;
		void* alloc2 = 0;
		EXPECT_NO_EXCEPTION(alloc1 = cheapHeap.allocate(32768 - sizeof (size_t)));
		EXPECT_NO_EXCEPTION(alloc2 = cheapHeap.allocate(32768 - sizeof (size_t)));
		EXPECT_EQUAL(cheapHeap.size(), 65536);
		EXPECT_EXCEPTION(cheapHeap.allocate(1), "out of Commodore 64 memory");
		cheapHeap.free(alloc2);
		cheapHeap.free(alloc1);
		cheapHeap.drain();
		EXPECT_EQUAL(cheapHeap.size(), 0);
	}
}

/* --- Vector test --- */

template<typename T> UInt32 matchLength(const T* b, const T* e, XorshiftRandom2x32& prng) {
	const T* it = b;
	while (it != e && *it == generateRandomValue<T>(prng)) {
		++it;
	}
	return static_cast<UInt32>(it - b);
}

template<typename T, UInt32 INTERNAL_SIZE> void testVector(const char* typeName, const unsigned int seed
		, const int iterations, const UInt32 maxSizeIncrement, Heap* const optionalHeap, const UInt32 initialSize) {
	std::cout << "Test Vector type: " << typeName << ", internal: " << INTERNAL_SIZE << ", seed: " << seed
			<< ", inc: " << maxSizeIncrement << ", heap: " << optionalHeap << ", initial: " << initialSize << std::endl;
	TestDataClass::constructedCount = 0;
	TestDataClass::destructedCount = 0;
	XorshiftRandom2x32 mainPRNG = XorshiftRandom2x32(seed);
	const unsigned int contentSeed = mainPRNG();
	if (optionalHeap != 0) {
		optionalHeap->drain();
		EXPECT_EQUAL(optionalHeap->size(), 0);
	}
	Vector<T, INTERNAL_SIZE> theVector(initialSize, optionalHeap);
	EXPECT(theVector.getAssociatedHeap() == optionalHeap);
	{
		XorshiftRandom2x32 contentPRNG = XorshiftRandom2x32(contentSeed);
		for (UInt32 i = 0; i < initialSize; ++i) {
			theVector[i] = generateRandomValue<T>(contentPRNG);
		}
	}
	UInt32 currentSize = initialSize;
	{
		Vector<T, INTERNAL_SIZE> swapVector(0, optionalHeap);
		for (int iterationCounter = 1; iterationCounter <= iterations; ++iterationCounter) {
			const UInt32 swappedSize = swapVector.size();
			
			EXPECT((currentSize == 0) == theVector.empty());
			if (iterationCounter == 1 || (iterationCounter % 10) == 0 || iterationCounter == iterations - 1) {
				std::wcout << " build iteration " << iterationCounter << ": size=" << currentSize << std::endl;
			}
			EXPECT_EQUAL(theVector.size(), currentSize);
			
			XorshiftRandom2x32 contentPRNG = XorshiftRandom2x32(contentSeed);
			EXPECT_EQUAL(matchLength(theVector.begin(), theVector.end(), contentPRNG), theVector.size());
			
			for (UInt32 i = 0; i < swappedSize; ++i) {
				swapVector[i] = generateRandomValue<T>(contentPRNG);
			}
			std::swap(swapVector, theVector);
			EXPECT_EQUAL(swapVector.size(), currentSize);
			EXPECT_EQUAL(theVector.size(), swappedSize);
			contentPRNG = XorshiftRandom2x32(contentSeed);
			EXPECT_EQUAL(matchLength(swapVector.begin(), swapVector.end(), contentPRNG), swapVector.size());
			
			XorshiftRandom2x32 newContentPRNG(contentPRNG);
			EXPECT_EQUAL(matchLength(theVector.begin(), theVector.end(), contentPRNG), theVector.size());

			theVector = swapVector;
			EXPECT_EQUAL(theVector.size(), currentSize);

			UInt32 sizeIncrement = mainPRNG(static_cast<int>(maxSizeIncrement - 1)) + 1;
			const UInt32 newSize = theVector.size() + sizeIncrement;
			theVector.reserve(newSize);
			theVector.resize(newSize);
			EXPECT(theVector.capacity() == newSize);
			for (UInt32 i = 0; i < sizeIncrement; ++i) {
				theVector[currentSize + i] = generateRandomValue<T>(newContentPRNG);
			}
			currentSize += sizeIncrement;
		}
	}
	
	const UInt32 insertBeginAt = theVector.size() / 2;
	UInt32 insertEndAt = insertBeginAt;
	const unsigned int insertedContentSeed = mainPRNG();
	{
		XorshiftRandom2x32 insertedContentPRNG = XorshiftRandom2x32(insertedContentSeed);
		for (int iterationCounter = 1; iterationCounter <= iterations; ++iterationCounter) {
			if (iterationCounter == 1 || (iterationCounter % 10) == 0 || iterationCounter == iterations - 1) {
				std::wcout << " insert iteration " << iterationCounter << ": size=" << currentSize << std::endl;
			}
			const UInt32 insertSize = mainPRNG(static_cast<int>(maxSizeIncrement - 1)) + 1;
			Vector<T, INTERNAL_SIZE> insertVector(insertSize, optionalHeap);
			for (UInt32 i = 0; i < insertSize; ++i) {
				insertVector[i] = generateRandomValue<T>(insertedContentPRNG);
			}
			theVector.insert(theVector.begin() + insertEndAt, insertVector.begin(), insertVector.end());
			currentSize += insertSize;
			EXPECT_EQUAL(theVector.size(), currentSize);
			insertEndAt += insertSize;
		}
		for (int i = 0; i < 3; ++i) {
			theVector.push(generateRandomValue<T>(insertedContentPRNG));
		}
		currentSize += 3;
		EXPECT_EQUAL(theVector.size(), currentSize);
	}
	
	{
		XorshiftRandom2x32 originalContentPRNG(contentSeed);
		EXPECT_EQUAL(matchLength(theVector.begin(), theVector.begin() + insertBeginAt, originalContentPRNG)
				, insertBeginAt);
		EXPECT_EQUAL(matchLength(theVector.begin() + insertEndAt, theVector.end() - 3, originalContentPRNG)
				, theVector.size() - 3 - insertEndAt);
		XorshiftRandom2x32 insertedContentPRNG(insertedContentSeed);
		EXPECT_EQUAL(matchLength(theVector.begin() + insertBeginAt, theVector.begin() + insertEndAt, insertedContentPRNG)
				, insertEndAt - insertBeginAt);
		EXPECT_EQUAL(matchLength(theVector.end() - 3, theVector.end(), insertedContentPRNG), 3);
	}
	EXPECT_EQUAL(theVector.size(), currentSize);
	std::wcout << " size after inserts=" << currentSize << std::endl;

	{
		theVector.erase(theVector.end() - 3, theVector.end());
		currentSize -= 3;
		EXPECT_EQUAL(theVector.size(), currentSize);
		theVector.erase(theVector.begin() + insertBeginAt, theVector.begin() + insertEndAt);
		currentSize -= insertEndAt - insertBeginAt;
		EXPECT_EQUAL(theVector.size(), currentSize);
		XorshiftRandom2x32 originalContentPRNG(contentSeed);
		EXPECT_EQUAL(matchLength(theVector.begin(), theVector.end(), originalContentPRNG), theVector.size());
	}
	EXPECT_EQUAL(theVector.size(), currentSize);
	std::wcout << " final size=" << currentSize << std::endl;

	if (strcmp(typeName, "TestDataClass") == 0) {
		std::cout << "constructed " << TestDataClass::constructedCount << " TestDataClasses" << std::endl;
		std::cout << "destructed " << TestDataClass::destructedCount << " TestDataClasses" << std::endl;
		EXPECT_EQUAL(TestDataClass::constructedCount - TestDataClass::destructedCount, theVector.size());
	}
	theVector.shrink();
	if (optionalHeap != 0) {
		size_t expectedSize = (currentSize > INTERNAL_SIZE ? sizeOfAllocation(currentSize * sizeof (T)) : 0);
		optionalHeap->drain();
		EXPECT_EQUAL(optionalHeap->size(), expectedSize);
	}
	theVector.resize(0);
	theVector.shrink();
	EXPECT(theVector.empty());
	EXPECT_EQUAL(theVector.size(), 0);
	EXPECT_EQUAL(theVector.begin(), theVector.end());
	if (optionalHeap != 0) {
		optionalHeap->drain();
		EXPECT_EQUAL(optionalHeap->size(), 0);
	}
	EXPECT_EQUAL(TestDataClass::constructedCount, TestDataClass::destructedCount);
	
	std::cout << std::endl;
}

static void testVectors() {
	std::cout << std::endl << "***** Vector *****" << std::endl << std::endl;

	Heap heap;
	std::cout << "sizeof (TestDataClass) == " << sizeof (TestDataClass) << std::endl;
	testVector<double, DEFAULT_INTERNAL_COUNT>("double", 9876, 577, 2, &heap, 0);
	testVector<double, DEFAULT_INTERNAL_COUNT>("double", 1234, 100, 53, &heap, 3);
	testVector<double, DEFAULT_INTERNAL_COUNT>("double", 2345, 10, 71082, &heap, 7);
	testVector<double, 45>("double", 3456, 10, 71082, 0, 23);
	testVector<bool, DEFAULT_INTERNAL_COUNT>("bool", 4567, 10, 56562, &heap, 7);
	testVector<bool, DEFAULT_INTERNAL_COUNT>("bool", 5678, 30, 5123, &heap, 89);
	testVector<TestDataClass, DEFAULT_INTERNAL_COUNT>("TestDataClass", 8765, 577, 2, &heap, 0);
	testVector<TestDataClass, DEFAULT_INTERNAL_COUNT>("TestDataClass", 6789, 22, 2453, 0, 3);
	testVector<TestDataClass, 0>("TestDataClass", 7890, 17, 595, &heap, 0);
	testVector<TestDataClass, 0>("TestDataClass", 7890, 17, 595, &heap, 1);
	testVector<TestDataClass, 20>("TestDataClass", 8901, 1, 1, &heap, 0);

	{
		EXPECT_EQUAL(heap.size(), 0);
		UnreliableConstructorClass::constructedCount = 0;
		UnreliableConstructorClass::destructedCount = 0;
		{
			EXPECT_NO_EXCEPTION(Vector<UnreliableConstructorClass> unreliable1(&heap));
			EXPECT_EQUAL(UnreliableConstructorClass::constructedCount, 0);
			EXPECT_EQUAL(UnreliableConstructorClass::destructedCount, 0);
		}
		{
			Vector<UnreliableConstructorClass> unreliable1(&heap);
			unreliable1.reserve(1000);
			EXPECT_EQUAL(UnreliableConstructorClass::constructedCount, 0);
			EXPECT_EQUAL(UnreliableConstructorClass::destructedCount, 0);
		}
		{
			EXPECT_EXCEPTION(Vector<UnreliableConstructorClass> unreliable2(11, &heap), "Evil constructor");
			EXPECT_EQUAL(UnreliableConstructorClass::constructedCount, 10);
			EXPECT_EQUAL(UnreliableConstructorClass::destructedCount, 10);
		}
		{
			UnreliableConstructorClass::constructedCount = 0;
			UnreliableConstructorClass::destructedCount = 0;
			Vector<UnreliableConstructorClass> unreliable3(&heap);
			EXPECT_NO_EXCEPTION(unreliable3.resize(5));
			EXPECT_EQUAL(UnreliableConstructorClass::constructedCount - UnreliableConstructorClass::destructedCount, 5);
			EXPECT_EXCEPTION(unreliable3.resize(15), "Evil constructor");
			EXPECT_EQUAL(UnreliableConstructorClass::constructedCount - UnreliableConstructorClass::destructedCount, 5);
		}
		heap.drain();
		EXPECT_EQUAL(heap.size(), 0);
	}

	{
		CheapHeap cheapHeap;
		EXPECT_NO_EXCEPTION(Vector<Byte> ok(65000, &cheapHeap));
		EXPECT_EXCEPTION(Vector<Byte> notOk(67000, &cheapHeap), "out of Commodore 64 memory");
		cheapHeap.drain();
		EXPECT_EQUAL(cheapHeap.size(), 0);
		EXPECT_EQUAL(TestDataClass::constructedCount, TestDataClass::destructedCount);
		Vector<TestDataClass> theVector(&cheapHeap);
		EXPECT_NO_EXCEPTION(theVector.resize(700));
		cheapHeap.drain();
		EXPECT_EQUAL(cheapHeap.size(), sizeOfAllocation(theVector.capacity() * sizeof (TestDataClass)));
		EXPECT_EQUAL(TestDataClass::constructedCount - TestDataClass::destructedCount, 700);
		EXPECT_EXCEPTION(theVector.resize(20000), "out of Commodore 64 memory");
		EXPECT_EQUAL(TestDataClass::constructedCount - TestDataClass::destructedCount, 700);
		theVector.shrink();
		cheapHeap.drain();
		EXPECT_EQUAL(cheapHeap.size(), sizeOfAllocation(700 * sizeof (TestDataClass)));
		theVector.resize(0);
		theVector.shrink();
		cheapHeap.drain();
		EXPECT_EQUAL(cheapHeap.size(), 0);
	}
}

/* --- Value tests --- */

struct DummyObject : public Object { };

void testValues() {
	std::cout << std::endl << "***** Value *****" << std::endl << std::endl;
	
	Heap heap;
	
	{
		EXPECT(Value::UNDEFINED.isUndefined());
		EXPECT(Value::NUL.isNull());
		EXPECT(Value::NOT_A_NUMBER.isNumber());	// lol
		EXPECT(Value::INFINITE_NUMBER.isNumber());
		EXPECT_EQUAL(Value::UNDEFINED.toObjectOrNull(heap, false), (Object*)(0));
		EXPECT_EXCEPTION(Value::UNDEFINED.toObject(heap, false), "TypeError: Cannot convert undefined or null to object");
		EXPECT_EQUAL(Value::NUL.toObjectOrNull(heap, false), (Object*)(0));
		EXPECT_EXCEPTION(Value::NUL.toObject(heap, false), "TypeError: Cannot convert undefined or null to object");
	}
	{
		const Value falseBoolValue(false);
		const Value trueBoolValue(true);
		EXPECT(falseBoolValue.isBoolean());
		EXPECT(trueBoolValue.isBoolean());
		EXPECT_EQUAL(falseBoolValue.asObject(), (Object*)(0));
		EXPECT_EQUAL(falseBoolValue.asFunction(), (Function*)(0));
		EXPECT_EQUAL(falseBoolValue.asArray(), (JSArray*)(0));
		EXPECT_EQUAL(trueBoolValue.asObject(), (Object*)(0));
		EXPECT_EQUAL(trueBoolValue.asFunction(), (Function*)(0));
		EXPECT_EQUAL(trueBoolValue.asArray(), (JSArray*)(0));
		EXPECT(!falseBoolValue.toBool());
		EXPECT(trueBoolValue.toBool());
		EXPECT_EQUAL(falseBoolValue.toInt(), 0);
		EXPECT_EQUAL(trueBoolValue.toInt(), 1);
		EXPECT_EQUAL(falseBoolValue.toDouble(), 0.0);
		EXPECT_EQUAL(trueBoolValue.toDouble(), 1.0);
		UInt32 index;
		EXPECT(trueBoolValue.toArrayIndex(index));
		EXPECT_EQUAL(index, 1);
		EXPECT_EXCEPTION(trueBoolValue.toFunction(heap), "TypeError: true is not a function");
		static const String FALSE_STRING("false");
		static const String TRUE_STRING("true");
		EXPECT(falseBoolValue.toString(heap)->isEqualTo(FALSE_STRING));
		EXPECT(trueBoolValue.toString(heap)->isEqualTo(TRUE_STRING));
		EXPECT_EQUAL(trueBoolValue.toWideString(heap), L"true");
		EXPECT_NOT_EQUAL(trueBoolValue.toObjectOrNull(heap, false), (Object*)(0));
		EXPECT_NO_EXCEPTION(trueBoolValue.toObject(heap, false));
		EXPECT(trueBoolValue.toObject(heap, false)->getInternalValue(heap).toBool());
		EXPECT_EQUAL(trueBoolValue.typeOfString(), &BOOLEAN_STRING);
		EXPECT(trueBoolValue.isStrictlyEqualTo(trueBoolValue));
		EXPECT(!trueBoolValue.isStrictlyEqualTo(Value(&TRUE_STRING)));
		EXPECT(trueBoolValue.isEqualTo(trueBoolValue));
		EXPECT(!trueBoolValue.isEqualTo(Value(&TRUE_STRING)));
		EXPECT(trueBoolValue.isEqualTo(Value(1.0)));
		EXPECT(!trueBoolValue.isLessThan(trueBoolValue));
		EXPECT(trueBoolValue.isLessThanOrEqualTo(trueBoolValue));
		EXPECT(trueBoolValue.isLessThan(Value(1234.5)));
		EXPECT(!trueBoolValue.isLessThan(Value(1.0)));
		EXPECT(trueBoolValue.isLessThanOrEqualTo(Value(1.0)));
		EXPECT(!trueBoolValue.equalsString(TRUE_STRING));
		EXPECT_EQUAL(trueBoolValue.add(heap, Value(1000.5)).toDouble(), 1001.5);
	}
	{
		const Value intNumberValue(1234);
		const Value floatNumberValue(1.33203125);	// exact in binary and decimal: 0x15500/65536.0
		const Value wrappingFloatNumber1(0xFFFFFFFFU + 1234.0);
		const Value wrappingFloatNumber2((0xFFFFFFFFU + 1234.0) * -1.0);
		EXPECT(intNumberValue.isNumber());
		EXPECT(floatNumberValue.isNumber());
		EXPECT_EQUAL(intNumberValue.asObject(), (Object*)(0));
		EXPECT_EQUAL(intNumberValue.asFunction(), (Function*)(0));
		EXPECT_EQUAL(intNumberValue.asArray(), (JSArray*)(0));
		EXPECT_EQUAL(floatNumberValue.asObject(), (Object*)(0));
		EXPECT_EQUAL(floatNumberValue.asFunction(), (Function*)(0));
		EXPECT_EQUAL(floatNumberValue.asArray(), (JSArray*)(0));
		EXPECT(!Value(0.0).toBool());
		EXPECT(intNumberValue.toBool());
		EXPECT(!Value::NOT_A_NUMBER.toBool());
		EXPECT_EQUAL(intNumberValue.toInt(), 1234);
		EXPECT_EQUAL(floatNumberValue.toInt(), 1);
		EXPECT_EQUAL(intNumberValue.toDouble(), 1234.0);
		EXPECT_EQUAL(floatNumberValue.toDouble(), 1.33203125);
		EXPECT_EQUAL(wrappingFloatNumber1.toInt(), 1233);
		EXPECT_EQUAL(wrappingFloatNumber2.toInt(), -1233);
		UInt32 index;
		EXPECT(intNumberValue.toArrayIndex(index));
		EXPECT_EQUAL(index, 1234);
		EXPECT(!floatNumberValue.toArrayIndex(index));
		EXPECT_EXCEPTION(intNumberValue.toFunction(heap), "TypeError: 1234 is not a function");
		static const String STRING_1234("1234");
		EXPECT(intNumberValue.toString(heap)->isEqualTo(STRING_1234));
		EXPECT_EQUAL(intNumberValue.toWideString(heap), L"1234");
		EXPECT_NOT_EQUAL(intNumberValue.toObjectOrNull(heap, false), (Object*)(0));
		EXPECT_NO_EXCEPTION(intNumberValue.toObject(heap, false));
		EXPECT_EQUAL(intNumberValue.toObject(heap, false)->getInternalValue(heap).toDouble(), 1234.0);
		EXPECT_EQUAL(intNumberValue.typeOfString(), &NUMBER_STRING);
		EXPECT(intNumberValue.isStrictlyEqualTo(intNumberValue));
		EXPECT(!intNumberValue.isStrictlyEqualTo(Value(&STRING_1234)));
		EXPECT(intNumberValue.isEqualTo(intNumberValue));
		EXPECT(intNumberValue.isEqualTo(Value(&STRING_1234)));
		EXPECT(!intNumberValue.isLessThan(intNumberValue));
		EXPECT(intNumberValue.isLessThan(Value(1234.5)));
		EXPECT(intNumberValue.isLessThanOrEqualTo(intNumberValue));
		EXPECT(!intNumberValue.isLessThanOrEqualTo(Value(1233.5)));
		EXPECT(!intNumberValue.equalsString(STRING_1234));
		EXPECT_EQUAL(intNumberValue.add(heap, Value(1000.5)).toDouble(), 2234.5);
	}
	{
		static const String CONSTANT_STRING("KONSTANT!");
		static const String LOLSTANT_STRING("LOLSTANT!");
		static const String NUMBER_STRING("-2.6640625");
		static const String INT_STRING("3493");
		const Value stringValue(&CONSTANT_STRING);
		const Value numberStringValue(&NUMBER_STRING);
		const Value intStringValue(&INT_STRING);
		EXPECT(stringValue.isString());
		EXPECT_EQUAL(stringValue.getString(), &CONSTANT_STRING);
		EXPECT_EQUAL(stringValue.asObject(), (Object*)(0));
		EXPECT_EQUAL(stringValue.asFunction(), (Function*)(0));
		EXPECT_EQUAL(stringValue.asArray(), (JSArray*)(0));
		EXPECT_EQUAL(stringValue.getString(), &CONSTANT_STRING);
		EXPECT(!Value(&EMPTY_STRING).toBool());
		EXPECT(stringValue.toBool());
		EXPECT_EQUAL(stringValue.toInt(), 0);
		EXPECT_EQUAL(numberStringValue.toInt(), -2);
		EXPECT(isNaN(stringValue.toDouble()));
		EXPECT_EQUAL(numberStringValue.toDouble(), -2.6640625);
		UInt32 index;
		EXPECT(!stringValue.toArrayIndex(index));
		EXPECT(!numberStringValue.toArrayIndex(index));
		EXPECT(intStringValue.toArrayIndex(index));
		EXPECT_EQUAL(index, 3493);
		EXPECT_EXCEPTION(stringValue.toFunction(heap), "TypeError: KONSTANT! is not a function");
		EXPECT(stringValue.toString(heap)->isEqualTo(CONSTANT_STRING));
		EXPECT_EQUAL(stringValue.toWideString(heap), L"KONSTANT!");
		EXPECT_NOT_EQUAL(stringValue.toObjectOrNull(heap, false), (Object*)(0));
		EXPECT_NO_EXCEPTION(stringValue.toObject(heap, false));
		EXPECT_EQUAL(stringValue.toObject(heap, false)->getInternalValue(heap).toWideString(heap), L"KONSTANT!");
		EXPECT_EQUAL(stringValue.typeOfString(), &STRING_STRING);
		EXPECT(stringValue.isStrictlyEqualTo(stringValue));
		EXPECT(stringValue.isEqualTo(stringValue));
		EXPECT(!intStringValue.isStrictlyEqualTo(Value(3493)));
		EXPECT(intStringValue.isEqualTo(Value(3493)));
		EXPECT(!stringValue.isLessThan(stringValue));
		EXPECT(stringValue.isLessThan(Value(&LOLSTANT_STRING)));
		EXPECT(stringValue.isLessThanOrEqualTo(stringValue));
		EXPECT(!stringValue.isLessThanOrEqualTo(Value(&EMPTY_STRING)));
		EXPECT(stringValue.equalsString(CONSTANT_STRING));
		EXPECT_EQUAL(stringValue.add(heap, Value(&LOLSTANT_STRING)).toWideString(heap), L"KONSTANT!LOLSTANT!");
		EXPECT_EQUAL(stringValue.add(heap, Value(1000.5)).toWideString(heap), L"KONSTANT!1000.5");
	}
	{
		DummyObject dummyObject;
		DummyObject dummyObject2;
		const Value objectValue(&dummyObject);
		const Value objectValue2(&dummyObject2);
		EXPECT(objectValue.isObject());
		EXPECT_EQUAL(objectValue.asObject(), &dummyObject);
		EXPECT_EQUAL(objectValue.getObject(), &dummyObject);
		EXPECT_EQUAL(objectValue.asFunction(), (Function*)(0));
		EXPECT_EQUAL(objectValue.asArray(), (JSArray*)(0));
		EXPECT(objectValue.toBool());
		EXPECT_EQUAL(objectValue.toInt(), 0);
		UInt32 index;
		EXPECT(!objectValue.toArrayIndex(index));
		EXPECT(isNaN(objectValue.toDouble()));
		EXPECT_EXCEPTION(objectValue.toFunction(heap), "TypeError: [object Object] is not a function");
		EXPECT_EQUAL(objectValue.toString(heap)->toWideString(), L"[object Object]");
		EXPECT_EQUAL(objectValue.toObjectOrNull(heap, false), &dummyObject);
		EXPECT_EQUAL(objectValue.toObject(heap, false), &dummyObject);
		EXPECT_EQUAL(objectValue.typeOfString(), &OBJECT_STRING);
		EXPECT(objectValue.isStrictlyEqualTo(objectValue));
		EXPECT(objectValue.isEqualTo(objectValue));
		EXPECT(!objectValue.isStrictlyEqualTo(objectValue2));
		EXPECT(!objectValue.isEqualTo(objectValue2));
		EXPECT(!objectValue.isLessThan(objectValue));
		EXPECT(!objectValue.isLessThanOrEqualTo(objectValue));
		EXPECT_EQUAL(objectValue.add(heap, objectValue2).typeOfString(), &NUMBER_STRING);
		EXPECT(isNaN(objectValue.add(heap, objectValue2).toDouble()));
	}
	{
		JSArray jsArray(heap.roots());
		const Value arrayValue(&jsArray);
		EXPECT(arrayValue.isObject());
		EXPECT_EQUAL(arrayValue.asObject(), &jsArray);
		EXPECT_EQUAL(arrayValue.asArray(), &jsArray);
	}
}

/* --- String tests --- */

void testStrings() {
	std::cout << std::endl << "***** String *****" << std::endl << std::endl;
	std::cout << "  - construction and comparison" << std::endl;
	std::cout << "  - wide/UTF-8 conversions" << std::endl;
	std::cout << "  - surrogate pair handling" << std::endl;
	std::cout << "  - character arrays" << std::endl;

	Heap heap;
	
	{
		static const String EMPTY_STRING;
		EXPECT_EQUAL(EMPTY_STRING.size(), 0);
	}
	{
		static const String STRING_FROM_CSTRING("fromCString");
		EXPECT_EQUAL(STRING_FROM_CSTRING.size(), 11);
		EXPECT_EQUAL(STRING_FROM_CSTRING.end() - STRING_FROM_CSTRING.begin(), 11);
		EXPECT(std::equal(STRING_FROM_CSTRING.begin(), STRING_FROM_CSTRING.end(), "fromCString"));
		const String stringOnHeap(heap.managed(), "fromCString");
		EXPECT(stringOnHeap.isEqualTo(STRING_FROM_CSTRING));
		const String stringFromStdString(heap.managed(), std::string("fromCString"));
		EXPECT(stringFromStdString.isEqualTo(STRING_FROM_CSTRING));
	}
	{
		static const String STRING_FROM_WIDE_CSTRING(L"fromWideCString\u4711");
		EXPECT_EQUAL(STRING_FROM_WIDE_CSTRING.size(), 16);
		EXPECT(std::equal(STRING_FROM_WIDE_CSTRING.begin(), STRING_FROM_WIDE_CSTRING.end(), L"fromWideCString\u4711"));
		EXPECT_EQUAL(*(STRING_FROM_WIDE_CSTRING.end() - 1), 0x4711);
		EXPECT_EQUAL(STRING_FROM_WIDE_CSTRING[0], L'f');
		EXPECT_EQUAL(STRING_FROM_WIDE_CSTRING[15], 0x4711);
		const std::string utf8String = STRING_FROM_WIDE_CSTRING.toUTF8String();
		EXPECT_EQUAL(utf8String.size(), 18);
		EXPECT(std::equal(utf8String.begin(), utf8String.end(), "fromWideCString\xE4\x9C\x91"));
		const std::wstring wideString = STRING_FROM_WIDE_CSTRING.toWideString();
		EXPECT_EQUAL(wideString.size(), 16);
		EXPECT(std::equal(wideString.begin(), wideString.end(), L"fromWideCString\u4711"));
		const String stringOnHeap(heap.managed(), L"fromWideCString\u4711");
		EXPECT(stringOnHeap.isEqualTo(STRING_FROM_WIDE_CSTRING));
		const String stringFromStdString(heap.managed(), std::wstring(L"fromWideCString\u4711"));
		EXPECT(stringFromStdString.isEqualTo(STRING_FROM_WIDE_CSTRING));
	}
	{
		static const String SURROGATE_PAIR_STRING(L"surrogatePair: \U0001F600");
		EXPECT_EQUAL(SURROGATE_PAIR_STRING.size(), 17);
		EXPECT_EQUAL(*(SURROGATE_PAIR_STRING.end() - 2), 0xD83D);
		EXPECT_EQUAL(*(SURROGATE_PAIR_STRING.end() - 1), 0xDE00);
		const std::string surrogatePairUTF8String = SURROGATE_PAIR_STRING.toUTF8String();
		EXPECT_EQUAL(surrogatePairUTF8String.size(), 19);
		EXPECT(std::equal(surrogatePairUTF8String.begin(), surrogatePairUTF8String.end(), "surrogatePair: \xF0\x9F\x98\x80"));
		const std::wstring surrogatePairWideString = SURROGATE_PAIR_STRING.toWideString();
		EXPECT(std::equal(surrogatePairWideString.begin(), surrogatePairWideString.end(), L"surrogatePair: \U0001F600"));
		const String stringOnHeap(heap.managed(), L"surrogatePair: \U0001F600");
		EXPECT(stringOnHeap.isEqualTo(SURROGATE_PAIR_STRING));
		const String stringFromStdString(heap.managed(), std::wstring(L"surrogatePair: \U0001F600"));
		EXPECT(stringFromStdString.isEqualTo(SURROGATE_PAIR_STRING));
	}
	{
		static const Char CHARS[] = { 'A', 'b', 'C', 'd', 'e', 'F', 'g', 'H', 'I', 'j', 'k', 'l', 'm' };
		static const String STRING_FROM_CHARS(CHARS + 0, CHARS + 13);
		EXPECT_EQUAL(STRING_FROM_CHARS.size(), 13);
		EXPECT(std::equal(STRING_FROM_CHARS.begin(), STRING_FROM_CHARS.end(), L"AbCdeFgHIjklm"));
		const String* stringFromChars2 = new(heap) String(heap.managed(), CHARS + 0, CHARS + 13);
		EXPECT_EQUAL(stringFromChars2->size(), 13);
		EXPECT(std::equal(stringFromChars2->begin(), stringFromChars2->end(), L"AbCdeFgHIjklm"));
	}
	heap.gc();
	heap.drain();
	EXPECT_EQUAL(heap.size(), 0);
}

/* --- Table tests --- */

void testTables() {
	std::cout << std::endl << "***** Table *****" << std::endl << std::endl;
	std::cout << "  - insertion and lookup" << std::endl;
	std::cout << "  - flag handling" << std::endl;
	std::cout << "  - iteration" << std::endl;

	Heap heap;
	{
		Table table(&heap);
		EXPECT_EQUAL(table.getLoadCount(), 0);
		EXPECT_EQUAL(table.getFirst(), (Table::Bucket*)(0));

		const String* firstKey = String::allocate(heap, "firstKey");
		Table::Bucket* b1 = table.insert(firstKey);
		EXPECT_NOT_EQUAL(b1, (Table::Bucket*)(0));
		EXPECT(table.update(b1, Value(1972)));
		EXPECT_EQUAL(table.getLoadCount(), 1);

		const String* secondKey = String::allocate(heap, "secondKey");
		Table::Bucket* b2 = table.insert(secondKey);
		EXPECT_NOT_EQUAL(b2, (Table::Bucket*)(0));
		EXPECT(table.update(b2, Value(4711), READ_ONLY_FLAG | DONT_DELETE_FLAG));
		EXPECT_EQUAL(table.getLoadCount(), 2);

		EXPECT_EQUAL(table.lookup(firstKey), b1);
		EXPECT_EQUAL(table.lookup(secondKey), b2);

		EXPECT_EQUAL(b1->getValue().toInt(), 1972);
		EXPECT_EQUAL(b2->getValue().toInt(), 4711);
		EXPECT((b2->getFlags() & READ_ONLY_FLAG) != 0);
		EXPECT((b2->getFlags() & DONT_DELETE_FLAG) != 0);

		EXPECT(!table.update(b2, Value(99)));
		EXPECT_EQUAL(b2->getValue().toInt(), 4711);
		EXPECT(!table.erase(b2));
		EXPECT(b2->valueExists());

		EXPECT(table.erase(b1));
		EXPECT(!b1->valueExists());

		table.update(b2, 123);
		EXPECT(b2->valueExists());
		EXPECT_EQUAL(b2->getIndexValue(), 123);
		EXPECT((b2->getFlags() & INDEX_TYPE_FLAG) != 0);

		for (int i = 0; i < 20; ++i) {
			table.update(table.insert(String::fromInt(heap, i)), i);
		}

		UInt32 count = 0;
		for (Table::Bucket* it = table.getFirst(); it != 0; it = table.getNext(it)) {
			if (it->valueExists()) {
			        ++count;
			}
		}
		EXPECT_EQUAL(count, 21);
	}
}

// --- main ---

int main(int argc, const char* argv[]) {
	if (argc >= 2 && strcmp(argv[1], "-s") == 0) {
		return selfTest();
	} else {
		testHeap();
		testValues();
		testVectors();
		testStrings();
		testTables();
		testVars();
		testArrayVars();
		testJSON();
		testCompilation();
		testLimits();
		testHighLevelAPI();
		readMeSample1();
		readMeSample2();
		if (failureCount == 0) {
			std::cout << "All " << testCount << " checks passed successfully" << std::endl << std::endl;
			return 0;
		} else {
			std::cout << failureCount << " checks out of " << testCount << " failed!" << std::endl << std::endl;
			return 1;
		}
	}
}
