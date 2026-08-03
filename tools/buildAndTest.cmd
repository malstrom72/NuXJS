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
REM suffix. The es3 variant is the pristine ES3 engine, built exactly as before.
SET suffix=
IF "%variant%"=="es5" (
	SET suffix=_es5
	SET CPP_OPTIONS=/DNUXJS_ES5=1 %CPP_OPTIONS%
)

CD ..\externals\PikaCmd
CALL .\BuildPikaCmd.cmd || GOTO error
CD ..\..\tools
REM Regenerate the embedded stdlib when any input is newer than the generated file.
SET regen=0
FOR %%F IN (..\src\stdlib.js ..\src\stdlibES5.js .\stdlibToCpp.pika .\stdlibMinifier.ppeg) DO (
	FOR /F %%R IN ('DIR /B /O:D "%%F" "..\src\stdlibJS.cpp" 2^>NUL') DO SET newest=%%R
	IF NOT "!newest!"=="stdlibJS.cpp" SET regen=1
)
IF "!regen!"=="1" ..\externals\PikaCmd\PikaCmd.exe .\stdlibToCpp.pika ..\src\stdlib.js ..\src\stdlibJS.cpp || GOTO error
IF "%target%"=="release" SET CPP_OPTIONS=/GR- %CPP_OPTIONS%
MKDIR ..\output >NUL 2>&1
CALL .\BuildCpp.cmd %target% %model% ..\output\NuXJSTest%suffix%_%target%_%model%.exe .\NuXJSTest.cpp ..\src\NuXJS.cpp ..\src\stdlibJS.cpp || GOTO error
..\output\NuXJSTest%suffix%_%target%_%model% -s >NUL 2>&1 || GOTO error
..\output\NuXJSTest%suffix%_%target%_%model% || GOTO error
CALL .\BuildCpp.cmd %target% %model% ..\output\NuXJS%suffix%_%target%_%model%.exe .\NuXJSREPL.cpp ..\src\NuXJS.cpp ..\src\stdlibJS.cpp || GOTO error

REM Select test directories for the variant: tests\es5 runs only under es5, tests\es3only only under es3.
SET testDirs=
FOR /D %%D IN (..\tests\*) DO (
	SET include=1
	IF /I "%%~nxD"=="es5" IF NOT "%variant%"=="es5" SET include=0
	IF /I "%%~nxD"=="es3only" IF "%variant%"=="es5" SET include=0
	IF "!include!"=="1" SET testDirs=!testDirs! "%%D\"
)
..\externals\PikaCmd\PikaCmd.exe .\test.pika -e -x "..\output\NuXJS%suffix%_%target%_%model% -s --legacy-exceptions" !testDirs! || GOTO error

IF NOT EXIST ..\output\examples MKDIR ..\output\examples
SET "examplesExe=..\output\examples\examples.exe"

ECHO Building examples
CALL .\BuildCpp.cmd %target% "%examplesExe%" ..\docs\examples\examples.cpp ..\src\NuXJS.cpp ..\src\stdlibJS.cpp || GOTO error

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
