@ECHO OFF
SETLOCAL ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION
PUSHD %~dp0

SET model=%1
IF "%model%"=="" SET model=x64

CALL tools\buildAndTest.cmd beta %model% || GOTO error
CALL tools\buildAndTest.cmd release %model% || GOTO error

IF EXIST output\NuXJScript_release_%model%.exe (
	MOVE /Y output\NuXJScript_release_%model%.exe output\NuXJScript.exe >NUL
)
POPD
EXIT /b 0

:error
EXIT /b %ERRORLEVEL%
