#ifdef _MSC_VER
#pragma float_control(precise, on, push)  
#endif

#include "../src/NuXJScript.h"
#include <fstream>
#include <memory>
#include <vector>
#include <sstream>
#include <ctime>

using namespace NuXJS;

static int recursiveStackCheck(const Code& code, Vector<Int32>& stackDepths
		, Int32 offset, Int32 currentStackDepth, Int32& maxStackDepth) {
	const CodeWord* codeWords = code.getCodeWords();
	const UInt32 codeSize = code.getCodeSize();
	
	int errors = 0;
	for (; offset < static_cast<Int32>(codeSize); ++offset) {
		if (stackDepths[offset] != DEAD_CODE_STACK_DEPTH) {
			if (stackDepths[offset] != currentStackDepth) {
				std::cerr << "Conflicting stack depth @" << offset << ": " << currentStackDepth << " & " << stackDepths[offset] << std::endl;
				++errors;
			}
			return errors;
		}

		const std::pair<Processor::Opcode, Int32> pair = Processor::unpackInstruction(codeWords[offset]);
		const Processor::Opcode opcode = pair.first;
		const Int32 operand = pair.second;
		if (opcode < 0 || opcode >= Processor::OP_COUNT) {
			std::cerr << "Invalid opcode " << static_cast<int>(opcode) << "@" << offset << std::endl;
			++errors;
		}
		stackDepths[offset] = currentStackDepth;
		if (currentStackDepth > static_cast<Int32>(code.getMaxStackDepth())) {
			std::cerr << "Stack overflow (code max is " << code.getMaxStackDepth() << ", stack depth @" << offset << " is " << currentStackDepth << ")" << std::endl;
			++errors;
		}
		maxStackDepth = std::max(maxStackDepth, currentStackDepth);
#if (VERIFY_STACK_LOGIC)
	if (stackDepths[offset] != code.stackDepths[offset]) {
		std::cerr << "Invalid compile-time stack depth @" << offset << " (" << code.stackDepths[offset] << " vs " << stackDepths[offset] << ")" << std::endl;
		++errors;
	}
#endif
		const Processor::OpcodeInfo& info = Processor::getOpcodeInfo(opcode);
		const Int32 thisStackUse = info.stackUse + (((info.flags & Processor::OpcodeInfo::POP_OPERAND) != 0) ? -operand : 0);
		currentStackDepth += thisStackUse;
		maxStackDepth = std::max(maxStackDepth, currentStackDepth);
		if (currentStackDepth < 0) {
			std::cerr << "Negative stack depth @" << offset << std::endl;
			++errors;
		}
		switch (opcode) {
			case Processor::JT_OP:
			case Processor::JF_OP:
			case Processor::JT_OR_POP_OP:
			case Processor::JF_OR_POP_OP:
			case Processor::JMP_OP:
			case Processor::JSR_OP:
			case Processor::TRY_OP:
			case Processor::NEXT_PROPERTY_OP: {
				const Int32 targetOffset = offset + 1 + operand;
				if (targetOffset < 0 || targetOffset >= static_cast<Int32>(codeSize)) {
					std::cerr << "Invalid target @" << offset << ": @" << targetOffset << std::endl;
					++errors;
					return errors;
				}
				const Int32 targetStackDepth = currentStackDepth + (((info.flags & Processor::OpcodeInfo::NO_POP_ON_BRANCH) != 0) ? 1 : 0)
						+ (((info.flags & Processor::OpcodeInfo::POP_ON_BRANCH) != 0) ? -1 : 0);
				errors += recursiveStackCheck(code, stackDepths, targetOffset, targetStackDepth, maxStackDepth);
				if (opcode == Processor::JMP_OP) {
					return errors;
				}
				break;
			}
			case Processor::RETURN_OP: // fix: check all returns from jsr end with the same stack pointer as entry (keep track with extra parameter that only updates with JSR)
			case Processor::THROW_OP: {
				return errors;
			}
	
			default: break;
		}
	}

	return errors;
}

static void implicitAllocations(Runtime& rt) {
	Var a = rt.newArrayVar();
	Var X(rt, "x");
	Var Y(rt, "y");
	rt.getHeap().gc();
	for (int i = 0; i < 10000000; ++i) {
		Var o = rt.newObjectVar();
		a[i % 80000] = o;
		o[X] = i * 23;
		o[Y] = i * 57;
		if ((i % 100) == 0) {
			rt.autoGC(true);
		}
		if ((i % 100000) == 0) {
			std::cerr << i << std::endl;
		}
	}
	rt.getHeap().gc();
}

