#ifdef _MSC_VER
#pragma float_control(precise, on, push)  
#endif

#include <stdint.h>
#include "../src/NuXJScript.h"
#include <fstream>
#include <memory>
#include <vector>
#include <sstream>
#include <stdexcept>
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
		std::cerr << "\tVars: " << code.getVarsCount() << std::endl;
		std::cerr << "\tArguments: " << code.getArgumentsCount() << std::endl;

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


bool pauseBeforeQuit = false;



static UInt32 calcUTF8ToUTF16Size(UInt32 utf8Size, const char* utf8Chars) {
		UInt32 n = 0;
		for (UInt32 i = 0; i < utf8Size; ++i) {
				Byte c = static_cast<Byte>(utf8Chars[i]);
				if ((c & 0x80) == 0) {
						++n;
				} else if ((c & 0xE0) == 0xC0) {
						assert(i + 1 < utf8Size && (utf8Chars[i + 1] & 0xC0) == 0x80);
						++n;
						++i;
				} else if ((c & 0xF0) == 0xE0) {
						assert(i + 2 < utf8Size && (utf8Chars[i + 1] & 0xC0) == 0x80 && (utf8Chars[i + 2] & 0xC0) == 0x80);
						++n;
						i += 2;
				} else if ((c & 0xF8) == 0xF0) {
						assert(i + 3 < utf8Size && (utf8Chars[i + 1] & 0xC0) == 0x80 && (utf8Chars[i + 2] & 0xC0) == 0x80 && (utf8Chars[i + 3] & 0xC0) == 0x80);
						n += 2;
						i += 3;
				} else {
						assert(false);
				}
		}
		return n;
}

static UInt32 convertUTF8ToUTF16(UInt32 utf8Size, const char* utf8Chars, Char* utf16Chars) {
		UInt32 outIndex = 0;
		for (UInt32 i = 0; i < utf8Size;) {
				Byte c = static_cast<Byte>(utf8Chars[i]);
				if ((c & 0x80) == 0) {
						utf16Chars[outIndex++] = static_cast<Char>(c);
						++i;
				} else if ((c & 0xE0) == 0xC0) {
						assert(i + 1 < utf8Size);
						Char cc = static_cast<Char>(((c & 0x1F) << 6) | (static_cast<Byte>(utf8Chars[i + 1]) & 0x3F));
						utf16Chars[outIndex++] = cc;
						i += 2;
				} else if ((c & 0xF0) == 0xE0) {
						assert(i + 2 < utf8Size);
						Char cc = static_cast<Char>(((c & 0x0F) << 12)
										| ((static_cast<Byte>(utf8Chars[i + 1]) & 0x3F) << 6)
										| (static_cast<Byte>(utf8Chars[i + 2]) & 0x3F));
						utf16Chars[outIndex++] = cc;
						i += 3;
				} else if ((c & 0xF8) == 0xF0) {
						assert(i + 3 < utf8Size);
						UInt32 c32 = ((c & 0x07) << 18)
										| ((static_cast<Byte>(utf8Chars[i + 1]) & 0x3F) << 12)
										| ((static_cast<Byte>(utf8Chars[i + 2]) & 0x3F) << 6)
										| (static_cast<Byte>(utf8Chars[i + 3]) & 0x3F);
						utf16Chars[outIndex++] = static_cast<Char>(((c32 - 0x10000) >> 10) + 0xD800);
						utf16Chars[outIndex++] = static_cast<Char>(((c32 - 0x10000) & 0x3FF) + 0xDC00);
						i += 4;
				} else {
						assert(false);
				}
		}
		return outIndex;
}

