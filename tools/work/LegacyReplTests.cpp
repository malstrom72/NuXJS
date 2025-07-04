// Legacy REPL helper tests preserved for reference.
// These were removed from NuXJREPL.cpp in commit 1c94e96930ac393051cb76839e7fbad371db9ab4.
// Wrapped in #if 0 to avoid interfering with normal builds.

#if 0
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

// Additional snippets removed from NuXJSREPL.cpp for reference:
//      std::cerr << "\tConstants: " << code.getConstants().size() << std::endl;
//      std::cout << " peak: " << peakSize << std::endl;
//      std::cout << " + " << size << std::endl;
//      std::cout << " - " << size << std::endl;
/*      virtual void releaseMemory(void* ptr, size_t size) {
                // std::cout << " - " << size << std::endl;
                return Heap::releaseMemory(ptr, size);
        }*/
// inStream->exceptions(std::ios_base::badbit | std::ios_base::failbit);
/*std::cout << sizeof(Value) << std::endl;
 std::cout << sizeof(String) << std::endl;
 std::cout << sizeof(JSObject) << std::endl;
 std::cout << sizeof(Array) << std::endl;
 std::cout << sizeof(ScriptFunction) << std::endl;*/
/*std::cerr << "Value size: " << sizeof (Value) << std::endl;
 std::cerr << "Bucket size: " << sizeof (Table::Bucket) << std::endl;
 std::cerr << "Table size: " << sizeof (Table) << std::endl;*/
/*                      const Constants* const consts = rt.getSharedConstants();
                        for (const Value* p = consts->begin(); p != consts->end(); ++p) {
                                std::wcerr << "\t\t" << p->toString(heap)->toWideString() << std::endl;
                        }*/
/*      Error* e = x.asErrorObject();
                if (e != 0) {
                        std::wcout << "type: " << e->getErrorType() << std::endl;
                        std::wcout << "name: " << e->getErrorName()->toWideString() << std::endl;
                        std::wcout << "message: " << e->getErrorMessage()->toWideString() << std::endl;
                        }
*/
//      const Value TEST_ARGV[1] = { String::alloc(heap, "Hello") };
//      printFunction.invoke(processor, 1, TEST_ARGV, &globals);
//      processor.run();        // just testing some weird behaviour
//      processor.run(STANDARD_CYCLES_BETWEEN_AUTO_GC); // just testing some weird behaviour
//      std::wifstream stdlibStream("stdlib.js");
//      std::wstring sourceWString = std::wstring(std::istreambuf_iterator<wchar_t>(stdlibStream), std::istreambuf_iterator<wchar_t>());
//      String source = String(heap.roots(), sourceWString.c_str());
//      stdlibStream.close();

#endif
