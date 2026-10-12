@ECHO OFF
SETLOCAL ENABLEEXTENSIONS
PUSHD %~dp0

REM The compile-depth tests, built with the flags products ship and run on a 512 KB stack, the size of a secondary
REM thread on macOS and iOS, so the default compile limit is shown to fit where the stack is tightest.
CD ..\externals\PikaCmd
CALL .\BuildPikaCmd.cmd || GOTO error
CD ..\..\tools
MKDIR ..\output >NUL 2>&1
SET CPP_OPTIONS=/GR- /FS
CALL .\BuildCpp.cmd release x64 ..\output\NuXJS_depth.exe .\NuXJSREPL.cpp ..\src\NuXJS.cpp ..\src\stdlibJS.cpp /link /STACK:524288 || GOTO error
..\externals\PikaCmd\PikaCmd.exe .\test.pika -e -x "..\output\NuXJS_depth -s --legacy-exceptions" ..\tests\extremes\compileDepth.io || GOTO error

POPD
EXIT /b 0
:error
POPD
EXIT /b %ERRORLEVEL%
