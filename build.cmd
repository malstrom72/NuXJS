@ECHO OFF
SETLOCAL ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION
PUSHD %~dp0

SET variant=%1
SET model=%2

IF /I "%variant%"=="es3" (
	SET CPP_OPTIONS=%CPP_OPTIONS% /DNUXJS_ES5=0
) ELSE IF /I "%variant%"=="es5" (
	SET CPP_OPTIONS=%CPP_OPTIONS% /DNUXJS_ES5=1
) ELSE IF /I "%variant%"=="both" (
	SET NUXJS_TEST_ES5_VARIANTS=1
) ELSE (
	SET model=%variant%
)

IF "%model%"=="" SET model=x64

CALL tools\buildAndTest.cmd beta %model% || GOTO error
CALL tools\buildAndTest.cmd release %model% || GOTO error

IF EXIST output\NuXJS_release_%model%.exe (
	MOVE /Y output\NuXJS_release_%model%.exe output\NuXJS.exe >NUL
)
ECHO === ALL BUILDS AND TESTS COMPLETED SUCCESSFULLY ===
POPD
EXIT /b 0

:error
EXIT /b %ERRORLEVEL%
