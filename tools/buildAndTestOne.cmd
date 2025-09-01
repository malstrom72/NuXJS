@ECHO OFF
SETLOCAL ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION

PUSHD %~dp0

SET target=%~1
SET model=%~2
SET es5=%~3
IF "%target%"=="" SET target=debug
IF "%model%"=="" SET model=x64
IF "%CPP_OPTIONS%"=="" SET CPP_OPTIONS=/FS
IF /I "%target%"=="release" SET CPP_OPTIONS=/GR- %CPP_OPTIONS%
IF NOT "%es5%"=="" SET CPP_OPTIONS=%CPP_OPTIONS% /DNUXJS_ES5=%es5%

MKDIR ..\output >NUL 2>&1

CALL .\BuildCpp.cmd %target% %model% ..\output\NuXJSTest_%target%_%model%.exe .\NuXJSTest.cpp ..\src\NuXJS.cpp ..\src\stdlibJS.cpp || GOTO error
..\output\NuXJSTest_%target%_%model% -s >NUL 2>&1 || GOTO error
..\output\NuXJSTest_%target%_%model% || GOTO error
CALL .\BuildCpp.cmd %target% %model% ..\output\NuXJS_%target%_%model%.exe .\NuXJSREPL.cpp ..\src\NuXJS.cpp ..\src\stdlibJS.cpp || GOTO error

IF NOT "%es5%"=="" (
	SET es5_enabled=%es5%
) ELSE (
	ECHO %CPP_OPTIONS% | FINDSTR /C:"/DNUXJS_ES5=0" >NUL
	IF ERRORLEVEL 1 (
		SET es5_enabled=1
	) ELSE (
		SET es5_enabled=0
	)
)

SET TEST_DIRS=..\tests\conforming\ ..\tests\erroneous\ ..\tests\es3only\
IF "%es5_enabled%"=="1" SET TEST_DIRS=%TEST_DIRS% ..\tests\es5\
SET TEST_DIRS=%TEST_DIRS% ..\tests\extremes\
IF "%es5_enabled%"=="1" SET TEST_DIRS=%TEST_DIRS% ..\tests\from262\
SET TEST_DIRS=%TEST_DIRS% ..\tests\migrated\ ..\tests\regression\ ..\tests\stdlib\ ..\tests\unconforming\ ..\tests\unsorted\

..\externals\PikaCmd\PikaCmd.exe .\test.pika -e -x ..\output\NuXJS_%target%_%model% %TEST_DIRS% || GOTO error
CALL runExamples.cmd %target% || GOTO error

IF NOT "%es5%"=="" ECHO Done NUXJS_ES5=%es5% (%target% %model%)

POPD
EXIT /b 0

:error
POPD
EXIT /b %ERRORLEVEL%
