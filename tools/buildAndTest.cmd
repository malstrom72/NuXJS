@ECHO OFF
SETLOCAL ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION

PUSHD %~dp0

SET target=%~1
SET model=%~2
IF "%target%"=="" SET target=debug
IF "%model%"=="" SET model=x64
SET CPP_OPTIONS=/FS

CD .\PikaCmd
CALL .\BuildPikaCmd.cmd || GOTO error
CD ..
.\PikaCmd\PikaCmd.exe .\stdlibToCpp.pika ..\src\stdlib.js ..\src\stdlibJS.cpp || GOTO error
IF "%target%"=="release" SET CPP_OPTIONS=/GR- %CPP_OPTIONS%
MKDIR ..\output >NUL 2>&1
CALL .\BuildCpp.cmd %target% %model% ..\output\NuXJSTest_%target%_%model%.exe .\NuXJSTest.cpp ..\src\NuXJScript.cpp ..\src\stdlibJS.cpp || GOTO error
..\output\NuXJSTest_%target%_%model% -s >NUL 2>&1 || GOTO error
..\output\NuXJSTest_%target%_%model% || GOTO error
CALL .\BuildCpp.cmd %target% %model% ..\output\NuXJScript_%target%_%model%.exe .\NuXJREPL.cpp ..\src\NuXJScript.cpp ..\src\stdlibJS.cpp || GOTO error
.\PikaCmd\PikaCmd.exe .\test.pika -e -x ..\output\NuXJScript_%target%_%model% ..\tests\ || GOTO error
ECHO Success!
POPD
EXIT /b 0

:error
ECHO Error %ERRORLEVEL%
POPD
EXIT /b %ERRORLEVEL%
