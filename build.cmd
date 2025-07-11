@ECHO OFF

SETLOCAL ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION



SET model=%1

IF "%model%"=="" SET model=native

	CALL tools\buildAndTest.cmd beta %model% || GOTO error
	CALL tools\buildAndTest.cmd release %model% || GOTO error

	IF EXIST output\NuXJScript_release_%model%.exe (

	MOVE /Y output\NuXJScript_release_%model%.exe output\NuXJScript.exe >NUL

)

EXIT /b 0


:error

EXIT /b %ERRORLEVEL%

