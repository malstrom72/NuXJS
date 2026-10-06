@ECHO OFF
SETLOCAL ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION

PUSHD %~dp0

SET target=%~1
SET model=%~2
IF "%target%"=="" SET target=debug
IF "%model%"=="" SET model=x64
SET CPP_OPTIONS=/FS

CD ..\externals\PikaCmd
CALL .\BuildPikaCmd.cmd || GOTO error
CD ..\..\tools
..\externals\PikaCmd\PikaCmd.exe .\stdlibToCpp.pika ..\src\stdlib.js ..\src\stdlibJS.cpp || GOTO error
IF "%target%"=="release" SET CPP_OPTIONS=/GR- %CPP_OPTIONS%
MKDIR ..\output >NUL 2>&1
CALL .\BuildCpp.cmd %target% %model% ..\output\NuXJSTest_%target%_%model%.exe .\NuXJSTest.cpp ..\src\NuXJS.cpp ..\src\stdlibJS.cpp || GOTO error
..\output\NuXJSTest_%target%_%model% -s >NUL 2>&1 || GOTO error
REM Unpack the fuzz corpus so NuXJSTest can replay it. The system tar is bsdtar; a plain `tar` can pick up a GNU tar
REM from another tool's bin directory, which reads .tar.gz but not the .zip this used to be.
IF EXIST ..\output\fuzzReplay RMDIR /S /Q ..\output\fuzzReplay
MKDIR ..\output\fuzzReplay
"%SystemRoot%\System32\tar.exe" -xzf ..\tests\fuzz\corpus.tar.gz --strip-components=1 -C ..\output\fuzzReplay || GOTO error
DIR /B /S /A-D ..\output\fuzzReplay > ..\output\fuzzReplay.txt || GOTO error
..\output\NuXJSTest_%target%_%model% ..\output\fuzzReplay.txt || GOTO error
CALL .\BuildCpp.cmd %target% %model% ..\output\NuXJS_%target%_%model%.exe .\NuXJSREPL.cpp ..\src\NuXJS.cpp ..\src\stdlibJS.cpp || GOTO error
..\externals\PikaCmd\PikaCmd.exe .\test.pika -e -x "..\output\NuXJS_%target%_%model% -s --legacy-exceptions" ..\tests\ || GOTO error

IF NOT EXIST ..\output\examples MKDIR ..\output\examples
SET "examplesExe=..\output\examples\examples.exe"

ECHO Building examples
CALL .\BuildCpp.cmd %target% %model% "%examplesExe%" ..\docs\examples\examples.cpp ..\src\NuXJS.cpp ..\src\stdlibJS.cpp || GOTO error

ECHO Running examples
%examplesExe% > ..\output\examples\all.log 2>&1 || GOTO error

IF EXIST ..\docs\examples\expected_examples.txt (
	FC ..\docs\examples\expected_examples.txt ..\output\examples\all.log || GOTO error
)

ECHO Success!
POPD
EXIT /b 0

:error
ECHO Error %ERRORLEVEL%
POPD
EXIT /b %ERRORLEVEL%
