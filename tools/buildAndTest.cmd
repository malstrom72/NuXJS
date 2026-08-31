@ECHO OFF
SETLOCAL ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION

PUSHD %~dp0

SET target=%~1
SET model=%~2
SET variant=%~3
IF "%target%"=="" SET target=debug
IF "%model%"=="" SET model=x64
IF "%variant%"=="" SET variant=es3
SET CPP_OPTIONS=/FS

REM The es5 variant compiles the ECMAScript 5.1 extensions (guarded by NUXJS_ES5) and gets an "_es5" binary
REM suffix. The es3 variant is the pristine ES3 engine, and has to ask for it: NuXJS.h defaults the macro to 1.
SET suffix=
IF "%variant%"=="es5" (
	SET suffix=_es5
	SET CPP_OPTIONS=/DNUXJS_ES5=1 %CPP_OPTIONS%
) ELSE (
	SET CPP_OPTIONS=/DNUXJS_ES5=0 %CPP_OPTIONS%
)

CD ..\externals\PikaCmd
CALL .\BuildPikaCmd.cmd || GOTO error
CD ..\..\tools
REM The blob carries the guarantee that the es3 build has not moved, so never risk a stale one on an mtime
REM comparison that a checkout can defeat. Regenerating costs a second and rewrites the file only when it changes.
MKDIR ..\output >NUL 2>&1
..\externals\PikaCmd\PikaCmd.exe .\stdlibToCpp.pika ..\src\stdlib.js ..\src\stdlibJS.cpp || GOTO error
..\externals\PikaCmd\PikaCmd.exe .\stdlibToCpp.pika ..\src\stdlib.js ..\output\stdlib.es3.js es3 || GOTO error
IF "%target%"=="release" SET CPP_OPTIONS=/GR- %CPP_OPTIONS%
CALL .\BuildCpp.cmd %target% %model% ..\output\NuXJSTest%suffix%_%target%_%model%.exe .\NuXJSTest.cpp ..\src\NuXJS.cpp ..\src\stdlibJS.cpp || GOTO error
..\output\NuXJSTest%suffix%_%target%_%model% -s >NUL 2>&1 || GOTO error
..\output\NuXJSTest%suffix%_%target%_%model% || GOTO error
CALL .\BuildCpp.cmd %target% %model% ..\output\NuXJS%suffix%_%target%_%model%.exe .\NuXJSREPL.cpp ..\src\NuXJS.cpp ..\src\stdlibJS.cpp || GOTO error

REM Select test directories for the variant: tests\es5 runs only under es5, tests\es3only only under es3.
REM The flag must not be named "include": environment variables are case-insensitive on Windows, so that
REM name overwrites INCLUDE and the examples build below loses every header path (C1083). It only bites
REM when the toolchain is already set up and BuildCpp.cmd therefore skips vcvarsall, which is exactly what
REM happens in a Visual Studio developer prompt, and never in CI, where each call sets INCLUDE up afresh.
SET testDirs=
FOR /D %%D IN (..\tests\*) DO (
	SET useDir=1
	IF /I "%%~nxD"=="es5" IF NOT "%variant%"=="es5" SET useDir=0
	IF /I "%%~nxD"=="es3only" IF "%variant%"=="es5" SET useDir=0
	IF "!useDir!"=="1" SET testDirs=!testDirs! "%%D\"
)
..\externals\PikaCmd\PikaCmd.exe .\test.pika -e -x "..\output\NuXJS%suffix%_%target%_%model% -s --legacy-exceptions" !testDirs! || GOTO error

IF NOT EXIST ..\output\examples MKDIR ..\output\examples
SET "examplesExe=..\output\examples\examples.exe"

ECHO Building examples
CALL .\BuildCpp.cmd %target% %model% "%examplesExe%" ..\docs\examples\examples.cpp ..\src\NuXJS.cpp ..\src\stdlibJS.cpp || GOTO error

ECHO Running examples
%examplesExe% > ..\output\examples\all.log 2>&1 || GOTO error

REM Its own expectation per variant: one example counts 5-cycle batches, and es5 compiles a few more instructions.
IF EXIST ..\docs\examples\expected_examples%suffix%.txt (
	FC ..\docs\examples\expected_examples%suffix%.txt ..\output\examples\all.log || GOTO error
)

ECHO Success!
POPD
EXIT /b 0

:error
ECHO Error %ERRORLEVEL%
POPD
EXIT /b %ERRORLEVEL%