static void operatorTest(Runtime& rt) {
	std::string t1;
	std::string t2 = "pokpok"+t1;
	Var s0(rt, "to");
	Var s1(rt, "gether");
	Heap& heap = rt.getHeap();
	std::wcout << (new(heap) String(heap.managed(), s0, s1))->toWideString() << std::endl;
	std::wcout << String::concatenate(heap, s0, s1)->toWideString() << std::endl;
	std::wcout << String(heap.roots(), s0, s1).toWideString() << std::endl;
/*	std::wcout << (s0 + s1) << std::endl;
	std::wcout << (s0 + "ijkl") << std::endl;
	std::wcout << ("ijkl" + s1) << std::endl;*/
/*	const double d = s0 - s1;
	std::wcout << d << std::endl;*/
}

#if (_MSC_VER)
#include <Windows.h>
#undef min
#undef max
double getCPUSecs() {
	::FILETIME creationTime;
	::FILETIME exitTime;
	::FILETIME kernelTime;
	::FILETIME userTime;
	BOOL success = ::GetProcessTimes(::GetCurrentProcess(), &creationTime, &exitTime, &kernelTime, &userTime);
	assert(success);
	return ((static_cast<__int64>(userTime.dwHighDateTime) << 32) | userTime.dwLowDateTime) / 10000000.0;
}
#else
#include <sys/time.h>
#include <sys/resource.h>
double getCPUSecs() {
	rusage rus;
	int res = getrusage(RUSAGE_SELF, &rus);
	assert(res == 0);
	return rus.ru_utime.tv_sec + rus.ru_utime.tv_usec / 1000000.0;
}
#endif

	bool interactive = true;

	std::vector<std::string> ioLines;

	void pushIOLines(char typeChar, const String& s) {
		const Char* p = s.begin();
		const Char* e = s.end();
		do {
			const Char* b = p;
			while (p != e && *p != '\n') {
				++p;
			}
			ioLines.push_back(typeChar + std::string(" ") + std::string(b, p));
			if (p != e) {
				++p;
			}
		} while (p != e);
	}

	void pushIOStop() {
		ioLines.push_back("-");
	}

	class PrintFunction : public Function {
		public:		virtual Value invoke(Runtime& rt, Processor& processor, UInt32 argc, const Value* argv, Object* thisObject) {
						const String* s = (argc >= 1 ? argv[0].toString(rt.getHeap()) : &EMPTY_STRING);
						std::wcout << s->toWideString().c_str() << std::endl;
						if (interactive) {
							pushIOLines('<', *s);
						}
						return Value::UNDEFINED;
					}
	};

	struct GCFunction : public Function {
		virtual Value invoke(Runtime& rt, Processor& processor, UInt32 argc, const Value* argv, Object* thisObject) {
			rt.getHeap().gc();
			rt.getHeap().drain();
			return Value::UNDEFINED;
		}
	};

	class NativeTestObject : public Object {
		protected:	struct AddFunction : public Function {
						typedef Function super;
						virtual Value invoke(Runtime& rt, Processor& processor, UInt32 argc, const Value* argv, Object* thisObject) {
							Heap& heap = rt.getHeap();
							if (thisObject->getClassName() != &NativeTestObject::className) {
								ScriptException::throwError(heap, TYPE_ERROR, "Invalid class");
							}
							const NativeTestObject* me = reinterpret_cast<NativeTestObject*>(thisObject);
							const double addX = (argc >= 1 ? argv[0].toDouble() : 0.0);
							const double addY = (argc >= 2 ? argv[1].toDouble() : 0.0);
							return new(heap) NativeTestObject(heap.managed(), addX + me->x, addY + me->y);
						}
					};

		public:		typedef Object super;
					NativeTestObject(GCList& gcList, double x, double y) : super(gcList), x(x), y(y) { }
					virtual const String* getClassName() const { return &className; };
					virtual Flags getOwnProperty(Runtime& rt, const Value& key, Value* v) const {
						if (key.equalsString("x")) { *v = x; return HIDDEN_CONST_FLAGS; };
						if (key.equalsString("y")) { *v = y; return HIDDEN_CONST_FLAGS; };
						if (key.equalsString("add")) { *v = &addFunction; return HIDDEN_CONST_FLAGS; };
						return super::getOwnProperty(rt, key, v);
					}
		
					virtual const String* toString(Heap& heap) const {
						std::stringstream ss;
						ss << "x: " << x << ", y: " << y;
						return String::allocate(heap, ss.str().c_str());
					}

		
		protected:	double x;
					double y;
					static String className;
					static AddFunction addFunction;
	};
	String NativeTestObject::className("NativeTestObject");
	NativeTestObject::AddFunction NativeTestObject::addFunction;

	class CallbackTest : public Function {
		public:		virtual Value invoke(Runtime& rt, Processor& processor, UInt32 argc, const Value* argv, Object* thisObject) {
						PrintFunction printFunction;
						for (UInt32 i = 0; i < argc; ++i) {
							Function* f = argv[i].asFunction();
							if (f == 0) {
								f = &printFunction;
							}
							rt.call(f, 1, &argv[i]);
						}
						return Value::UNDEFINED;
					}
	};

	static void disassemble(Heap& heap, const Code& code) {
		const CodeWord* codeWords = code.getCodeWords();
		const Value* constants = code.getConstants()->begin();
		const UInt32 codeSize = code.getCodeSize();
		
		Vector<Int32> stackDepths(codeSize, &heap);
		std::fill(stackDepths.begin(), stackDepths.end(), DEAD_CODE_STACK_DEPTH);
		
		Int32 maxStackDepth = 0;
		int errors = recursiveStackCheck(code, stackDepths, 0, 1, maxStackDepth);
		if (maxStackDepth != code.getMaxStackDepth()) {
			std::cerr << "Notice: code definition max stack depth is " << code.getMaxStackDepth() << " but max stack depth actually used is " << maxStackDepth << std::endl;
		}
		
		for (UInt32 offset = 0; offset < codeSize; ++offset) {
			const std::pair<Processor::Opcode, Int32> pair = Processor::unpackInstruction(codeWords[offset]);
			const Processor::Opcode opcode = pair.first;
			const Int32 operand = pair.second;
			if (opcode < 0 || opcode >= Processor::OP_COUNT) {
				break;
			}

			if (stackDepths[offset] == DEAD_CODE_STACK_DEPTH) {
				std::cerr << "?";
			} else {
				std::cerr << stackDepths[offset];
			}
			std::cerr << "\t";
	#if (VERIFY_STACK_LOGIC)
			if (code.stackDepths[offset] == DEAD_CODE_STACK_DEPTH) {
				std::cerr << "?";
			} else {
				std::cerr << code.stackDepths[offset];
			}
			std::cerr << "\t";
	#endif
			std::cerr << "@" << offset << ":\t" << Processor::getOpcodeInfo(opcode).mnemonic;
			
			switch (opcode) {
				case Processor::JT_OP:
				case Processor::JF_OP:
				case Processor::JT_OR_POP_OP:
				case Processor::JF_OR_POP_OP:
				case Processor::JMP_OP:
				case Processor::JSR_OP:
				case Processor::TRY_OP:
				case Processor::NEXT_PROPERTY_OP: {
					const Int32 target = offset + 1 + operand;
					std::cerr << " @" << target;
					break;
				}
				case Processor::READ_LOCAL_OP:
				case Processor::WRITE_LOCAL_OP:
				case Processor::WRITE_LOCAL_POP_OP: {
					const Int32 index = operand;
					const String* name = code.getLocalName(index);
					if (name != 0) std::wcerr << L" $" << name->toWideString();
					std::wcerr << L" (" << index << L")";
					break;
				}
				case Processor::CALL_OP:
				case Processor::CALL_METHOD_OP:
				case Processor::CALL_EVAL_OP:
				case Processor::NEW_OP:
				case Processor::POP_OP:
				case Processor::PUSH_BACK_OP:
				case Processor::PUSH_ELEMENTS_OP: std::cerr << " *" << operand; break;
				case Processor::REPUSH_OP: std::cerr << " " << operand; break;
				case Processor::CONST_OP:
				case Processor::GEN_FUNC_OP:
				case Processor::CATCH_SCOPE_OP: std::wcerr << L" #" << constants[operand].toString(heap)->toWideString(); break;
				case Processor::DECLARE_OP:
				case Processor::READ_NAMED_OP:
				case Processor::WRITE_NAMED_OP:
				case Processor::WRITE_NAMED_POP_OP:
				case Processor::ADD_PROPERTY_OP:
				case Processor::DELETE_NAMED_OP:
				case Processor::TYPEOF_NAMED_OP: std::wcerr << L" " << constants[operand].toString(heap)->toWideString(); break;
				default: break;
			}
			std::cerr << std::endl;
		}
		
		std::cerr << "\tMax stack depth: " << code.getMaxStackDepth() << std::endl;
		std::cerr << "\tCode: " << code.getCodeSize() << std::endl;
	//	std::cerr << "\tConstants: " << code.getConstants().size() << std::endl;
		std::cerr << "\tVars: " << code.getVarsCount() << std::endl;
		std::cerr << "\tArguments: " << code.getArgumentsCount() << std::endl;
	/* FIX :	for (const Value* p = code.constants.begin(); p != code.constants.end(); ++p) {
			std::wcerr << "\t\t" << p.toString(heap).toWideString() << std::endl;
		}*/

		assert(errors == 0);
	}

	Value disassemble(Runtime& rt, Processor& processor, UInt32 argc, const Value* argv, Object* thisObject) {
		Heap& heap = rt.getHeap();
		Function* f = (argc >= 1 ? argv[0].asFunction() : 0);
		if (f == 0) { // FIX : sub to make is not a function error or something?
			ScriptException::throwError(heap, TYPE_ERROR, String::concatenate(heap, *argv[0].toString(heap), String(" is not a function")));
		}
		const Code* code = f->getScriptCode();
		if (code == 0) {
			ScriptException::throwError(heap, TYPE_ERROR, "Cannot disassemble native code");
		}
		disassemble(heap, *code);
		return Value::UNDEFINED;
	}

	Value gcTest(Runtime& rt, Processor& processor, UInt32 argc, const Value* argv, Object* thisObject) {
		VarList safeKeep(rt, argc, argv);
		Heap& heap = rt.getHeap();
		heap.gc();
		Value v = String::allocate(heap, "");
		for (UInt32 i = 0; i < argc; ++i) {
			v = String::concatenate(heap, *v.toString(heap), *argv[i].toString(heap));
		}
		return v;
	}