Var read(Runtime& rt, const Var& thisVar, const VarList& args) {
		std::ifstream file;
		const String* contentsString = 0;
		try {
			const String* filenameString = args[0];
			const std::string filename = filenameString->toUTF8String();
			file.open(filename.c_str(), std::ios::binary);
			if (!file.good()) {
				   ScriptException::throwError(rt.getHeap(), GENERIC_ERROR, "Could not open input file");
			}
			file.exceptions(std::ios_base::badbit | std::ios_base::failbit);
			std::string contents((std::istreambuf_iterator<char>(file)), std::istreambuf_iterator<char>());
			Heap& heap = rt.getHeap();
			UInt32 utf16Size = calcUTF8ToUTF16Size(static_cast<UInt32>(contents.size()), contents.data());
			std::vector<Char> buffer(utf16Size);
			convertUTF8ToUTF16(static_cast<UInt32>(contents.size()), contents.data(), buffer.data());
			contentsString = new(heap) String(heap.managed(), buffer.data(), buffer.data() + utf16Size);
		}
		catch (const std::ios_base::failure& x) {
			ScriptException::throwError(rt.getHeap(), GENERIC_ERROR, x.what());
		}
		return Var(rt, Value(contentsString));
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
		}
		return p;
	}
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
	try {
	String source(EMPTY_STRING);
	std::string inputFilePath;
	std::istream* inStream = &std::cin;
	bool doTime = false;
	size_t peakMemory = 0;
	bool doSuppressStdErr = false;
	bool loadStdLib = true;
	for (int argi = 1; argi < argc; ++argi) {
		if (strcmp(argv[argi], "-t") == 0) doTime = true;
		else if (strcmp(argv[argi], "-s") == 0) doSuppressStdErr = true;
		else if (strcmp(argv[argi], "-p") == 0) pauseBeforeQuit = true;
		else if (strcmp(argv[argi], "-n") == 0) loadStdLib = false;
		else if (inputFilePath.empty()) {
			inputFilePath = argv[argi];
			interactive = false;
		} else {
			std::cout << "Too many arguments" << std::endl;
			return 1;
		}
	}

	if (inputFilePath.empty() && !inStream->good()) {
		std::cerr << "Could not open input stream" << std::endl;
		return 1;
	}

	const String LF_STRING("\n");
	const String PRINT_STRING("print");

	MyHeap heap;
	Runtime rt(heap);
	if (!inputFilePath.empty()) {
		std::ifstream file(inputFilePath.c_str(), std::ios::binary);
		if (!file.good()) {
			std::cerr << "Could not open input stream" << std::endl;
			return 1;
		}
		std::string contents((std::istreambuf_iterator<char>(file)), std::istreambuf_iterator<char>());
		UInt32 utf16Size = calcUTF8ToUTF16Size(static_cast<UInt32>(contents.size()), contents.data());
		std::vector<Char> buffer(utf16Size);
		convertUTF8ToUTF16(static_cast<UInt32>(contents.size()), contents.data(), buffer.data());
		source = String(heap.roots(), buffer.data(), buffer.data() + utf16Size);
	} else {
		if (!inStream->good()) {
			std::cerr << "Could not open input stream" << std::endl;
			return 1;
		}
	}

	Object& globals = *rt.getGlobalObject();
	Var globs = rt.getGlobalsVar();
	globs["read"] = read;
	globs["load"] = load;
	globs["quit"] = quit;

	PrintFunction printFunction;
	globals.setOwnProperty(rt, &PRINT_STRING, &printFunction, DONT_ENUM_FLAG);
	GCFunction gcFunction;
	const String GC_STRING("gc");
	globals.setOwnProperty(rt, &GC_STRING, &gcFunction, DONT_ENUM_FLAG);
	globals.setOwnProperty(rt, String::allocate(heap, "dasm"), new(heap) FunctorAdapter<NativeFunction>(heap.managed(), disassemble), DONT_ENUM_FLAG);
	CallbackTest callbackTest;
	globals.setOwnProperty(rt, String::allocate(heap, "callbackTest"), &callbackTest, DONT_ENUM_FLAG);

	randomSeed();

	if (loadStdLib) {
		try {
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


	Processor processor(rt);
	processor.run(STANDARD_CYCLES_BETWEEN_AUTO_GC); // just testing some weird behaviour

	inStream->exceptions(std::ios_base::badbit);
	while ((interactive ? inStream->good() : true) && !doQuit) {
		if (interactive) {
			assert(!inStream->fail());
		}
		bool execute = false;
		try {
			if (interactive) {
				std::string utf8Line;
				std::getline(*inStream, utf8Line);
				if (!inStream->good() && !inStream->eof()) throw std::runtime_error("Input error");
				// FIX : add #undo that drops just the last one
				if (utf8Line == "#save" || utf8Line.compare(0, 6, "#save ") == 0) {
					std::wstring s;
					UInt32 size16 = calcUTF8ToUTF16Size(static_cast<UInt32>(utf8Line.size()), utf8Line.data());
					std::vector<Char> buf(size16);
					convertUTF8ToUTF16(static_cast<UInt32>(utf8Line.size()), utf8Line.data(), buf.data());
					s.assign(buf.begin(), buf.end());
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
				} else if (utf8Line == "#purge") {
					ioLines.clear();
					std::cout << "purged" << std::endl;
				} else if (!utf8Line.empty()) {
					UInt32 size16 = calcUTF8ToUTF16Size(static_cast<UInt32>(utf8Line.size()), utf8Line.data());
					std::vector<Char> buf(size16);
					convertUTF8ToUTF16(static_cast<UInt32>(utf8Line.size()), utf8Line.data(), buf.data());
					String line(heap.roots(), buf.data(), buf.data() + size16);
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
				if (inputFilePath.empty()) {
					std::string contents((std::istreambuf_iterator<char>(*inStream)), std::istreambuf_iterator<char>());
					UInt32 size16 = calcUTF8ToUTF16Size(static_cast<UInt32>(contents.size()), contents.data());
					std::vector<Char> buf(size16);
					convertUTF8ToUTF16(static_cast<UInt32>(contents.size()), contents.data(), buf.data());
					source = String(heap.roots(), buf.data(), buf.data() + size16);
				}
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
	if (interactive && !inStream->eof()) {
		std::cout << "input stream failure" << std::endl;
		return 1;
	}
	return 0;
	}
	catch (const Exception& x) {
		std::cerr << "Uncaught exception: " << x.what() << std::endl;
	}
	catch (const std::exception& x) {
		std::cerr << "Uncaught std::exception: " << x.what() << std::endl;
	}
	catch (...) {
		std::cerr << "Uncaught unknown exception" << std::endl;
	}
	return 1;
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
