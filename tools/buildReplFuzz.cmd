@ECHO OFF
SETLOCAL ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION
CD /D "%~dp0.."
IF NOT EXIST output MKDIR output
REM Builds the libFuzzer target for the engine with MSVC, optimized but with asserts on (release with NDEBUG undefined;
REM beta's debug CRT is several times slower), like buildReplFuzz.sh. Pass stdlib to reach src/stdlib.js as well.
REM Give libFuzzer a scratch directory first, since it writes new inputs into its first corpus directory:
REM	output\NuXJSFuzz.exe output\fuzz\corpus tests\fuzz\seeds -dict=tests\fuzz\fuzz.dict
REM Shared rule: Windows fuzzing stays on MSVC, and clang with ASan or UBSan runs on the Mac. The one clang-cl build
REM verified here, kept because MSVC has no UBSan, needs all of CPP_COMPILER="<llvm>\clang-cl.exe" and
REM	-fsanitize=fuzzer,address,undefined -fno-sanitize-recover=all -fsanitize-address-use-after-return=never /Ob0
REM	/U NDEBUG /D _DISABLE_STRING_ANNOTATION /D _DISABLE_VECTOR_ANNOTATION /link /STACK:8388608
REM without the use-after-return flag, ASan's fake stack breaks MSVC exception unwinding and every throwing input
REM "crashes" in __FrameHandler3. Such a build also needs LLVM's copy of the AddressSanitizer DLL, not the one staged
REM below, and the two have the same file name, so do not keep both in output\.

SET "fuzzDefines="
SET "fuzzOutput=output\NuXJSFuzz"
IF /I "%~1"=="stdlib" (
	SET "fuzzDefines=/D LIBFUZZ_STDLIB"
	SET "fuzzOutput=output\NuXJSFuzzStdlib"
	SHIFT
)

SET CPP_OPTIONS=/fsanitize=fuzzer /fsanitize=address /U NDEBUG /D LIBFUZZ %fuzzDefines% /I src %CPP_OPTIONS%
CALL tools\BuildCpp.cmd release x64 "%fuzzOutput%" tools\NuXJSREPL.cpp src\NuXJS.cpp src\stdlibJS.cpp /link /STACK:8388608 || GOTO error

REM AddressSanitizer needs its runtime DLL beside the executable to run outside a Visual Studio prompt. Found the way
REM BuildCpp.cmd finds the toolchain, which is not to be edited.
SET "pfpath=%ProgramFiles(x86)%"
IF NOT DEFINED pfpath SET "pfpath=%ProgramFiles%"
SET "vswhere=%pfpath%\Microsoft Visual Studio\Installer\vswhere.exe"
SET "asanDll="
IF EXIST "%vswhere%" (
	FOR /F "usebackq tokens=*" %%a IN (`"%vswhere%" -latest -products * -property installationPath`) DO SET "vsInstallPath=%%a"
	IF DEFINED vsInstallPath (
		SET /P toolsVersion=<"!vsInstallPath!\VC\Auxiliary\Build\Microsoft.VCToolsVersion.default.txt"
		SET "asanDll=!vsInstallPath!\VC\Tools\MSVC\!toolsVersion!\bin\Hostx64\x64\clang_rt.asan_dynamic-x86_64.dll"
	)
)
IF NOT DEFINED asanDll GOTO searchDll
IF EXIST "!asanDll!" GOTO copyDll
:searchDll
FOR /F "delims=" %%d IN ('DIR /B /S "%ProgramFiles%\Microsoft Visual Studio\*\VC\Tools\MSVC\*\bin\Hostx64\x64\clang_rt.asan_dynamic-x86_64.dll" 2^>NUL') DO SET "asanDll=%%d"
IF NOT EXIST "!asanDll!" (
	ECHO Could not find clang_rt.asan_dynamic-x86_64.dll; %fuzzOutput% will not start until it is beside it.
	GOTO done
)
:copyDll
COPY /Y "!asanDll!" output\ >NUL || GOTO error

:done
ECHO Built %fuzzOutput%.exe
EXIT /b 0

:error
EXIT /b %ERRORLEVEL%