bool pauseBeforeQuit = false;

String TEST_CLASS_STRING("NativeObject");
class NativeObject : public JSObject {
	public:		typedef JSObject super;
	public:		NativeObject(GCList& gcList, Object* prototype) : super(gcList, prototype), x(0.3) { }
	public:		NativeObject(GCList& gcList, Object* prototype, const VarList& args)
						: super(gcList, prototype), x(args[0] != Value::UNDEFINED ? args[0] : 0.0) { if (args[1] != Value::UNDEFINED) { Var me = args[1]; me = this; args[1](); } }
	public:		virtual const String* getClassName() const { return &TEST_CLASS_STRING; }
	public:		static Var testMethod1(Runtime& rt, const Var& thisVar, const VarList& args) {
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
					return Var(rt, x);
				}
	protected:	double x;
};

struct BindingTestObject {
	BindingTestObject() : x(123.456) { }
	Var method(Runtime& rt, const Var& thisVar, const VarList& args) {
		return Var(rt, x);
	}
	double x;
};

struct NativeConstructor : public ExtensibleFunction {
	typedef ExtensibleFunction super;
	NativeConstructor(GCList& gcList, const Var& prototype) : super(gcList), prototype(prototype) { }
	virtual Value invoke(Runtime& rt, Processor& processor, UInt32 argc, const Value* argv, Object* thisObject) {
		Heap& heap = rt.getHeap();
		return new(heap) NativeObject(heap.managed(), prototype, VarList(rt, argc, argv));
	}
	Var prototype;
};

