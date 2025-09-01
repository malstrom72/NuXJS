@ECHO OFF
SETLOCAL ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION

PUSHD %~dp0

SET target=%~1
SET model=%~2
IF "%target%"=="" SET target=debug
IF "%model%"=="" SET model=x64
IF "%CPP_OPTIONS%"=="" SET CPP_OPTIONS=/FS

REM Build PikaCmd and update stdlibJS.cpp
PUSHD ..\externals\PikaCmd
CALL .\BuildPikaCmd.cmd || GOTO error
POPD
..\externals\PikaCmd\PikaCmd.exe .\stdlibToCpp.pika ..\src\stdlib.js ..\src\stdlibJS.cpp || GOTO error

REM Optional dual-variant test mode
IF "%NUXJS_TEST_ES5_VARIANTS%"=="1" (
	IF /I "%target%"=="release" IF "%NUXJS_SKIP_RELEASE%"=="1" (
		ECHO Skipping release per NUXJS_SKIP_RELEASE=1
		POPD
		EXIT /b 0
	)
	FOR %%E IN (0 1) DO (
		ECHO Building and testing with NUXJS_ES5=%%E (%target% %model%)
		CALL .\buildAndTestOne.cmd %target% %model% %%E || GOTO error
	)
) ELSE (
	CALL .\buildAndTestOne.cmd %target% %model% || GOTO error
)

ECHO Success!
POPD
EXIT /b 0

:error
ECHO Error %ERRORLEVEL%
POPD
EXIT /b %ERRORLEVEL%