Var test1(Runtime& rt, const Var& thisVar, const VarList& args) {
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

static std::wstring utf8ToUtf16(const std::string& utf8) {
       std::wstring wide;
       wide.reserve(utf8.size());
       for (size_t i = 0; i < utf8.size();) {
               unsigned char c = utf8[i];
               if (c < 0x80) {
                       wide.push_back(static_cast<wchar_t>(c));
                       ++i;
               } else if ((c & 0xE0) == 0xC0 && i + 1 < utf8.size()) {
                       wchar_t w = ((c & 0x1F) << 6) | (utf8[i + 1] & 0x3F);
                       wide.push_back(w);
                       i += 2;
               } else if ((c & 0xF0) == 0xE0 && i + 2 < utf8.size()) {
                       wchar_t w = ((c & 0x0F) << 12) | ((utf8[i + 1] & 0x3F) << 6) | (utf8[i + 2] & 0x3F);
                       wide.push_back(w);
                       i += 3;
               } else if ((c & 0xF8) == 0xF0 && i + 3 < utf8.size()) {
                       unsigned int cp = ((c & 0x07) << 18) | ((utf8[i + 1] & 0x3F) << 12)
                                       | ((utf8[i + 2] & 0x3F) << 6) | (utf8[i + 3] & 0x3F);
                       cp -= 0x10000;
                       wide.push_back(static_cast<wchar_t>(0xD800 | (cp >> 10)));
                       wide.push_back(static_cast<wchar_t>(0xDC00 | (cp & 0x3FF)));
                       i += 4;
               } else {
                       wide.push_back(L'?');
                       ++i;
               }
       }
       return wide;
}

Var read(Runtime& rt, const Var& thisVar, const VarList& args) {
       std::ifstream file;
       std::wstring contentsWide;
       try {
               const std::wstring filenameWide = args[0];
               file.open(std::string(filenameWide.begin(), filenameWide.end()).c_str(), std::ios::binary);
               if (!file.good()) {
                       ScriptException::throwError(rt.getHeap(), GENERIC_ERROR, "Could not open input file");
               }
               file.exceptions(std::ios_base::badbit | std::ios_base::failbit);
               std::string contents((std::istreambuf_iterator<char>(file)), std::istreambuf_iterator<char>());
               contentsWide = utf8ToUtf16(contents);
       }
       catch (const std::ios_base::failure& x) {
               ScriptException::throwError(rt.getHeap(), GENERIC_ERROR, x.what());
       }
       return Var(rt, contentsWide);
}

Var load(Runtime& rt, const Var& thisVar, const VarList& args) {
	Var source = read(rt, thisVar, args);
	rt.run(source);
	return Var(rt);
}

bool doQuit = false;

Var quit(Runtime& rt, const Var& thisVar, const VarList& args) {
	doQuit = true;
	return Var(rt);
}

struct MyHeap : public Heap {
	MyHeap() : peakSize(0) { }
	virtual void* acquireMemory(size_t size) {
		void* p = Heap::acquireMemory(size);
		if (allocatedSize > peakSize) {
			peakSize = allocatedSize;
		//	std::cout << " peak: " << peakSize << std::endl;
		}
		// std::cout << " + " << size << std::endl;
		return p;
	}
/*	virtual void releaseMemory(void* ptr, size_t size) {
		// std::cout << " - " << size << std::endl;
		return Heap::releaseMemory(ptr, size);
	}*/
	size_t peakSize;
};

#if (_MSC_VER)
        #include <Windows.h>
        #include <time.h>
#elif defined(__APPLE__)
        #include <mach/mach_time.h>
        #include <libkern/OSAtomic.h>
#else
        #include <time.h>
        #include <sys/time.h>
#endif

void randomSeed() {
	unsigned int seed;
#if (_MSC_VER)
        ::LARGE_INTEGER count;
        ::BOOL success = ::QueryPerformanceCounter(&count);
        if (!success) {
                count.LowPart = 0;
                count.HighPart = 0;
        }
        seed = (static_cast<unsigned int>(time(0)) ^ count.LowPart)
                        + (static_cast<unsigned int>(::GetTickCount()) ^ count.HighPart);
#elif defined(__APPLE__)
        const uint64_t t = ::mach_absolute_time();
        seed = (static_cast<unsigned int>(time(0)) ^ static_cast<unsigned int>(t & 0xFFFFFFFFU))
                        + (static_cast<unsigned int>(clock()) ^ static_cast<unsigned int>((t >> 32) & 0xFFFFFFFFU));
#else
        struct timespec ts;
        clock_gettime(CLOCK_MONOTONIC, &ts);
        const uint64_t t = static_cast<uint64_t>(ts.tv_sec) ^ static_cast<uint64_t>(ts.tv_nsec);
        seed = (static_cast<unsigned int>(time(0)) ^ static_cast<unsigned int>(t & 0xFFFFFFFFU))
                        + (static_cast<unsigned int>(clock()) ^ static_cast<unsigned int>((t >> 32) & 0xFFFFFFFFU));
#endif
        srand(seed);
}

int testMain(int argc, const char* argv[]) {
	// FIX : exception handling on top-level
    String source(EMPTY_STRING);
    std::auto_ptr<std::wifstream> inputFileStream;
    std::wistream* inStream = &std::wcin;
    bool doTime = false;
    int gcRate = 256; // FIX : drop or what?
    size_t peakMemory = 0;
    bool autoGCRate = true;
	bool doSuppressStdErr = false;
	bool loadStdLib = true;
    for (int argi = 1; argi < argc; ++argi) {
        if (strcmp(argv[argi], "-t") == 0) doTime = true;
        else if (strcmp(argv[argi], "-s") == 0) doSuppressStdErr = true;
        else if (argi + 1 < argc && strcmp(argv[argi], "-gc") == 0) {
            gcRate = atoi(argv[++argi]);
            autoGCRate = false;
        }
        else if (strcmp(argv[argi], "-p") == 0) pauseBeforeQuit = true;
        else if (strcmp(argv[argi], "-n") == 0) loadStdLib = false;
        else if (inputFileStream.get() == 0) {
            inputFileStream.reset(new std::wifstream(argv[argi]));
            inStream = inputFileStream.get();
            interactive = false;
        } else {
            std::cout << "Too many arguments" << std::endl;
            return 1;
        }
    }

	if (!inStream->good()) {
		std::cerr << "Could not open input stream" << std::endl;
		return 1;
	}
	// FIX : this didnt work
	// inStream->exceptions(std::ios_base::badbit | std::ios_base::failbit);

    /*std::cout << sizeof(Value) << std::endl;
     std::cout << sizeof(String) << std::endl;
     std::cout << sizeof(JSObject) << std::endl;
     std::cout << sizeof(Array) << std::endl;
     std::cout << sizeof(ScriptFunction) << std::endl;*/
    const String LF_STRING("\n");
    const String PRINT_STRING("print");
    /*std::cerr << "Value size: " << sizeof (Value) << std::endl;
     std::cerr << "Bucket size: " << sizeof (Table::Bucket) << std::endl;
     std::cerr << "Table size: " << sizeof (Table) << std::endl;*/

    MyHeap heap;
    Runtime rt(heap);
	Object& globals = *rt.getGlobalObject();
	Var globs = rt.getGlobalsVar();
	globs["read"] = read;
	globs["load"] = load;
	globs["quit"] = quit;

#if 0
    rt.setMemoryCap(8192*10);
    Var anObject = rt.eval("({ a: 123.45, b: 'y' })");
    Var aValue = anObject["a"];
    std::wstring ws = anObject["a"];
    anObject["c"] = 99;
    anObject["z"] = rt.eval("(123)");
    std::wcout << aValue << std::endl;
    std::wcout << static_cast<Var>(anObject["z"]) << std::endl;
    std::wcout << ws << std::endl;

	
	Var v23(rt);
    bool b = v23;
    const Value args[1] = { v23 };
  //  rt.call(v23, 0, args);
    std::wcout << rt.eval("s = 0; for (i = 0; i < 100; ++i) s += i; s") << std::endl;
    double v = rt.eval("s = 0; for (i = 0; i < 100; ++i) s += i; s");
    std::wcout << v23 << std::endl;

    rt.setMemoryCap(512 * 1024 * 1024);
 /*   JSObject globals(heap.roots(), &rt.objectPrototype);
	rt.setGlobalObject(&globals);
	*/
	
rt.setupStandardLibrary();
	globs["tezt"] = 55;
	assert(globs.has("tezt"));
	assert(!globs.has("ttezt"));
	globs["tezt2"] = globs["tezt"];
	double ddd = globs["tezt"];
	globs["f"] = rt.eval("(function(a, b) { return a + b })");
	globs["arr"] = rt.eval("([1,3,5,2,4,6])");
	globs["test1"] = test1;
	Var o = globs["o"] = new(heap) JSObject(heap.managed(), rt.getObjectPrototype());
	o["gcTest"] = gcTest;
	o["zub"] = "yo";
	std::wcout << globs["f"](29, 99) << std::endl;
	Var a = globs["arr"];
	std::wcout << o["gcTest"]("hej", 12959) << std::endl;
	std::wcout << o["gcTest"]("hej", 12959, "zzz") << std::endl;
	const Value list[4] = { Var(rt, "a"), Var(rt, "bcd"), Var(rt, 1391), Var(rt, "zz9z9") };
	std::wcout << o["gcTest"](VarList(rt, 4, list)) << std::endl;
	std::wcout << globs["o"][o["gcTest"]("zub")] << std::endl;

	globs["o2"] = rt.newObject();
	Var arrr = globs["o2"]["a"] = rt.newArray();
	for (int i = 0; i < 22; ++i) arrr[i] = i * 3;
	std::wcout << globs["o2"]["a"]["length"] << std::endl;
	std::wcout << globs["o2"]["a"]["toString"]() << std::endl;
	std::wcout << globs["o2"]["a"][15]["toString"](16) << std::endl;

	Var regExp = rt.eval("(/x.*y/)");
	std::wcout << regExp["test"]("xyzzzy") << std::endl;
//	a = 55;
	for (int i = 0; i < a.length(); ++i) {
		std::wcout << a[i] << std::endl;
		a[i] = a[i] * 2;
	}
	
	Var nativeObjectPrototype = rt.newObject();
	nativeObjectPrototype["testMethod1"] = NativeObject::testMethod1;
//	nativeObjectPrototype["testMethod2"] = new(rt.getHeap()) VarMemberFunctionAdapter<NativeObject>(rt.getHeap().managed(), &NativeObject::testMethod2);
	nativeObjectPrototype["nativeMethod"] = &NativeObject::nativeMethod;
	globs["NativeObject"] = NativeObject::construct;
	globs["NativeObject"]["prototype"] = nativeObjectPrototype;
	
	globs["NativeObject2"] = new(heap) NativeConstructor(heap.managed(), nativeObjectPrototype);
	
	BindingTestObject bindingTestObject;
	globs["bound"] = Var(rt, &bindingTestObject, &BindingTestObject::method);
	
	Var booool(rt);
	std::wcout << (booool.to<bool>() ? L"true" : L"false") << std::endl;
#endif
    PrintFunction printFunction;
    globals.setOwnProperty(rt, &PRINT_STRING, &printFunction, DONT_ENUM_FLAG);
    GCFunction gcFunction;
    const String GC_STRING("gc");
    globals.setOwnProperty(rt, &GC_STRING, &gcFunction, DONT_ENUM_FLAG);
    globals.setOwnProperty(rt, String::allocate(heap, "dasm"), new(heap) FunctorAdapter<NativeFunction>(heap.managed(), disassemble), DONT_ENUM_FLAG);
CallbackTest callbackTest;
globals.setOwnProperty(rt, String::allocate(heap, "callbackTest"), &callbackTest, DONT_ENUM_FLAG);
//globals.setOwnProperty(rt, String::alloc(heap, "nativeTestObject"), new(heap) NativeTestObject(heap.managed(), 1.4, 2.9));

	randomSeed();

	if (loadStdLib) {
		try {
/* FIX : drop			std::wifstream stdlibStream("stdlib.js");
			std::wstring sourceWString = std::wstring(std::istreambuf_iterator<wchar_t>(stdlibStream), std::istreambuf_iterator<wchar_t>());
			String source = String(heap.roots(), sourceWString.c_str());
			stdlibStream.close();*/
			rt.setupStandardLibrary();
		}
		catch (const std::exception& x) {
			std::cerr << "exception setting up standard lib: " << x.what() << std::endl;
			return 1;
		}
		catch (...) {
			std::cerr << "exception setting up standard lib" << std::endl;
			return 1;
		}
	}

// operatorTest(rt);
// implicitAllocations(rt);

	Processor processor(rt);
	processor.run(STANDARD_CYCLES_BETWEEN_AUTO_GC);	// just testing some weird behaviour
//	const Value TEST_ARGV[1] = { String::alloc(heap, "Hello") };
//	printFunction.invoke(processor, 1, TEST_ARGV, &globals);
//	processor.run();	// just testing some weird behaviour
	
	inStream->exceptions(std::wifstream::badbit);
    while (inStream->good() && !doQuit) {
    	assert(!inStream->fail());
        bool execute = false;
        try {
            std::wstring s;
            if (interactive) {
                std::getline(*inStream, s);
                // FIX : add #undo that drops just the last one
                if (s == L"#save" || s.substr(0, 6) == L"#save ") {
                    const time_t t = time(0);
                    char fn[257];
                    if (s.size() >= 6) {
                        std::wstring ws = L"tests/";
                        ws += s.substr(6);
                        ws += L".io";
                        strncpy(fn, std::string(ws.begin(), ws.end()).c_str(), 256);
                        fn[256] = 0;
                    } else {
                        strftime(fn, 256, "tests/%Y%m%d_%H%M%S.io", localtime(&t));
                    }
                    std::ofstream saveStream(fn);
                    for (std::vector<std::string>::const_iterator it = ioLines.begin(); it != ioLines.end(); ++it) {
                        saveStream << *it << std::endl;
                    }
                    saveStream.close();
                    ioLines.clear();
                    std::cout << "saved to " << fn << std::endl;
                } else if (s == L"#purge") {
                    ioLines.clear();
                    std::cout << "purged" << std::endl;
                } else if (!s.empty()) {
                    String line(heap.roots(), s.c_str());
                    if (!source.empty()) source = String(heap.roots(), source, LF_STRING);
                    source = String(heap.roots(), source, line);
                } else {
                    if (source.size() > 0 && source[0] == '?') {
                        source = String(heap.roots(), String(heap.roots(), String("print("), String(heap.roots(), source.begin() + 1, source.end())), String(")")); // FIX : operator +
                    }
                    if (interactive) {
                        pushIOLines('>', source);
                    }
                    execute = true;
                }
            } else {
				std::wstring sourceWString = std::wstring(std::istreambuf_iterator<wchar_t>(*inStream), std::istreambuf_iterator<wchar_t>());
				source = String(heap.roots(), sourceWString.c_str());
                execute = true;
                doQuit = true; // FIX : we shouldn't use the same loop for interactive and non-interactive
            }
			
            if (execute) {
			    Code globalCode(heap.roots());
                Compiler compiler(heap.roots(), &globalCode, (interactive ? Compiler::FOR_EVAL : Compiler::FOR_GLOBAL));
                try {
                    compiler.compile(source);
                }
                catch (const Exception&) {
                	size_t offset;
                	int lineNumber;
                	int columnNumber;
                	compiler.getStopPosition(offset, lineNumber, columnNumber);
                    std::wstring ws;
                    {
                        std::wstringstream ss;
                        ss << L"!!!! Line: " << lineNumber;
						// ss << ", column: " << columnNumber; // FIX : keep or not? if so, need to update all tests:
                        ws = ss.str();
                    }
                    std::wcout << ws << std::endl;
                    if (interactive) {
                        pushIOLines('!', String(heap.roots(), ws.c_str()));
                    }
// FIX :						std::wcout << std::wstring(std::max<const Char*>(stopPoint - 8, source.begin()), std::min<const Char*>(stopPoint + 8, source.end())) << std::endl;
                    throw;
                }
                if (!doSuppressStdErr) {
/*                	const Constants* const consts = rt.getSharedConstants();
                    for (const Value* p = consts->begin(); p != consts->end(); ++p) {
                        std::wcerr << "\t\t" << p->toString(heap)->toWideString() << std::endl;
                    }*/
                }
               	processor.run(STANDARD_CYCLES_BETWEEN_AUTO_GC);	// just testing some weird behaviour
                processor.enterGlobalCode(&globalCode);

                bool done = false;
			    rt.resetTimeOut(60);
                const double start = getCPUSecs();
               	do {
                    done = !processor.run(STANDARD_CYCLES_BETWEEN_AUTO_GC);
					rt.autoGC(true);
					rt.checkTimeOut();
                   	peakMemory = std::max<size_t>(peakMemory, heap.size());
                } while (!done);

				processor.run(STANDARD_CYCLES_BETWEEN_AUTO_GC);	// just testing some weird behaviour
				if (!doSuppressStdErr) {
					Value v = processor.getResult();
					std::wcerr << L"\t=" << v.toString(heap)->toWideString() << std::endl;
				}
				if (doTime) {
					const double end = getCPUSecs();
					std::cerr << (end - start) << "s" << std::endl;
					std::cerr << heap.size() / (1024.0 * 1024.0) << "MiB" << std::endl;
					std::cerr << peakMemory / (1024.0 * 1024.0) << "MiB" << std::endl;
					std::cerr << heap.peakSize / (1024.0 * 1024.0) << "MiB" << std::endl;
				}

                source = EMPTY_STRING;
            }
        }
        catch (const ScriptException& x) {
        /*	Error* e = x.asErrorObject();
        	if (e != 0) {
        		std::wcout << "type: " << e->getErrorType() << std::endl;
        		std::wcout << "name: " << e->getErrorName()->toWideString() << std::endl;
        		std::wcout << "message: " << e->getErrorMessage()->toWideString() << std::endl;
			}*/
            source = EMPTY_STRING;
            std::wstring ws = x.value.toString(heap)->toWideString();
            ws = L"!!!! " + ws;
            std::wcout << ws << std::endl;
            if (!interactive) {
                return 1;
            } else {
                pushIOLines('!', String(heap.roots(), ws.c_str()));
            }
        }
        catch (const std::exception& x) {
            source = EMPTY_STRING;
            std::cout << "!!!! " << x.what() << std::endl;
            if (!interactive) {
                return 1;
            } else {
                pushIOLines('!', x.what());
            }
        }
        catch (...) {
            source = EMPTY_STRING;
            std::cout << "Unknown exception" << std::endl;
            if (!interactive) {
                return 1;
            } else {
                pushIOLines('!', "Unknown exception");
            }
        }
        if (execute && interactive) {
            pushIOStop();
        }
    }
    // FIX : non-interactive doesn't set eof, god damn weird iostream library!!
    if (interactive && !inStream->eof()) {
    	std::cout << "input stream failure" << std::endl;
    	return 1;
    }
    return 0;
}

#ifdef LIBFUZZ
extern "C" int LLVMFuzzerTestOneInput(const uint8_t *Data, size_t Size) {
	Heap heap;
    Runtime rt(heap);
    rt.resetTimeOut(2);
    rt.setMemoryCap(64*1024*1024);
    try {
	    rt.run(String(reinterpret_cast<const Char*>(Data), reinterpret_cast<const Char*>(Data) + Size / 2));
	}
	catch (Exception&) {
	}
  return 0;  // Non-zero return values are reserved for future use.
}
#endif

#ifndef LIBFUZZ
int main(int argc, const char* argv[]) {
    int rc = testMain(argc, argv);
    if (pauseBeforeQuit) std::wcin.get();
    return rc;
}
#endif

#ifdef _MSC_VER
#pragma float_control(pop)  
#endif
